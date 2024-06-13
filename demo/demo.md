---
layout: default
links:
  - title: GitHub
    url: https://github.com/linux-system-roles
  - title: Galaxy
    url: https://galaxy.ansible.com/linux-system-roles
---
The **Linux System Roles** are a collection of roles and modules executed by
Ansible to assist Linux admins in the configuration of common GNU/Linux
subsystems. Conceptually, the intent is to serve as a consistent "API" to a
give Linux distribution that is consistent across multiple major and minor
releases. This collection is available in Ansible Galaxy at
[linux-system-roles](https://galaxy.ansible.com/ui/repo/published/fedora/linux_system_roles/).

## Demo time!
This demo provides a collection of ansible playbooks that call upon the Linux System Roles to configure aspects of a test subject virtual machine.

This demo assumes the follow environment is already configured:

### Control Node
  - RHEL 7.4 or later, physical or virtual
  - Subscribed to Red Hat Subscription Manager (RHSM)
  - Base and Extras channels enabled
  - Name resolution of test environment. Could be /etc/hosts
  - Ansible inventory populated
  - Root ssh keys have been exchanged to grant access; use `ssh-copy-id`

  ~~~
  [root@rhel74-controlnode ~]# cat /etc/hosts
  127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
  ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

  192.168.75.224 rhel74-controlNode
  192.168.75.200 rhel74-test

  [root@rhel74-controlnode ~]# head /etc/ansible/hosts
  localhost
  rhel74-controlNode

  [rhel:children]
  rhel7_hosts
  rhel6_hosts

  [rhel7_hosts]
  rhel74-controlNode
  rhel74-test

  [root@rhel74-controlnode ~]# ssh-copy-id root@rhel74-test

  ~~~

### Test subject virtual machine
  - Virtual machine (easiest way to test multiple NICs and kdump)
    - vCPU, 2G RAM
    - RHEL 6.9 or later
  - Subscribed to Red Hat Subscription Manager (RHSM)
  - Base and Extras channels enabled

### Running the demo
Execute the Ansible commands on the ControlNode and the verification commands on the managed client node.

~~~
ansible rhel74-test -m setup -a 'gather_subset=network'
ansible rhel74-test -m setup -a 'gather_subset=network filter=ansible_interfaces'
ansible rhel74-test -m setup -a 'gather_subset=network filter=ansible_e*' |grep -e ansible_e -e macaddr

ansible-playbook -l rhel74-test 1example-network.yml
    # verify on test node
    nmcli c;  nmcli d;
    ip addr

ansible-playbook -l rhel74-test 2example-network-remove.yml
    # verify on test node
    nmcli c;  nmcli d;
    ip addr

ansible-playbook -l rhel74-test 3example-timesync.yml
    # verify on test node
    systemctl list-units | grep -i -e ntp -e chrony
    systemctl status chronyd.service
    ls /etc/chrony*
    less /etc/chrony.conf

ansible-playbook -l rhel74-test 4example-first-kdump.yml
ansible-playbook -l rhel74-test 5example-selinux.yml
# These two steps will do the very basics to enable kdump and selinux.
# However, if not previously configured during install time, they will
# require a reboot.  This is not automatically done by Ansible or the
# System Roles by design.

ansible-playbook -l rhel74-test 6example-kdump.yml
    # verify on test node
    getenforce
    ls -lZd /var/mycrash
    systemctl status kdump
    ls /etc/kdump*
    less /etc/kdump.conf
~~~
