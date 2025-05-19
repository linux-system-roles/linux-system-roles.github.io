---
layout: home
title: Home
---

The **Linux System Roles** are a set of Ansible Roles, also available as an
Ansible Collection, used to manage and configure common GNU/Linux operating
system components. Conceptually, the intent is to provide for the operating
system components an automation "API" that is consistent across multiple major
and minor releases. The roles are available in Ansible Galaxy at
[linux-system-roles](https://galaxy.ansible.com/ui/standalone/namespaces/4114).  If you
would prefer to use a collection instead of individual roles, see
[fedora.linux_system_roles collection](https://galaxy.ansible.com/ui/repo/published/fedora/linux_system_roles)

## Consistent and abstract

A major objective is that a role will provide a consistent user interface to
provide settings to a given subsystem that is abstract from any particular
implementation.  For example, assigning an IP Address to a network interface
should be a generic concept separate from any particular implementations such
as init networking scripts, NetworkManager, or systemd-networkd.

Another part of the consistency is a set of [Good
Practices](https://github.com/redhat-cop/automation-good-practices)
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
- CentOS and CentOS Stream
- openSUSE and SUSE Linux Enterprise (SLE SP6+)

Note:

- Some components are not available on EL6, and some are available only on EL8+/Fedora.
- Support for SUSE and openSUSE is in progress and currently limited to a subset of roles.
- Refer to the documentation of each role to verify compatibility across distributions.

## Collection

If you would prefer to use a collection instead of individual roles, see
[Linux System Roles Collection](https://galaxy.ansible.com/ui/repo/published/fedora/linux_system_roles)

## Submit an Issue

If the issue is specific to a role, file an issue at the role repository - for example, [network issues](https://github.com/linux-system-roles/network/issues/new/choose)

If the issue is not specific to a role e.g. a general question, or a request to add a new role, use [General issues](https://github.com/linux-system-roles/linux-system-roles.github.io/issues/new)

## Demos

- [Demo home page](https://github.com/linux-system-roles/linux-system-roles.github.io/tree/master/demo)
- [DevConf2020.cz](https://github.com/linux-system-roles/linux-system-roles.github.io/tree/master/demo/devconf-demo)
- [DevConf2021.cz](https://github.com/linux-system-roles/linux-system-roles.github.io/tree/master/demo/devconf2021-cz-demo/)

## Currently supported subsystems

- [email (postfix)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/postfix/)
- [kdump (kernel crash dump)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/kdump/)
- [network](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/network/)
- [selinux](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/selinux/)
- [timesync](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/timesync/)
- [storage](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/storage/)
- [tlog (terminal logging, session recording)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/tlog/)
- [logging](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/logging/)
- [metrics](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/metrics/)
- [nbde_server](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/nbde_server/)
- [nbde_client](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/nbde_client/)
- [certificate](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/certificate/)
- [kernel_settings (sysctl, sysfs, etc.)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/kernel_settings/)
- SSH server (used in the collection) [ansible-sshd](https://github.com/willshersystems/ansible-sshd/)
- [SSH client](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/ssh/)
- [VPN (IPSec - libreswan)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/vpn/)
- [Microsoft SQL Server](https://galaxy.ansible.com/ui/repo/published/microsoft/sql/)
- [Crypto policies](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/crypto_policies/)
- [Cluster HA (pacemaker/corosync)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/ha_cluster/)
- [Cockpit](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/cockpit/)
- [firewall](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/firewall/)
- [Systemd journald](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/journald/)
- [Active Directory join](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/ad_integration/)
- [podman](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/podman)
- [Red Hat Subscription Management and Insights](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/rhc)
- [PostgreSQL](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/postgresql/)
- [keylime_server](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/keylime_server/)
- [fapolicyd](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/fapolicyd/)
- [snapshot (lvm)](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/snapshot/)
- [bootloader](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/bootloader/)
- [gfs2](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/gfs2/)
- [sudo](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/sudo/)

## Subsystems on the roadmap

- [pam_pwd](https://github.com/linux-system-roles/pam_pwd/)
- AuditD
- Kerberos authentication
- [tuned (power management)](https://github.com/linux-system-roles/tuned/)
