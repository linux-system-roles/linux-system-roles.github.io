---
layout: page
title: Role Argument Specification for System Roles
---

## Role argument specification

NOTE: This document was created with assistance from ChatGPT using model 5.6
Sol Light.

This document describes the Role argument specification format for system roles that extends the Ansible
[role argument specification](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html#role-argument-spec)
with fields from the
[Ansible module DOCUMENTATION block](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_modules_documenting.html#documentation-block)
and the [Ansible module RETURN block](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_modules_documenting.html#return-block)
and with the `allowed_ranges`, `allowed_patterns`, and `additional_types`
fields described below.

A system role provides an argument specification in the standard `meta/argument_specs.yml`, but this format
is limited for the way system roles use arguments.  In addition, system roles can have "return values"
which are host-scoped variables set by the role.  For example, many system roles return
information about the system, or return a boolean variable to indicate that the user of the
role must reboot the system in order for the changes to be applied.  While these are not
the same as return values from an Ansible module, they serve much the same purpose.

The standard file `meta/argument_specs.yml` cannot be used for this, so in addition to this
file, system roles provide a file `meta/sr_argument_specs.yml` which uses the additions.

## Specification format

The document must contain a top-level `argument_specs` mapping. Each key in
that mapping names a role entry point. All field names are lowercase.  In addition
to the standard fields, the following fields are added.

### Additional option fields

The fields below may be used for every option, including suboptions declared
under `options` and type alternatives declared under `additional_types`.

#### `allowed_ranges`

An integer option's accepted range or ranges. The value is a string or a list
of strings. `MIN-MAX` denotes an inclusive range. An omitted bound denotes an
open-ended range, as in `1024-` or `-0`. When a list is supplied, satisfying any
range is sufficient. The field must not be empty and is valid only when `type`
is `int`.

Use `choices` instead when the accepted integers form a small, finite set.

#### `allowed_patterns`

A regular expression or list of regular expressions accepted for an option of
type `str` or `path`. When a list is supplied, matching any expression is
sufficient. Each expression applies to the entire value; authors should use
explicit `^` and `$` anchors to make that intention portable. The field must not
be empty and is invalid for other types.

Use `choices` instead when the accepted strings form a small, finite set.

#### `additional_types`

A list of mappings that describe alternative accepted types. Each mapping
accepts the same fields as an option, including `options`, `allowed_ranges`,
`allowed_patterns`, and a nested `additional_types` list. The specification on
the parent option is tested first, followed by additional alternatives in
document order. A value is accepted when one complete alternative validates.

Fields that apply to the option as a whole, including `description`,
`version_added`, `aliases`, deprecation metadata, `required`, and `default`,
should normally be placed on the parent. The parent owns the default value, and
that value must validate against at least one alternative.

### Additional entry point fields

#### `return_values`

This is a `dict` in the same format as [Ansible module RETURN block](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_modules_documenting.html#return-block)
Each key is the name of a host-scoped variable that the role can set with `set_fact`.
Because `set_fact` is host-scoped, the value may differ when the role runs on multiple hosts.
The usual convention for the role is to prefix each one by the name of the role - for example `bootloader_facts`.
If this is omitted from the spec, the role has no return values.

## Sample specification

The following example demonstrates ranges, patterns, multiple types, nested
options, dependencies, aliases, deprecation metadata, and simple and nested
return values.

```yaml
# roles/my_service/meta/sr_argument_specs.yml
---
argument_specs:
  # roles/my_service/tasks/main.yml entry point
  main:
    short_description: Configure the example service
    description:
      - Configures listeners and backend servers for the example service.
      - Validates all role variables before applying the configuration.
    version_added: "1.0.0"
    author:
      - Linux System Roles contributors
    options:
      rolename_port:
        description:
          - TCP port on which the service listens.
        type: int
        required: false
        default: 443
        allowed_ranges: "1-65535"

      rolename_bind_address:
        description:
          - IPv4 address or DNS name on which the service listens.
        type: str
        required: true
        aliases:
          - rolename_listen_address
        allowed_patterns:
          - '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
          - '^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)*[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$'

      rolename_endpoint:
        description:
          - TCP port or Unix-domain socket used by a local client.
        type: int
        allowed_ranges: "1-65535"
        additional_types:
          - type: path
            allowed_patterns: '^/(?:[^/]+/)*[^/]+$'

      rolename_backends:
        description:
          - Backend server definitions.
        type: list
        elements: dict
        required: false
        default: []
        options:
          name:
            description:
              - Unique backend name.
            type: str
            required: true
            allowed_patterns: '^[a-z][a-z0-9_-]{0,62}$'

          protocol:
            description:
              - Transport protocol.
            type: str
            choices:
              - tcp
              - tls
            default: tcp

          address:
            description:
              - Backend IPv4 address or DNS name.
            type: str

          port:
            description:
              - Backend TCP port.
            type: int
            allowed_ranges: "1-65535"

          socket:
            description:
              - Backend Unix-domain socket.
            type: path
            allowed_patterns: '^/.+$'

          tls_cert:
            description:
              - TLS certificate path.
            type: path

          tls_key:
            description:
              - TLS private-key path.
            type: path

        mutually_exclusive:
          - [address, socket]
        required_one_of:
          - [address, socket]
        required_together:
          - [tls_cert, tls_key]
        required_if:
          - [protocol, tls, [tls_cert, tls_key]]
        required_by:
          address:
            - port

      rolename_legacy_mode:
        description:
          - Deprecated compatibility mode.
        type: bool
        aliases:
          - rolename_compatibility_mode
          - rolename_old_compatibility_mode
        deprecated_aliases:
          - name: rolename_old_compatibility_mode
            version: "3.0.0"
            collection_name: example.service
        removed_in_version: "4.0.0"
        removed_from_collection: example.service

    return_values:
      rolename_reboot_required:
        description:
          - Whether the managed host must be rebooted for the changes to take effect.
        returned: always
        type: bool
        sample: false

      rolename_facts:
        description:
          - Information about the effective service configuration.
        returned: success
        type: dict
        version_added: "1.1.0"
        contains:
          enabled:
            description:
              - Whether the service is enabled to start at boot.
            returned: success
            type: bool
            sample: true

          listeners:
            description:
              - Effective service listeners.
            returned: success
            type: list
            elements: dict
            contains:
              address:
                description:
                  - Address on which the service listens.
                returned: success
                type: str
                sample: 192.0.2.10
              port:
                description:
                  - TCP port on which the service listens.
                returned: success
                type: int
                sample: 443

          backend_names:
            description:
              - Names of the configured backends.
            returned: success
            type: list
            elements: str
            sample:
              - primary
              - failover
```
