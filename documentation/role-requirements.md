---
layout: page
title: "How to Specify Roles Used by Other Roles"
---
# Intro

Many of our roles need to use the functionality provided by another role.

An example for the Logging role:
* When new certs need to be generated with deploying the logging system,
  integration with the certificate role. See also
  (Certificate README)[https://github.com/linux-system-roles/certificate/blob/master/README.md]
* A RELP connection may need to open a port in the firewall, and could use the
  firewall role.
* A RELP connection may need to set SELinux attributes for a port, and could use
  the selinux role.

There are many more candidates which could use the Certificate role, the Network
role, the Firewall role, etc.  Any role that needs an X509 cert could use the
certificate role.  Any role that needs to open a port could use the firewall and
selinux roles.

# Tasks

Roles will need to add tasks to enable/disable/add/remove the cert/port/whatever
using the other role.  The role must specify the other roles using the FQRN e.g.
```yaml
# logging/tasks/main.yml
  - name: Configure firewall
    include_role:
      name: linux-system-roles.firewall
    vars:
      firewall:
        - port: 9876
          state: enabled
```

# Dependencies/Requirements

The role will need some way to specify the dependencies on the other roles.
Unfortunately, we cannot use role dependencies in `meta/main.yml` as in
(Role Dependencies)[https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#using-role-dependencies].
The problem is that this not only *installs* the roles, but it also *executes*
the roles. There is no way to turn off execution and just use dependency
installation. In our roles we want to have the ability to call roles in-line
and/or dynamically using the `roles` keyword and using `include_role` and using
`import_role`. We need another mechanism, but there isn't another automatic
dependency mechanism. So, just like we had to do for roles having dependencies
on collections, and created our own `meta/collection-requirements.yml`, we
will use a file `meta/role-requirements.yml`.  It will be in the same format as
(requirements.yml)[https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-multiple-roles-from-a-file]
For example:

```yaml
# logging/meta/role-requirements.yml
roles:
  - name: linux-system-roles.firewall
```

with optional `src`, `version`, etc.

Since there is no automatic way to install these, we will need to document in
the README for each role that the user needs to manually install these from
Galaxy, as we did for the collection requirements (see
https://github.com/linux-system-roles/storage/#requirements)

For example:
```
Requirements

If the file `meta/role-requirements.yml` is present, install the role requirements using that file:

`ansible-galaxy install -vv -r meta/role-requirements.yml`
```

# Collections

The role2collection script will need to be able to change references to used
roles.  For example, in the above logging case, it will have to change it like
this:

```yaml
# roles/logging/tasks/main.yml
  - name: Configure firewall
    include_role:
      name: fedora.linux_system_roles.firewall
    vars:
      firewall:
        - port: 9876
          state: enabled
```

The role2collection script will also have to change the README, and anywhere
else external roles are referenced.  The role2collection script supports the
`--extra-mapping` parameter.  Maybe we could add something like
`--extra-mapping-from /path/to/meta/role-requirements.yml`.  The role2collection
script would read each role and convert each one like
`--extra-mapping org.rolename:namespace.collection.rolename`.

The role2collection script will not need to do anything with
`meta/role-requirements.yml` - it will not need to add these to the collection
`galaxy.yml` as dependencies.  Any dependencies on linux-system-roles roles will
be automatically satisfied by the collection, since the collection includes all
of them.  Any dependencies on external roles are avoided for now, and left to
some future developer to figure out.

# Tools/CI

We will need to add support for this to `tox-lsr`.  For example, if I am a
logging role developer, and I run a logging role test using `tox -e qemu ...`,
tox-lsr must ensure the certificate, selinux, and firewall roles are available,
using `role-requirements.yml`, similar to how it handles collection dependencies
https://github.com/linux-system-roles/tox-lsr/blob/main/src/tox_lsr/test_scripts/runqemu.py#L863

If testing the role by converting it to collection format first, the
dependencies will also need to be converted into the same collection.  For
example, if I use `tox -e collection`, and the role has dependencies on system
roles `roleA` and `roleB`, then the converted collection must have
`fedora.linux_system_roles.roleA` and `fedora.linux_system_roles.roleB`.

Developers should have the option to specify a local directory.  For example, if
I have all of the roles checked out under `$HOME/linux-system-roles`, I should
be able to use `$HOME/linux-system-roles/certificate` etc. when working on the
logging role (which is especially handy if I am working on both roles in
conjunction).  Perhaps we can add symlinks under `tests/roles/`, or the user can
specify something like `tox -e qemu ... --roles-path $HOME/linux-system-roles`
(but the latter would require that the developer has
`$HOME/linux-system-roles/linux-system-roles.certificate` i.e. the name of the
directory must be the FQRN).

We will need to add support for integration test CI.  The test will need to
install the roles using `role-requirements.yml`, similar to how we install
collection dependencies.

# RPM/Packaging

We may need to improve support for this in the RPM spec file.  For example, we
currently do a `sed` of all `linux-system-roles.` strings to `rhel-system-roles.`.
We need to ensure this works for the role references mentioned above.  We may
need to use a semantic scanner that understands the YAML structure/Ansible
syntax, similar to how the role2collection script works, if `sed` is not suitable.
