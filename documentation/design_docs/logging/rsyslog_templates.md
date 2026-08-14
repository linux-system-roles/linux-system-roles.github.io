---
layout: page
title: Rsyslog
---

## templates

### Sub-configuration files in rsyslog.d

The [rules.conf.j2](https://github.com/linux-system-roles/logging/blob/main/roles/rsyslog/templates/rules.conf.j2) is a template to generate
sub-configuration files based on the rules defined in the file.  Rsyslog configurations are implemented
as a combination of small pieces.

Each piece is defined in the logging role default yaml files as follows (a simple example):
```
- name: filename
  type: type
  options: |-
    configure_line0
    configure_line1
    .....
```

It is deployed to /etc/rsyslog.d/[0-9][0-9]-filename.conf, where [0-9][0-9] is determined with the type [1].  The "filename" is from the value of `name`.  By default, the suffix is `conf`.

[1] - rsyslog_weight_map:

<table class="documentation-table">
  <thead>
    <tr><th>type</th><th>value</th></tr>
  </thead>
  <tbody>
    <tr><td>global, globals</td><td>05</td></tr>
    <tr><td>module, modules</td><td>10</td></tr>
    <tr><td>template, templates</td><td>20</td></tr>
    <tr><td>output, outputs</td><td>30</td></tr>
    <tr><td>service, services</td><td>30</td></tr>
    <tr><td>rule, rules, ruleset, rulesets</td><td>50</td></tr>
    <tr><td>input, inputs</td><td>90</td></tr>
  </tbody>
</table>

The contents of the file:
```
configure_line0
configure_line1
.....
```

Further controls are available.
To change the file suffix to `system`:
```
- name: filename
  type: type
  suffix: 'system'
```
To change the preceding digits to 99:
```
- name: filename
  type: type
  weight: '99'
```
To use completely pre-determined filename:
```
- filename: 'fixed-filename.conf'
```
