---
layout: home
title: Home
---

The **Linux System Roles** are a collection of roles and modules executed by
Ansible to assist Linux admins in the configuration of common GNU/Linux
subsystems. Conceptually, the intent is to serve as a consistent "API" to a
give Linux distribution that is consistent across multiple major and minor
releases. This collection is available in Ansible Galaxy at
[linux-system-roles](https://galaxy.ansible.com/linux-system-roles/).

## Consistent and abstract

A major objective is that the role will provide a consistent user interface to
provide settings to a given subsystem that is abstract from any particular
implementation.  For example, assigning an IP Address to a network interface
should be a generic concept separate from any particular implementations such
as init networking scripts, NetworkManager, or systemd-networkd.

## Utilize the subsystems' native libraries
Whenever possible, the modules for this effort will take advantage of the
native libraries and interfaces provided by the distribution, rather than
calling upon CLI commands.  Example libraries include dbus, libnm, and similar
interfaces which provide robust and strictly defined inputs.

## Currently supported distributions

- Fedora
- Red Hat Enterprise Linux (RHEL 6+)
- RHEL 6+ derivatives such as CentOS 6+

## Currently supported subsystems

- [email (postfix)](https://galaxy.ansible.com/linux-system-roles/postfix/)
- [kdump (kernel crash dump)](https://galaxy.ansible.com/linux-system-roles/kdump/)
- [network](https://galaxy.ansible.com/linux-system-roles/network/)
- [selinux](https://galaxy.ansible.com/linux-system-roles/selinux/)
- [timesync](https://galaxy.ansible.com/linux-system-roles/timesync/)

## Subsystems on the roadmap

- Red Hat Subscription Management
- [firewall](https://galaxy.ansible.com/linux-system-roles/firewall/)
- system logging
- [storage](https://galaxy.ansible.com/linux-system-roles/storage/)
- kerberos authentication
- bootloader
- [tuned (power management)](https://galaxy.ansible.com/linux-system-roles/tuned/)
