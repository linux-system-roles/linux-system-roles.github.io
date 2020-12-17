---
layout: home
title: Home
---

The **Linux System Roles** are a set of Ansible Roles, also available as an
Ansible Collection, used to manage and configure common GNU/Linux operating
system components. Conceptually, the intent is to provide for the operating
system components an automation "API" that is consistent across multiple major
and minor releases. The roles are available in Ansible Galaxy at
[linux-system-roles](https://galaxy.ansible.com/linux-system-roles/).  If you
would prefer to use a collection instead of individual roles, see
[https://galaxy.ansible.com/fedora/linux_system_roles](https://galaxy.ansible.com/fedora/linux_system_roles)


## Consistent and abstract

A major objective is that a role will provide a consistent user interface to
provide settings to a given subsystem that is abstract from any particular
implementation.  For example, assigning an IP Address to a network interface
should be a generic concept separate from any particular implementations such
as init networking scripts, NetworkManager, or systemd-networkd.

Another part of the consistency is a set of [Best
Practices](https://github.com/oasis-roles/meta_standards/blob/master/README.md)
which role users and developers follow in order to maintain a consistent
behavior and interface for all of the roles.

## Utilize the subsystems' native libraries

Whenever possible, the modules for this effort will take advantage of the
native libraries and interfaces provided by the distribution, rather than
calling upon CLI commands.  Example libraries include dbus, libnm, and similar
interfaces which provide robust and strictly defined inputs.

## Currently supported distributions

- Fedora
- Red Hat Enterprise Linux (RHEL 6+)
- RHEL 6+ derivatives such as CentOS 6+

Note that some components are not available on EL6, and some are available
only on EL8/Fedora.  See the documentation for the individual roles.

## Collection
If you would prefer to use a collection instead of individual roles, see
https://galaxy.ansible.com/fedora/linux_system_roles

## Currently supported subsystems

- [email (postfix)](https://galaxy.ansible.com/linux-system-roles/postfix/)
- [kdump (kernel crash dump)](https://galaxy.ansible.com/linux-system-roles/kdump/)
- [network](https://galaxy.ansible.com/linux-system-roles/network/)
- [selinux](https://galaxy.ansible.com/linux-system-roles/selinux/)
- [timesync](https://galaxy.ansible.com/linux-system-roles/timesync/)
- [storage](https://galaxy.ansible.com/linux-system-roles/storage/)
- [tlog (terminal logging, session recording)](https://galaxy.ansible.com/linux-system-roles/tlog/)
- [logging](https://galaxy.ansible.com/linux-system-roles/logging/)
- [metrics](https://galaxy.ansible.com/linux-system-roles/metrics/)
- [nbde_server](https://galaxy.ansible.com/linux-system-roles/nbde_server/)
- [nbde_client](https://galaxy.ansible.com/linux-system-roles/nbde_client/)
- [certificate](https://galaxy.ansible.com/linux-system-roles/certificate/)
- [kernel_settings (sysctl, sysfs, etc.)](https://galaxy.ansible.com/linux-system-roles/kernel_settings/)

## Subsystems on the roadmap

- SSH server and client (for now we are using [ansible-sshd](https://github.com/willshersystems/ansible-sshd))
- [VPN (IPSec - libreswan)](https://github.com/linux-system-roles/vpn)
- [Crypto policy](https://github.com/linux-system-roles/crypto_policies/)
- [firewall](https://galaxy.ansible.com/linux-system-roles/firewall/)
- [Cockpit](https://github.com/linux-system-roles/cockpit)
- Cluster HA (pacemaker/corosync)
- AuditD
- Red Hat Subscription Management
- Kerberos authentication
- Bootloader
- [tuned (power management)](https://galaxy.ansible.com/linux-system-roles/tuned/)
