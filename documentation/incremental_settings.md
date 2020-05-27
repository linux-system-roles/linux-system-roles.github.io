# Incremental Settings for Ansible Values

Many existing Ansible modules allow for *incrementally* changing the state of
the system or of the underlying managed object.  For example, when you use the
`sysctl` module, you do not provide every single `sysctl` setting describing
the entire state of the kernel settings.  Instead, you provide a single
setting which *incrementally* updates the state of all of the `sysctl`
settings, by adding, modifying, or removing a single value.
```yaml
- name: modify a single kernel setting
  sysctl:
    name: some_setting
    value: 123  # to add/replace the value
```
or
```yaml
- name: modify a single kernel setting
  sysctl:
    name: some_setting
    state: absent  # to remove the value
```
Many roles in the System Roles project need to follow the usual pattern of
module interfaces and allow specifying incremental changes instead of the
complete state to be able to be safely used multiple times in a playbook
without the later invocation clobbering the result of the previous invocation,
and to preserve previous state of the managed systems.  We had a need to
generalize the usual approach of modules to lists of settings for role
parameters.  We based our approach on
[Kubernetes JSON strategic merge](https://stupefied-goodall-e282f7.netlify.app/contributors/devel/strategic-merge-patch/),
and reuse of the Ansible `state` keyword.  We use this to manage objects which
are represented by a `list` of `dict` objects.

## Removing list items with `state: absent`

This is the case where you want to remove some of the values from the managed
object. Use `state: absent` in the `dict` value to remove the item named by
`name`. For example, if you are using `widget_manager` to manage a list of
widgets:
```yaml
widget_manager:
  - name: widget_a
    value: 111
  - name: widget_b
    state: absent
  - name: widget_c
    state: absent
```
This will change the state of widget `widget_a` to have the value of `111`,
and will remove widgets `widget_b` and `widget_c` from being managed by the
managed object.  NOTE: the behavior of `state: absent` depends on what the
underlying implementation is actually doing.  If a widget is a physical
object in the system, this might mean that the implementation will remove the
object (like the `file` module will remove the file with `state: absent`).
This might mean that the implementation will remove the specified object from
the list of objects being managed (like the `sysctl` module, which will remove
the parameter from the `/etc/sysctl.conf` file, but the actual value of the
parameter will not revert to its original value until after a reboot).

## Replacing an entire list of items with the given values with `previous: replaced`

This is the case where you want to remove all of the existing values in the
managed object and replace those values with the given values.  Use
`previous: replaced` as one of the items in the list of values (preferably
the first value in the list).  For example, using `widget_manager` parameters:
```yaml
widget_manager:
  - previous: replaced
  - name: widget_a
    value: 785592
  - name: widget_b
    value: 111111
  - name: widget_c
    value: 222222
```
This will remove any existing settings and replace them with the settings given.

## Removing all of the settings with `state: empty`

This is the case where you want to remove all of the existing values in the
managed object.  For example, if you want to remove all of the
`widget_manager` parameters:
```yaml
widget_manager:
  state: empty
```
This will remove all of the `widget_manager` parameters.  NOTE: This does
exactly the same thing as `- previous: replaced`, but is a shorter, more
readable version.  That is, using `state: empty` as above is equivalent to
this:
```yaml
widget_manager:
  - previous: replaced
```
