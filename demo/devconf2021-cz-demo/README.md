These files were used to create the demo given at DevConf.cz 2021.
* [Pre-recorded presentation](https://youtu.be/OPQaC-wVqDU)
* [Demo](https://youtu.be/z4ExuSLORJY)

Note that there is no `inventory/inventory.yml` file.  I create this dynamically
from my OpenStack demo environment. The basic idea is that you need to have 3
hosts, and pick one of them to be the logging, metrics, and NFS server.
Depending on how you deployed the machines, you might not need `ansible_host` if
your hosts like `host1.example.com` resolve both from the controller host and
the managed hosts.  `ansible_user` is some user created during node provisioning
time.  See the `demo-heat-template.yaml` for how I created this user and
specified the ssh key to use and the sudo setup for `ansible_become`.  I also
created the storage data volume using the `demo-heat-template.yaml` and got the
device name from the template output.  The `logging_domain` should be a domain
which matches all of the client hosts. One more thing - for the sake of sanity I
allowed all connections from all ports in my OpenStack cluster - see
`demo-heat-template.yaml` `demo_security_group` - depending on your provisioning
system, you may have to allow specified ports to be opened between your nodes. I
used `extra_setup.yml` to create the ethernet devices used for the `network`
role.

```yaml
all:
  hosts:
    host1.example.com:
      ansible_host: xxx.xxx.xxx.xxx
      ansible_ssh_common_args: -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
      ansible_user: demo
      ansible_become: true
    host2.example.com:
      ansible_host: xxx.xxx.xxx.xxx
      ansible_ssh_common_args: -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
      ansible_user: demo
      ansible_become: true
    host3.example.com:
      ansible_host: xxx.xxx.xxx.xxx
      ansible_ssh_common_args: -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
      ansible_user: demo
      ansible_become: true
  vars:
    metrics_server: host1.example.com
    logging_server: host1.example.com
    logging_domain: example.com
    vpn_connections:
      - hosts:
          host1.example.com:
            hostname: host1.example.com
          host2.example.com:
            hostname: host2.example.com
          host3.example.com:
            hostname: host3.example.com
        auto: start
        rekey: true
  children:
    logging_servers:
      hosts:
        host1.example.com:
    metrics_servers:
      hosts:
        host1.example.com:
      vars:
        metrics_monitored_hosts:
          - host2.example.com
          - host3.example.com
    nfs_servers:
      hosts:
        host1.example.com:
      vars:
        storage_data_volume: /dev/vdb
