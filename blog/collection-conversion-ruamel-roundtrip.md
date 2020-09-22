---
layout: page
title: "Conversion to Collection - YAML roundtrip with ruamel"
---
The System Roles team is working on making the roles available as a collection.
One of the challenges is that we have to continue to support the old style roles
for the foreseeable future due to customers using older versions of Ansible.
So rather than just create a github repository for the collection and do a
one-time conversion of all of the roles to collection format, we have decided to keep the existing
github role structure, and instead use a script to build the collection for
publishing in Galaxy.

## Using the `collections:` keyword

One strategy is to use the
[`collections:`](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html#using-collections-in-a-playbook)
keyword in the play.  For example:
```yaml
- name: Apply the kernel_settings role
  hosts: all
  roles:
    - kernel_settings
  tasks:
    - name: use the kernel_settings module
      kernel_settings:
        ...
```
To use this role from a collection `fedora.system_roles`, you could use the
`collections:` keyword:
```yaml
- name: Apply the kernel_settings role
  hosts: all
  collections:
    - fedora.system_roles
  roles:
    - kernel_settings
  tasks:
    - name: use the kernel_settings module
      kernel_settings:
        ...
```
However, the guidance we have received from the Ansible team is that we should
use FQRN (Fully Qualified Role Name) and FQCN (Fully Qualified Collection Name)
to avoid any naming collisions or ambiguity, and not to rely on the
`collections:` keyword.  This means we have a lot of conversion to do.  For Ansible YAML files, the two
main items are:
* convert references to role `ROLENAME` and `linux-system-roles.ROLENAME` to
  `fedora.system_roles.ROLENAME`
* convert references to modules to use the FQCN e.g. `some_module:` to
  `fedora.system_roles.some_module:`

## Using regular expressions to search/replace strings

One solution is to use a regular expression match - just look for references to
`linux-system-roles.ROLENAME` and convert them to
`fedora.system_roles.ROLENAME`.  This works pretty well, but there is no
guarantee that there is some odd use of `linux-system-roles.ROLENAME` not
related to a role keyword.  It would be much better and safer if we could only
change those places where the role name is used in the semantic context of an
Ansible role reference.  For modules, it is quite tricky to do this
search/replace using a regexp.  To complicate matters, in the `network` role,
the module name `network_connections` is also used as a role variable name.  I'm
not sure how one would write a regexp that could detect the semantic context and
only replace the string `network_connections` with
`fedora.system_roles.network_connections` in the context of usage as an Ansible
module.

## Using the Ansible parser

The next solution was to use the Ansible parser
(`ansible.parsing.dataloader.DataLoader`) to read in the files with the full
semantic information.  We took inspiration from the `ansible-lint` code for
this, and used similar heuristics to determine the file and node types:
* file location - files in the `vars/` and `defaults/` directories are not
  `tasks/` files
* Ansible type - a tasks file has type `AnsibleSequence` not `AnsibleMapping`
* node type - a `play` has one of the `play` keywords like `gather_facts`,
  `tasks`, etc.

For `task` nodes, we then use `ansible.parsing.mod_args.ModuleArgsParser` to
parse out the module name (as is done in `ansible-lint`).

For role references, we look for
* a `task` with a module `include_role` or `import_role` with a `name` parameter
* a `play` with a `roles` keyword
* a `meta` with a `dependencies` keyword

A role in a `roles` or `dependencies` may be referenced as
```
roles/dependencies:
  - ROLENAME
# OR
  - name: ROLENAME
    vars: ...
# OR
  - role: ROLENAME
    vars: ...
```
This allowed us to easily identify where the `ROLENAME` was referenced as a role
rather than something else, and to identify where the role modules were used.

The next problem - how to write out these converted files?  Just using a plain
YAML dump, even if nicely formatted, does not preserve all of our pre/post YAML
doc, comments, formatting, etc.  We thought it was important to keep this as
much as possible:
* keep license headers in files
* helps visually determine if the collection conversion was successful
* when bugs come from customers using the collection, we can much better debug
  and fix the source role if the line numbers and formatting match
* we'll use this code when we eventually convert our repos in github to use the collection
  format

## Using Ansible and ruamel

The `ruamel.yaml` package has the ability to "round-trip" YAML files, preserving
comments, quoting, formatting, etc.  We borrowed another technique from
`ansible-lint` which parses and iterates Ansible files using both the Ansible
parser and the ruamel parser "in parallel" (`ansible-lint` is also comment
aware).  This is an excerpt from the role file parser class:
```python
    def __init__(self, filepath, rolename):
        self.filepath = filepath
        dl = DataLoader()
        self.ans_data = dl.load_from_file(filepath)
        if self.ans_data is None:
            raise LSRException(f"file is empty {filepath}")
        self.file_type = get_file_type(self.ans_data)
        self.rolename = rolename
        self.ruamel_yaml = YAML(typ="rt")
        self.ruamel_yaml.default_flow_style = False
        self.ruamel_yaml.preserve_quotes = True
        self.ruamel_yaml.width = None
        buf = open(filepath).read()
        self.ruamel_data = self.ruamel_yaml.load(buf)
        self.ruamel_yaml.indent(mapping=2, sequence=4, offset=2)
        self.outputfile = None
        self.outputstream = sys.stdout
```
The class uses `ans_data` for looking at the data using Ansible semantics, and
uses `ruamel_data` for doing the modification and writing.
```python
    def run(self):
        if self.file_type == "vars":
            self.handle_vars(self.ans_data, self.ruamel_data)
        elif self.file_type == "meta":
            self.handle_meta(self.ans_data, self.ruamel_data)
        else:
            for a_item, ru_item in zip(self.ans_data, self.ruamel_data):
                self.handle_item(a_item, ru_item)

    def write(self):
        def xform(thing):
            if self.file_type == "tasks":
                thing = re.sub(LSRFileTransformerBase.INDENT_RE, "", thing)
            return thing
        if self.outputfile:
            outstrm = open(self.outputfile, "w")
        else:
            outstrm = self.outputstream
        self.ruamel_yaml.dump(self.ruamel_data, outstrm, transform=xform)

    def handle_item(self, a_item, ru_item):
        """handle any type of item - call the appropriate handlers"""
        ans_type = get_item_type(a_item)
        self.handle_vars(a_item, ru_item)
        self.handle_other(a_item, ru_item)
        if ans_type == "task":
            self.handle_task(a_item, ru_item)
        self.handle_task_list(a_item, ru_item)

    def handle_task_list(self, a_item, ru_item):
        """item has one or more fields which hold a list of Task objects"""
        for kw in TASK_LIST_KWS:
            if kw in a_item:
                for a_task, ru_task in zip(a_item[kw], ru_item[kw]):
                    self.handle_item(a_task, ru_task)
```
The concrete class that uses this code provides callbacks for tasks, vars, meta,
and other, and the callback can change the data.  `a_task` is the `task` node
from the Ansible parser, and `ru_task` is the `task` node from the ruamel
parser.  `role_modules` is a `set` of names of the modules provided by the role.
`prefix` is e.g. `fedora.system_roles.`
```python
    def task_cb(self, a_task, ru_task, module_name, module_args, delegate_to):
        if module_name == "include_role" or module_name == "import_role":
            rolename = ru_task[module_name]["name"]
            lsr_rolename = "linux-system-roles." + self.rolename
            if rolename == self.rolename or rolename == lsr_rolename:
                ru_task[module_name]["name"] = prefix + self.rolename
        elif module_name in role_modules:
            # assumes ru_task is an orderreddict
            idx = tuple(ru_task).index(module_name)
            val = ru_task.pop(module_name)
            ru_task.insert(idx, prefix + module_name, val)
```
This produces an output file that is very close to the input - but not quite.

## Problems with this approach

* We can't make ruamel do proper indentation of lists without having it do the
  indentation at the first level.  For example:

```yaml
- name: first level
  block:
    - name: second level
      something: something
```
comes out as
```yaml
  - name: first level
    block:
      - name: second level
        something: something
```
This is why we have the `xform` hack in the `write` method.

* Even with the hack, comments are not indented correctly

```yaml
- name: first level
  # comment here
  block:
    # comment here
    - name: second level
      something: something
```
comes out as
```yaml
  - name: first level
  # comment here
    block:
    # comment here
      - name: second level
        something: something
```
One approach would be to have `xform` skip the removal of the two extra spaces
at the beginning of the line if the first non-space character in the line is
`#`.  However, if you have `shell` scripts or embedded config files with
comments in them, these will then not be indented correctly, leading to
problems.  So for now, we just live with improperly indented Ansible comments.

* Line wrapping is not preserved

We use `yamllint` and have had to use some creative wrapping/folding to abide by
the line length restriction e.g.
```yaml
    - "{{ ansible_facts['distribution'] }}_\
        {{ ansible_facts['distribution_version'] }}.yml"
    - "{{ ansible_facts['distribution'] }}_\
        {{ ansible_facts['distribution_major_version'] }}.yml"
```
is converted to
```yaml
    - "{{ ansible_facts['distribution'] }}_{{ ansible_facts['distribution_version']\
        \ }}.yml"
    - "{{ ansible_facts['distribution'] }}_{{ ansible_facts['distribution_major_version']\
        \ }}.yml"
```
that is, ruamel imposes its own line length and wrapping convention.

We also didn't have to worry about how to handle usage of plugins inside of
`lookup` functions, which would seem to be a much more difficult problem.
