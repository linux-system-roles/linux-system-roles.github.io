---
layout: page
title: "How to Specify Roles Used by Other Roles"
---
# Intro

Many of our roles need to use the functionality provided by another role.

An example for the Logging role:
* When new certs need to be generated with deploying the logging system,
  integration with the certificate role. See also
  [Certificate README](https://github.com/linux-system-roles/certificate/blob/master/README.md)
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
using the other role.  The role must specify the other roles using the FQCN e.g.
```yaml
# logging/tasks/main.yml
  - name: Configure firewall
    include_role:
      name: fedora.linux_system_roles.firewall
    vars:
      firewall:
        - port: 9876
          state: enabled
```

# Dependencies/Requirements

The collections required at runtime will be specified in the
`meta/collection-requirements.yml` file, as are done for other collections.
```yaml
collections:
  - name: fedora.linux_system_roles
  - name: some.other_collection
```
and this will be documented in the README.  The `Requirements` text will need to
be changed for roles that already have some instructions about collections.  For
example:
```
Requirements

The role requires additional collections which are specified in `meta/collection-requirements.yml`.  These are not automatically installed.  You must install them like this:

`ansible-galaxy install -vv -r meta/collection-requirements.yml`
```
We will have to update any existing wording to be more generic like the above.

Collections required at test-time will be specified in
`tests/collection-requirements.yml`.  Users will typically not need to know
about this, but developers can use this with tox-lsr, the CI system, etc.

# Collections

We may have to add another option to the role2collection script to be able to
change references to used roles, when changing to a different namespace and/or
collection.  For example, in the above logging case, if we have this:

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

And we want to change all references of `fedora.linux_system_roles` to
`namespace.other_name`, we will need to tell the script how to do that.  The
role2collection script supports the `--extra-mapping` parameter, but I'm not
sure if it can be used for this case.

The role2collection script will need to ignore any references to its given
`namespace` and `collection` in the `meta/collection-requirements.yml`.  That
is, when it sees ` - name: fedora.linux_system_roles` it should ignore this.

# Tools/CI

We will need to add support for this to `tox-lsr`.  For example, if I am a
logging role developer, and I run a logging role test using `tox -e qemu ...`,
tox-lsr must ensure the certificate, selinux, and firewall roles are available.
It already handles installing collections from
`meta/collection-requirements.yml`, so there might not be much work to do there.

Developers should have the option to specify a local directory.  For example, if
I have all of the roles checked out under `$HOME/linux-system-roles`, I should
be able to use `$HOME/linux-system-roles/certificate` etc. when working on the
logging role (which is especially handy if I am working on both roles in
conjunction).  Maybe add a `--use-local-roles` option to runqemu?

We will need to add support for integration test CI.  The test will need to
install the collection dependencies.  It already does this, so we might not have
to change anything here.

# RPM/Packaging

This is related to `Collections` - we may need some parameter we can use to tell role2collection to convert `fedora.linux_system_roles.OTHER_ROLE` to `namespace.other_collection.OTHER_ROLE`.
