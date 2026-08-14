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

## Benefits of System Roles

### Consistent and abstract

A major objective is that a role will provide a consistent user interface to
provide settings to a given subsystem that is abstract from any particular
implementation.  For example, assigning an IP Address to a network interface
should be a generic concept separate from any particular implementations such
as init networking scripts, NetworkManager, or systemd-networkd.

Another part of the consistency is a set of [Good
Practices](https://github.com/redhat-cop/automation-good-practices)
which role users and developers follow in order to maintain a consistent
behavior and interface for all of the roles.

### Utilize the subsystems' native libraries

Whenever possible, the modules for this effort will take advantage of the
native libraries and interfaces provided by the distribution, rather than
calling upon CLI commands.  Example libraries include dbus, libnm, and similar
interfaces which provide robust and strictly defined inputs.

### Designed in conjunction with subsystem maintainers

Each role handles subsystem best practices, corner cases, new features.
In many cases, the role for a particular subsystem is designed by the maintainer
of that subsystem.  For example, the network system role was designed by the
team that maintains NetworkManager and nmstate.

### Hides RHEL major and minor version differences

You can use the same inventory and playbook to manage a mix of multiple
different RHEL major and minor versions. Many subsystems have major version
differences, and some have minor version differences (e.g. fapolicyd).  The role
hides and manages those differences for you.

### Can manage a list of settings

Most roles can take a list of settings, so no need for looping in the playbook.
You can define the list of settings in the inventory, the role takes care of
applying those settings idempotently.  In most cases, the playbook is just a
list of roles to invoke - no further logic is needed.

### Aids in upgrade

After you upgrade your managed node to the next major version of the OS, you can
keep using the same playbook and inventory to manage that node.  Fewer changes,
fewer errors, less QE.

### Extensively tested

The roles collectively have over 600 integration tests, many unit tests, which
are included with the roles, and tested across many different OS and Ansible
versions, as well as multiple versions of `ansible-lint` and `ansible-test`. The
integration tests are Ansible playbooks, and are a great resource for learning
how to use the roles, in addition to the examples.

### Roles are composable

Internally, some roles which provide a network service use the **certificate**
role for the TLS cert/key, the **firewall** role for managing the firewall
ports, and the **selinux** role for managing port policy, so the user does not
have to manage these separately. Externally, users can chain multiple roles in a
single playbook for complete end-to-end scenarios - for example, combining the
**certificate**, **firewall**, and **cockpit** roles to deploy the RHEL web
console with trusted certificates in one run.

### Other features

* Consistent API/naming across multiple roles - For example, a variable with a
  `_cert` suffix means the same thing in all roles.
* Can manage immutable systems (ostree).
* Works with explicit fact gathering - each role knows how to gather facts
  needed by the role.  You can use the roles with `ANSIBLE_GATHERING=explicit`.
* Handles lifecycle management beyond initial setup - roles support ongoing
  operations such as encryption key rotation, certificate renewal, snapshot
  revert, and configuration updates, not just first-time provisioning.
* Handle reboot orchestration - several roles detect when changes require a
  reboot and can handle the reboot sequence automatically, or report the need if
  not permitted.

## Supported distributions

- Fedora
- Red Hat Enterprise Linux (RHEL 6+)
- CentOS and CentOS Stream
- openSUSE and SUSE Linux Enterprise (SLE SP6+)

**Note:**

- Some components are not available on EL6, and some are available only on EL8+/Fedora.
- Support for SUSE and openSUSE is in progress and currently limited to a subset of roles.
- Refer to the documentation of each role to verify compatibility across distributions.

## Supported roles

<table class="documentation-table">
  <thead>
  <tr>
    <th>Role Name</th>
    <th>Description</th>
    <th>Ansible Galaxy</th>
    <th>GitHub Repository</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <td>ad_integration</td>
    <td>Active Directory join</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/ad_integration/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/ad_integration">linux-system-roles/ad_integration</a></td>
  </tr>
  <tr>
    <td>aide</td>
    <td>Advanced Intrusion Detection Environment (file integrity monitoring)</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/aide/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/aide">linux-system-roles/aide</a></td>
  </tr>
  <tr>
    <td>auditd</td>
    <td>Linux audit daemon</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/auditd/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/auditd">linux-system-roles/auditd</a></td>
  </tr>
  <tr>
    <td>bootloader</td>
    <td>Boot loader configuration</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/bootloader/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/bootloader">linux-system-roles/bootloader</a></td>
  </tr>
  <tr>
    <td>certificate</td>
    <td>Certificate management</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/certificate/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/certificate">linux-system-roles/certificate</a></td>
  </tr>
  <tr>
    <td>cockpit</td>
    <td>Cockpit web console</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/cockpit/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/cockpit">linux-system-roles/cockpit</a></td>
  </tr>
  <tr>
    <td>crypto_policies</td>
    <td>Crypto policies</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/crypto_policies/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/crypto_policies">linux-system-roles/crypto_policies</a></td>
  </tr>
  <tr>
    <td>fapolicyd</td>
    <td>File access policy daemon</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/fapolicyd/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/fapolicyd">linux-system-roles/fapolicyd</a></td>
  </tr>
  <tr>
    <td>firewall</td>
    <td>Firewall configuration</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/firewall/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/firewall">linux-system-roles/firewall</a></td>
  </tr>
  <tr>
    <td>gfs2</td>
    <td>GFS2 clustered file system</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/gfs2/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/gfs2">linux-system-roles/gfs2</a></td>
  </tr>
  <tr>
    <td>ha_cluster</td>
    <td>Cluster HA (Pacemaker/Corosync)</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/ha_cluster/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/ha_cluster">linux-system-roles/ha_cluster</a></td>
  </tr>
  <tr>
    <td>hpc</td>
    <td>High performance computing</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/hpc/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/hpc">linux-system-roles/hpc</a></td>
  </tr>
  <tr>
    <td>journald</td>
    <td>Systemd journald</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/journald/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/journald">linux-system-roles/journald</a></td>
  </tr>
  <tr>
    <td>kernel_settings</td>
    <td>Kernel settings (sysctl, sysfs, etc.)</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/kernel_settings/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/kernel_settings">linux-system-roles/kernel_settings</a></td>
  </tr>
  <tr>
    <td>keylime_server</td>
    <td>Keylime remote attestation server</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/keylime_server/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/keylime_server">linux-system-roles/keylime_server</a></td>
  </tr>
  <tr>
    <td>kdump</td>
    <td>Kernel crash dump</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/kdump/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/kdump">linux-system-roles/kdump</a></td>
  </tr>
  <tr>
    <td>logging</td>
    <td>System logging (rsyslog)</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/logging/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/logging">linux-system-roles/logging</a></td>
  </tr>
  <tr>
    <td>metrics</td>
    <td>Metrics collection - PCP, Grafana, Valkey, Elasticsearch, and more</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/metrics/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/metrics">linux-system-roles/metrics</a></td>
  </tr>
  <tr>
    <td>mssql</td>
    <td>Microsoft SQL Server</td>
    <td><a href="https://galaxy.ansible.com/ui/repo/published/microsoft/sql/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/mssql">linux-system-roles/mssql</a></td>
  </tr>
  <tr>
    <td>nbde_client</td>
    <td>Network-bound disk encryption client</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/nbde_client/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/nbde_client">linux-system-roles/nbde_client</a></td>
  </tr>
  <tr>
    <td>nbde_server</td>
    <td>Network-bound disk encryption server</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/nbde_server/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/nbde_server">linux-system-roles/nbde_server</a></td>
  </tr>
  <tr>
    <td>network</td>
    <td>Network configuration - NetworkManager, nmstate, ifcfg</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/network/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/network">linux-system-roles/network</a></td>
  </tr>
  <tr>
    <td>pam_pwd</td>
    <td>PAM password quality and configuration</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/pam_pwd/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/pam_pwd">linux-system-roles/pam_pwd</a></td>
  </tr>
  <tr>
    <td>podman</td>
    <td>Podman containers - Quadlets, Kube specs, Secrets, registries, storage, credentials</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/podman/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/podman">linux-system-roles/podman</a></td>
  </tr>
  <tr>
    <td>postfix</td>
    <td>Postfix email server</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/postfix/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/postfix">linux-system-roles/postfix</a></td>
  </tr>
  <tr>
    <td>postgresql</td>
    <td>PostgreSQL</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/postgresql/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/postgresql">linux-system-roles/postgresql</a></td>
  </tr>
  <tr>
    <td>rhc</td>
    <td>Red Hat Subscription Management and Insights</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/rhc/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/rhc">linux-system-roles/rhc</a></td>
  </tr>
  <tr>
    <td>selinux</td>
    <td>SELinux configuration</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/selinux/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/selinux">linux-system-roles/selinux</a></td>
  </tr>
  <tr>
    <td>snapshot</td>
    <td>LVM snapshot management</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/snapshot/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/snapshot">linux-system-roles/snapshot</a></td>
  </tr>
  <tr>
    <td>ssh</td>
    <td>SSH client</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/ssh/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/ssh">linux-system-roles/ssh</a></td>
  </tr>
  <tr>
    <td>sshd</td>
    <td>SSH server</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/willshersystems/sshd/">Galaxy</a></td>
    <td><a href="https://github.com/willshersystems/ansible-sshd">willshersystems/ansible-sshd</a></td>
  </tr>
  <tr>
    <td>storage</td>
    <td>Storage management - LVM, RAID, LUKS, pools, volumes, and more</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/storage/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/storage">linux-system-roles/storage</a></td>
  </tr>
  <tr>
    <td>sudo</td>
    <td>Sudo configuration - manage sudoers file</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/sudo/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/sudo">linux-system-roles/sudo</a></td>
  </tr>
  <tr>
    <td>systemd</td>
    <td>Systemd unit management - system and user units</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/systemd/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/systemd">linux-system-roles/systemd</a></td>
  </tr>
  <tr>
    <td>timesync</td>
    <td>Time synchronization - chrony, ntp</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/timesync/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/timesync">linux-system-roles/timesync</a></td>
  </tr>
  <tr>
    <td>tlog</td>
    <td>Terminal logging and session recording</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/tlog/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/tlog">linux-system-roles/tlog</a></td>
  </tr>
  <tr>
    <td>trustee_client</td>
    <td>Trustee client</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/trustee_client/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/trustee_client">linux-system-roles/trustee_client</a></td>
  </tr>
  <tr>
    <td>trustee_server</td>
    <td>Trustee server</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/trustee_server/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/trustee_server">linux-system-roles/trustee_server</a></td>
  </tr>
  <tr>
    <td>vpn</td>
    <td>VPN (IPSec with Libreswan)</td>
    <td><a href="https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/vpn/">Galaxy</a></td>
    <td><a href="https://github.com/linux-system-roles/vpn">linux-system-roles/vpn</a></td>
  </tr>
  </tbody>
</table>

## Collection

If you would prefer to use a collection instead of individual roles, see
[Linux System Roles Collection](https://galaxy.ansible.com/ui/repo/published/fedora/linux_system_roles)

## Submit an Issue

If the issue is specific to a role, file an issue at the role repository - for example, [network issues](https://github.com/linux-system-roles/network/issues/new/choose)

If the issue is not specific to a role e.g. a general question, or a request to add a new role, use [General issues](https://github.com/linux-system-roles/linux-system-roles.github.io/issues/new)

## Demos

- [Demo home page](/demo/demo.html)
- [DevConf2020.cz](https://github.com/linux-system-roles/linux-system-roles.github.io/tree/master/demo/devconf-demo)
- [DevConf2021.cz](https://github.com/linux-system-roles/linux-system-roles.github.io/tree/master/demo/devconf2021-cz-demo/)

## Roles on the roadmap

- Kerberos authentication
- [tuned (power management)](https://github.com/linux-system-roles/tuned/)
