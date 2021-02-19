#!/bin/sh

set -euxo pipefail

if [ -n "${OPENRC:-}" ] ; then
    . $OPENRC
fi

scriptdir=$( dirname $0 )

PROPERTIES_FILE=${PROPERTIES_FILE:-${1:-$scriptdir/demo-heat-properties.yaml}}
STACK_NAME=${STACK_NAME:-$USER.demo.test}
STACK_FILE=${STACK_FILE:-$scriptdir/demo-heat-template.yaml}
SERVER_NAME=${SERVER_NAME:-$USER.demo.test}
declare -A name2ip=([machineA]="" [machineB]="" [machineC]="")
declare -A name2fqdn=([machineA]="" [machineB]="" [machineC]="")
ANSIBLE_USER=${ANSIBLE_USER:-demo}
export ANSIBLE_STDOUT_CALLBACK=debug

if [ -z "$START_STEP" ] ; then
    echo Error: must define START_STEP
    exit 1
fi

STOP_STEP="${STOP_STEP:-run_ansible}"

wait_until_cmd() {
    ii=$3
    interval=${4:-10}
    while [ $ii -gt 0 ] ; do
        $1 $2 && break
        sleep $interval
        ii=`expr $ii - $interval`
    done
    if [ $ii -le 0 ] ; then
        return 1
    fi
    return 0
}

get_machine() {
    nova list | awk -v pat=$1 '$0 ~ pat {print $2}'
}

get_stack() {
    openstack stack list | awk -v pat=$1 '$0 ~ pat {print $2}'
}

cleanup_old_machine_and_stack() {
    stack=`get_stack $STACK_NAME`
    if [ -n "$stack" ] ; then
        openstack stack delete -y $stack || openstack stack delete $stack
    fi

    if [ -n "$stack" ] ; then
        wait_s_d() {
            status=`openstack stack list | awk -v ss=$1 '$0 ~ ss {print $6}'`
            if [ "$status" = "DELETE_FAILED" ] ; then
                # try again
                openstack stack delete -y $1 || openstack stack delete $stack
                return 1
            fi
            test -z "`get_stack $1`"
        }
        wait_until_cmd wait_s_d $STACK_NAME 400 20
    fi

    mach=`get_machine $SERVER_NAME`
    if [ -n "$mach" ] ; then
        nova delete $mach
    fi

    if [ -n "$mach" ] ; then
        wait_n_d() { nova show $1 > /dev/null ; }
        wait_until_cmd wait_n_d $mach 400 20
    fi
}

get_stack_out_val() {
    local val=$(openstack stack output show $1 $2 -c output_value -f value)
    if [ -n "$val" ] ; then
        echo "$val"
        return 0
    fi
    return 1
}

get_mach_status() {
    nova console-log $SERVER_NAME
}

wait_for_stack_create() {
    status=`openstack stack list | awk -v ss=$1 '$0 ~ ss {print $6}'`
    if [ -z "${status:-}" ] ; then
        return 1 # not created yet
    elif [ $status = "CREATE_IN_PROGRESS" ] ; then
        return 1
    elif [ $status = "CREATE_COMPLETE" ] ; then
        return 0
    elif [ $status = "CREATE_FAILED" ] ; then
        echo could not create stack
        openstack stack show $STACK_NAME
        exit 1
    else
        echo unknown stack create status $status
        return 1
    fi
    return 0
}

get_cloud_init_finished() {
    ansible -vv -i inventory $1 -m shell -a "tail -1 /var/log/cloud-init-output.log | grep '^Cloud-init.* finished at '" 
}

create_stack_and_machs_get_external_ips() {
    openstack stack create -e $PROPERTIES_FILE \
              -t $STACK_FILE $STACK_NAME

    wait_until_cmd wait_for_stack_create $STACK_NAME 600

    stack=`get_stack $STACK_NAME`
    for host in ${!name2ip[*]}; do
        wait_until_cmd get_stack_out_val "$stack ${host}_ip" 400
    done
}

get_fqdn() {
    # use getent hosts $ip to get the fqdn used by the host
    ssh -n -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no demo@"$1" "getent hosts $1" | \
        awk -v ip="$1" '$0 ~ "^" ip " " {print $2; exit 0}; {exit 1}'
}

make_inventory() {
    # Use fqdn for host key if available, otherwise, use the
    # shortname - always use the ip address for ansible_host
    echo "all:"
    echo "  hosts:"
    local firsthost=""
    local domain=""
    local host
    for host in ${!name2ip[*]}; do
        local invhost=""
        if [ -n "${name2fqdn[$host]}" ]; then
            invhost="${name2fqdn[$host]}"
            domain=${invhost#*.}
        else
            invhost="$host"
        fi
        if [ -z "$firsthost" ]; then
            firsthost="$invhost"
        fi
        echo "    ${invhost}:"
        echo "      ansible_host: ${name2ip[$host]}"
        echo "      ansible_ssh_common_args: -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
        echo "      ansible_user: ${ANSIBLE_USER}"
        echo "      ansible_become: true"
    done
    echo "  vars:"
    echo "    metrics_server: $firsthost"
    echo "    logging_server: $firsthost"
    if [ -n "$domain" ]; then
        echo "    logging_domain: $domain"
    fi
    echo "    vpn_connections:"
    echo "      - hosts:"
    for host in ${name2fqdn[*]}; do
        echo "          ${host}:"
        echo "            hostname: ${host}"
    done
    echo "        auto: start"
    echo "        rekey: true"
    echo "  children:"
    echo "    logging_servers:"
    echo "      hosts:"
    echo "        $firsthost:"
    echo "    metrics_servers:"
    echo "      hosts:"
    echo "        $firsthost:"
    echo "      vars:"
    echo "        metrics_monitored_hosts:"
    for host in ${name2fqdn[*]}; do
        if [ "$host" != "$firsthost" ]; then
            echo "          - $host"
        fi
    done
    echo "    nfs_servers:"
    echo "      hosts:"
    echo "        $firsthost:"
    echo "      vars:"
    echo "        storage_data_volume: $disk_path"
}

if [ "$START_STEP" = clean ] ; then
    cleanup_old_machine_and_stack
    START_STEP=create
fi
if [ "$STOP_STEP" = clean ] ; then
    exit 0
fi

stack=
if [ "$START_STEP" = create ] ; then
    create_stack_and_machs_get_external_ips
    START_STEP=getips
fi
if [ "$STOP_STEP" = create ] ; then
    exit 0
fi

if [ "$START_STEP" = getips ] ; then
    if [ -z "$stack" ] ; then
        stack=`get_stack $STACK_NAME`
    fi
    for host in ${!name2ip[*]} ; do
        name2ip[$host]=$(get_stack_out_val $stack ${host}_ip)
    done
    START_STEP=getfqdns
fi
if [ "$STOP_STEP" = getips ] ; then
    exit 0
fi

if [ "$START_STEP" = getfqdns ] ; then
    if [ -z "$stack" ] ; then
        stack=`get_stack $STACK_NAME`
    fi
    for host in ${!name2ip[*]} ; do
        if [ -z "${name2ip[$host]}" ]; then
            name2ip[$host]=$(get_stack_out_val $stack ${host}_ip)
        fi
        wait_until_cmd get_fqdn "${name2ip[$host]}" 300
        name2fqdn[$host]=$(get_fqdn "${name2ip[$host]}")
    done
    START_STEP=inventory
fi
if [ "$STOP_STEP" = getfqdns ] ; then
    exit 0
fi

if [ "$START_STEP" = inventory ] ; then
    if [ -z "$stack" ] ; then
        stack=`get_stack $STACK_NAME`
    fi
    for host in ${!name2ip[*]} ; do
        if [ -z "${name2ip[$host]}" ]; then
            name2ip[$host]=$(get_stack_out_val $stack ${host}_ip)
        fi
    done
    for host in ${!name2fqdn[*]} ; do
        if [ -z "${name2fqdn[$host]}" ]; then
            name2fqdn[$host]=$(get_fqdn "${name2ip[$host]}")
        fi
    done
    disk_path=$(get_stack_out_val $stack data_volume_path)
    if [ ! -d inventory ]; then
        mkdir -p inventory
    fi
    INVENTORY=${INVENTORY:-inventory/inventory.yml}
    make_inventory > $INVENTORY
    START_STEP=wait_for_cloud_init
fi
if [ "$STOP_STEP" = inventory ] ; then
    exit 0
fi

if [ "$START_STEP" = wait_for_cloud_init ] ; then
    for host in ${!name2ip[*]} ; do
        wait_until_cmd get_cloud_init_finished $host 600 30
    done
    START_STEP=collection
fi
if [ "$STOP_STEP" = wait_for_cloud_init ] ; then
    exit 0
fi

if [ "$START_STEP" = collection ] ; then
    srcpath=$(pwd)/lsr
    pushd $HOME/linux-system-roles/auto-maintenance > /dev/null 2>&1
    python release_collection.py --src-path $srcpath --collection-release-yml collection_release.yml.demo --force
    popd > /dev/null 2>&1
    ansible-galaxy collection install --force oasis_roles.system
    START_STEP=extra_setup
fi
if [ "$STOP_STEP" = collection ] ; then
    exit 0
fi

if [ "$START_STEP" = extra_setup ] ; then
    rm -f ansible.log
    ANSIBLE_LOG_PATH=ansible.log ansible-playbook -vv -i inventory extra_setup.yml
    START_STEP=run_ansible
fi
if [ "$STOP_STEP" = extra_setup ] ; then
    exit 0
fi

if [ "$START_STEP" = run_ansible ] ; then
    rm -f ansible.log
    ANSIBLE_LOG_PATH=ansible.log ansible-playbook -vv -i inventory playbook.yml
fi
