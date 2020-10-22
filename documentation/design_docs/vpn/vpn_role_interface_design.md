---
layout: page
title: VPN Role Interface Design
---
One of the big problems is - how will users provide the hosts and host specific
information in their Ansible inventory?

Consider the following use cases:

* Host-to-Host (openstack): Specific nodes connecting to each other. Use IPsec
  for IP failover between these nodes (so all other nodes don't need to be aware
  of anything happening). Authentication Methods are FreeIPA certificates, and
  pre-shared keys. More information at (OpenStack IPSec
  docs)[https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/features/ipsec.html]
* Host-to-Host (data centers): Two systems in different data centers communicate
  encrypted with each other using FreeIPA certificates, pre-shared keys and rsa
  keys

In the general case, the user runs one or more playbooks to configure a large
group of machines using several different roles (e.g. storage, network, selinux,
firewall, apache, postgres, etc.), and the inventory specifies the hosts,
groups, and variables to apply globally, to specific groups, and to specific
hosts.

For example, here is an inventory that sets up dbservers and webservers:
```yaml
all:
  vars:
    a_global_var: value
  hosts:
    db1.example.com:
      a_host_specific_var: value
    db2.example.com:
    web1.example.com:
    web2.example.com:
  children:
    dbservers:  # name of group of db servers
      hosts:
        db1.example.com:
        db2.example.com:
      vars:
        a_group_var: value  # vars that apply to all hosts in the dbservers group
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
      vars:
        another_group_var: value
```
And I'll use a playbook like this:
```yaml
- hosts: dbservers
  roles:
    - linux-system-roles.network
    - linux-system-roles.storage
    - postgres.postgres
- hosts: webservers
  roles:
    - linux-system-roles.network
    - linux-system-roles.storage
    - apache.apache
```
Now, let's add two hosts called bastion1 and bastion2 that we want to setup vpn
between, using PSK.  Let's also assume that bastion1 is "local" - that is, we
have Ansible ssh access to it directly, but bastion2 is "remote" - that is, we
will have to configure it separately e.g. bastion2 is in a different data center
that will we have to somehow log into to set it up.
```yaml
all:
  vars:
    a_global_var: value
  hosts:
    db1.example.com:
      a_host_specific_var: value
    db2.example.com:
    web1.example.com:
    web2.example.com:
    bastion1.example.com:
      vpn_hostid: '@bastion1'
      vpn_shared_key: Vault!abc..  #  vault encrypted value
      vpn_connections:
        - name: bastion1-bastion2  #  name of conn in ipsec conf
          remote: bastion2.example.com
          remoteid: '@bastion2'
          shared_key: Vault!def..
  children:
    dbservers:  # name of group of db servers
      hosts:
        db1.example.com:
        db2.example.com:
      vars:
        a_group_var: value  # vars that apply to all hosts in the dbservers group
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
      vars:
        another_group_var: value
```
And I'll use a playbook like this:
```yaml
- hosts: dbservers
  roles:
    - linux-system-roles.network
    - linux-system-roles.storage
    - postgres.postgres
- hosts: webservers
  roles:
    - linux-system-roles.network
    - linux-system-roles.storage
    - apache.apache
- hosts: bastion1.example.com
  roles:
    - linux-system-roles.vpn
```
We will use a template for ipsec.conf like this (assuming we have some sort of
loop over all of the vpn_connections array values)
```
conn {{ vpn_connections[index].name }}
    left={{ inventory_hostname }}
    leftid={{ vpn_hostid }}
    right={{ vpn_connections[index].remote }}
    rightid={{ vpn_connections[index].remoteid }}
# and the shared key comes from vpn_connections[index].shared_key
```
expanded:
```
conn bastion1-bastion2
    left=bastion1.example.com
    leftid=@bastion1
    right=bastion2.example.com
    rightid=@bastion2
```
We would have to do something similar at the remote site, except we would swap
the values for local and remote.

If we want all of the vpn connections to use the same encryption algorithms,
auto behavior, etc. we can set them as global variables in the `all.vars`
section and refer to them as e.g. `ike={{ vpn_sec_alg }}` in the ipsec conf
file.

The benefit of this approach is that it is simple - there is one connection, and
you specify all of the necessary parameters.  The problem is that it doesn't
scale very well - if you have more than two hosts, representing it this way in
the inventory gets painful.

This approach can be slightly simplified if we assume all hosts are defined in
the inventory and can be managed by the same ansible playbook:
```yaml
all:
  hosts:
    bastion1.example.com:
      vpn_hostid: '@bastion1'
      vpn_shared_key: Vault!abc..  #  vault encrypted value
      vpn_connections:
        - name: bastion1-bastion2
          remote: bastion2.example.com
    bastion2.example.com:
      vpn_hostid: '@bastion2'
      vpn_shared_key: Vault!def..  #  vault encrypted value
      vpn_connections:
        - name: bastion2-bastion1
          remote: bastion1.example.com
        - name: bastion2-bastion3
          remote: bastion3.example.com
    bastion3.example.com:
      vpn_hostid: '@bastion3'
      vpn_shared_key: Vault!ghi..  #  vault encrypted value
      vpn_connections:
        - name: bastion3-bastion2
          remote: bastion2.example.com
  children:
    vpn:
      bastion1.example.com:
      bastion2.example.com:
      bastion3.example.com:
```
And I'll use a playbook like this:
```yaml
- hosts: vpn
  roles:
    - linux-system-roles.vpn
```
We can use `hostvars` to look up the parameters of the other hosts:
```
set remotehost = vpn_connections[index].remote  #  e.g. bastion2.example.com
set remotevars = hostvars[remotehost]
conn {{ vpn_connections[index].name }}
    left={{ inventory_hostname }}
    leftid={{ vpn_hostid }}
    right={{ remotehost }}
    rightid={{ remotevars.remoteid }}
# and the shared key comes from remotevars.shared_key
```
We could also define `vpn_connections` at the global level, but we would have to
add some sort of logic to the template so that it would skip setting up tunnels
to itself (e.g. when `inventory_hostname == remotehost`)

If we wanted to do a full mesh configuration, we would omit the
`vpn_connections`, and include the logic to skip setting up tunnels to itself.
```yaml
all:
  hosts:
    bastion1.example.com:
      vpn_hostid: '@bastion1'
      vpn_shared_key: Vault!abc..  #  vault encrypted value
    bastion2.example.com:
      vpn_hostid: '@bastion2'
      vpn_shared_key: Vault!def..  #  vault encrypted value
    bastion3.example.com:
      vpn_hostid: '@bastion3'
      vpn_shared_key: Vault!ghi..  #  vault encrypted value
  children:
    vpn:
      bastion1.example.com:
      bastion2.example.com:
      bastion3.example.com:
```
And I'll use a playbook like this:
```yaml
- hosts: vpn
  roles:
    - linux-system-roles.vpn
```
The vpn role would be called for each host in the group. The vpn role code would
loop over all hosts defined in the current play, excluding the current host, and
set up vpn tunnels to all of them:
```
for host in all_hosts | reject('==', inventory_hostname)
set remotevars = hostvars[host]
conn {{ construct name based on local and remote host properties }}
    left={{ inventory_hostname }}
    leftid={{ vpn_hostid }}
    right={{ host }}
    rightid={{ remotevars.remoteid }}
```
