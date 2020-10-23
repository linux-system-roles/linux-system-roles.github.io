---
layout: page
title: VPN Role Interface Design
---
One of the big problems is - how will users provide the hosts and host specific
information in their Ansible inventory?

The variable `vpn_connections` is a list of tunnels.  Each tunnel specifies two
or more hosts.  The role creates tunnels between each pair of hosts, using a
common set of parameters (e.g. if using PSK they all share the same key).

The simplest case looks like this:
```yaml
all:
  hosts:
    bastion1.example.com: {...}
    bastion2.example.com: {...}
    bastion3.example.com: {...}
  vars:
    vpn_connections:
      - hosts:
          bastion1.example.com:
          bastion2.example.com:
          bastion3.example.com:
```
The role will set up a vpn tunnel between each pair of hosts in the list, using
the default parameters, including generating keys as needed (depending on what
is the default secret type).  This assumes the names of the hosts under `hosts`
are the same as the names of the hosts used in the Ansible inventory, and that
you can use those names to configure the tunnels (i.e. they are real FQDNs that
resolve correctly).

The user may also provide other variables that should be applied to the
configuration for each tunnel:
```yaml
    vpn_connections:
      - name: vpn-tunnel-x
        shared_key: Vault!abc...
        sec_alg: AES-GCM
        auto: on-demand
        hosts:
          bastion1.example.com:
          bastion2.example.com:
          bastion3.example.com:
```
There may be cases where the names of the hosts in the inventory are not FQDN
hostnames that you can use directly (e.g. they may be host aliases like
bastion_east).  There are a couple of ways to handle this case:

Use the Ansible `hosts` configuration:
```yaml
all:
  hosts:
    bastion_east:
      ansible_host: bastion1.example.com
      vpn_hostid: '@bastion-east'
    bastion_west:
      ansible_host: bastion2.example.com
      vpn_hostid: '@bastion-west'
    bastion_north:
      ansible_host: bastion3.example.com
      vpn_hostid: '@bastion-north'
  vars:
    vpn_connections:
      - hosts:
          bastion_east:
          bastion_west:
          bastion_north:
```
The role would lookup the value of the host to use from
`hostvars[hostname].ansible_host`.  You can specify other variables which are
always associated with a particular host, like `vpn_hostid`, in the host
configuration, which would be used for every connection where that host is
referenced.

You can also specify the host to use directly.  For example, in some cases, the
host/IP used by Ansible for SSH may not be the same as the host/IP for which you
want to set up a vpn connection:
```yaml
all:
  hosts:
    bastion_east:
      ansible_host: bastion1.example.com # the hostname that Ansible uses
      vpn_host: 192.168.122.101 # the IP address we want to use for the tunnel
    bastion_west:
      ansible_host: bastion2.example.com
      vpn_host: 192.168.122.102
    bastion_north:
      ansible_host: bastion3.example.com
  vars:
    vpn_connections:
      - hosts:
          bastion_east:
          bastion_west:
          bastion_north:
            vpn_host: 192.168.122.103
```
Note that users can provide the host specific parameters with either the host's
definition in the Ansible `all.hosts` section, or under each host in the `hosts`
list under `vpn_connections`.  This gives the admin flexibility in case they
cannot edit values in one or the other section.

There are a couple of use cases where you cannot use per-host settings in
`all.hosts`:
* The hosts are external to the inventory e.g. in a remote datacenter, and you can only set up the local ends of the tunnels.
```yaml
all:
  hosts:
    bastion_east:
      ansible_host: bastion1.example.com
    bastion_west:
      ansible_host: bastion2.example.com
  vars:
    vpn_connections:
      - hosts:
          bastion_east:
          bastion_west:
          bastion_north: # not in the hosts list
            vpn_host: 192.168.122.103
            external: true
```
The `external: true` means that we know `bastion_north` is not in the Ansible
inventory, so do not warn that this host is unknown.  Or perhaps we can assume
that if the host is not in the list, but sufficient parameters are specified,
the host is external, and do not warn.  We might also use `external: true` as a
hint that verification can fail if the remote end of the tunnel is not yet set
up.

* The hosts have multiple vpn tunnels associated with multiple NICs e.g. some OpenStack and OpenShift use cases:
```yaml
all:
  hosts:
    bastion_east: {...}
    bastion_west: {...}
    bastion_north: {...}
  vars:
    vpn_connections:
      - name: control_plane_vpn
        hosts:
          bastion_east:
            vpn_host: 192.168.122.101 # IP for control plane
          bastion_west:
            vpn_host: 192.168.122.102
          bastion_north:
            vpn_host: 192.168.122.103
      - name: data_plane_vpn
        hosts:
          bastion_east:
            vpn_host: 10.0.0.1 # IP for data plane
          bastion_west:
            vpn_host: 10.0.0.2
          bastion_north:
            vpn_host: 10.0.0.3
```
