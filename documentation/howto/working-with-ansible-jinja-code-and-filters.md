---
layout: page
title: Working with Ansible Jinja2 code and filters
---
When working with Ansible Jinja2 code and filters, it is helpful to write small
playbooks to test out functionality.  This is especially true if you are
developing a large role/playbook and want to try out a filter in one of the
tasks.  You do not want to have to run the entire playbook with a virtual
machine just to test one filter output in one task.

## Example playbook
Here is an example of such a playbook:
<!-- {% raw %} -->
```yaml
- name: Test to_nice_json
  hosts: localhost
  gather_facts: false
  vars:
    foo: bar
  tasks:
    - name: Show value of foo
      debug:
        msg: |
          foo is {{ foo | to_nice_json }}
```
<!-- {% endraw %} -->

Run this playbook like this:

```
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -vv debug.yml
```

I like to use `ANSIBLE_STDOUT_CALLBACK=debug` and filters like `to_nice_json`
because it really helps me see the structure of the data in a multi-line format
rather than in a single line JSON blob with escaped quotes and embedded
newlines.

## Example with nested dict data and map

Here is an example testing out a filter in a complex nested data structure -
given the `result` dict, I want to extract a list of `cidr_block` values:

<!-- {% raw %} -->
```yaml
- name: Test map and list
  hosts: localhost
  gather_facts: false
  vars:
    result:
      vpc:
        cidr_block_association_set:
          - id: block1
            cidr_block: 192.168.122.0/24
            cidr_block_state:
              state: present
          - id: block2
            cidr_block: 192.168.123.0/24
            cidr_block_state:
              state: disabled
  tasks:
    - name: Show cidr_block values
      debug:
        msg: blocks {{ result.vpc.cidr_block_association_set |
          map(attribute="cidr_block") | list | to_nice_json }}
```
<!-- {% endraw %} -->

and this is the output of the task:

<!-- {% raw %} -->
```
TASK [debug] *******************************************************************************
task path: /home/rmeggins/ansible_sandbox/vpc-test.yml:16
ok: [localhost] => {}

MSG:

blocks [
    "192.168.122.0/24",
    "192.168.123.0/24"
]
```
<!-- {% endraw %} -->

## Example that uses facts

Typically you will set `gather_facts: false` to speed up playbooks when you
don't need system facts.  Even fact gathering from localhost takes time.
However, if you do need to test some functionality that requires
`ansible_facts`, omit the `gather_facts: false`.

<!-- {% raw %} -->
```yaml
---
- name: Test with ansible_facts
  hosts: localhost
  tasks:
    - name: Set some facts
      set_fact:
        facts: "{{ ansible_facts }}"
        separators: ["-", "_"]
        versions:
          - "{{ ansible_facts['distribution_version'] }}"
          - "{{ ansible_facts['distribution_major_version'] }}"
    - name: Set more facts
      set_fact:
        varfiles: "{{ [facts['distribution']] | product(separators) |
          map('join') | product(versions | unique) | map('join') |
          list + [facts['distribution'], facts['os_family']] }}"
    - name: Show varfiles
      debug:
        msg: varfiles {{ varfiles | to_nice_json }}
```
<!-- {% endraw %} -->

Here is an example that parses `service_facts`:

<!-- {% raw %} -->
```yaml
---
- name: Parse service_facts
  hosts: localhost
  tasks:
    - name: service facts
      service_facts:
    - debug:
        msg: |
          service_facts {{ ansible_facts.services | to_nice_json }}
          again {{ ansible_facts.services | dict2items |
            selectattr('key', 'match', '^systemd-cryptsetup@') |
            map(attribute='value') | map(attribute='name') | list }}
```
<!-- {% endraw %} -->

## Using Different Jinja2 Versions

System Roles still has to support Ansible 2.9 and Jinja2 2.9 for EL7.  The
easiest way to test with this is to use a python `virtualenv`:

```bash
python -mvenv ~/.venv-ans29-jinja29
. ~/.venv-ans29-jinja29/bin/activate
pip install 'ansible==2.9.*' 'jinja2==2.7.*'
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -vv debug.yml
```
This will run your playbook with ansible 2.9 and jinja 2.7.

When you are done testing, type `deactivate` to "leave" the virtualenv.  For
more information about virtualenv see [python
venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment)

## Coding for multiple versions of Ansible and Jinja

In general, use the filters and tests provided by Ansible 2.9 wherever possible:
https://docs.ansible.com/ansible/2.9/user_guide/playbooks_templating.html

If you must use a Jinja2 feature (like `map` or `selectattr`), and you want to
make sure it works with Jinja 2.7, it is a bit tricky, because there are no
docs.  If you use the Jinja 2.10 and later docs at [Jinja2
docs](https://jinja.palletsprojects.com/en/2.11.x/templates/), you'll have to be
very careful because some of the features are not supported in jinja 2.7, and
you'll have to reference the code at
https://github.com/pallets/jinja/blob/2.7.3/jinja2/filters.py and https://github.com/pallets/jinja/blob/2.7.3/jinja2/tests.py to see if your
filter/test is supported.  Some notable differences:

* `namespace` is not available
* the tests `eq`, `equalto`, and `==` are not available

For `namespace`, you'll just have to figure out how to write your `for` loops in
such a way that they don't need `namespace`.

For the `eq` filter - it is quite common to want to write a filter expression
like this:

<!-- {% raw %} -->
```
{{ somelistofdicts | selectattr('someattr', '==', 'somevalue') | list }}
```
<!-- {% endraw %} -->

but that will not work in jinja 2.7 because the test `==` is not available.
Fortunately, ansible 2.9 provides the `match` test, so you can rewrite the above
like this:

<!-- {% raw %} -->
```
{{ somelistofdicts | selectattr('someattr', 'match', '^somevalue$') | list }}
```
<!-- {% endraw %} -->

which will work on all versions of ansible and jinja2.

## Complex Ansible/Jinja Data Manipulation

See [Manipulating data](https://docs.ansible.com/ansible/latest/playbook_guide/complex_data_manipulation.html)
for many examples of complex data parsing and manipulation.

## How to solve some common ansible-lint issues

### Line Wrapping

ansible-lint has a pretty short line length, which causes problems if you are
trying to use good programming practices by having descriptive variable names,
which usually end up being quite long.  On top of that, ansible-lint enforces
spacing in Jinja constructs and expressions.  Here are some examples of how to
deal with line wrapping in common scenarios:

#### Use the YAML `>-` flow scalars.

For example - instead of this:
```yaml
- name: This is a very, very, very, ........................... very long line
```
use this:
```yaml
- name: >-
    This is a very, very, very,
    ...........................
    very long line
```
The `>-` flow scalar operator will concatenate each line into a single line
string, with a single space character replacing the new line and leading spaces.

#### Jinja expressions can be wrapped

For example - instead of this:
<!-- {% raw %} -->
```yaml
  foo: "{{ a_very.long_variable.name | somefilter('with', 'many', 'arguments') | another_filter | list }}"
```
<!-- {% endraw %} -->
use the filter `|` as a natural line break:
<!-- {% raw %} -->
```yaml
  foo: "{{ a_very.long_variable.name |
    somefilter('with', 'many', 'arguments') |
    another_filter | list }}"
```
<!-- {% endraw %} -->
Remember, in a `when`, `that`, `failed_when`, or other such keywords, you can just
write Jinja code - you do not need the `"{{ ... }}"`:
```yaml
  when: a_very.long_variable.name |
    somefilter('with', 'many', 'arguments') |
    another_filter | list
```

But what if the code is already indented a lot, and the variable I'm assigning to
is already very long, and I can't put anything else on the line?  Just start the
assignment on the next line:
<!-- {% raw %} -->
```yaml
                    foo: "{{
                      a_very.long_variable.name |
                      somefilter('with', 'many', 'arguments') |
                      another_filter | list }}"
```
<!-- {% endraw %} -->
If you have to do the same thing in a `when`, `that`, etc., you can use a backslash:
```yaml
                    foo: \
                      a_very.long_variable.name |
                      somefilter('with', 'many', 'arguments') |
                      another_filter | list
```

#### Use `vars` for locally scoped intermediate values

But what if my variable name is very long, and/or I use it in several places?
Use a `vars` in the task to assign a locally scoped variable with a short name,
or pre-digest some of the work:
<!-- {% raw %} -->
```yaml
- name: Set some test variables
  set_fact:
    my_very_long_variable_1: "{{ a_very.long_variable.name | some_filter | filter1 }}"
    my_very_long_variable_2: "{{ a_very.long_variable.name | some_filter | filter2 }}"
```
<!-- {% endraw %} -->
Notice that both assignments have `a_very.long_variable.name | some_filter` in
common, so we can "pre-digest" that with a local variable:
<!-- {% raw %} -->
```yaml
- name: Set some test variables
  set_fact:
    my_very_long_variable_1: "{{ __pre_digest | filter1 }}"
    my_very_long_variable_2: "{{ __pre_digest | filter2 }}"
  vars:
    __pre_digest: "{{ a_very.long_variable.name | some_filter }}"
```
<!-- {% endraw %} -->
You can use a `vars` on *any* task - even `include_role`, `include_tasks`, etc.
You can also use `vars` in a `block` to create variables used by multiple tasks
in the `block` that are locally scoped to the `block`.

#### Use backslash escapes in double quoted strings

But what if I have a very long string that I cannot use `>-` to wrap because I
cannot have extra spaces in the value e.g. like a url value?
<!-- {% raw %} -->
```yaml
  uri:
    url: "https://{{ my_very_long_value_for_hostname }}:{{ my_very_long_value_for_port }}{{ my_very_long_value_for_uri }}{{ my_very_long_value_for_query }}"
```
<!-- {% endraw %} -->
You can use a backslash escape in a double quoted string:
<!-- {% raw %} -->
```yaml
  uri:
    url: "https://{{ my_very_long_value_for_hostname }}:\
      {{ my_very_long_value_for_port }}\
      {{ my_very_long_value_for_uri }}?\
      {{ my_very_long_value_for_query }}"
```
<!-- {% endraw %} -->
yaml will concatenate the values with no spaces:
`https://myhost:myport/myuri?myquery`

## References

* [Ansible 2.9 Filters, Tests, Jinja Templating](https://docs.ansible.com/ansible/2.9/user_guide/playbooks_templating.html)
* [Jinja 2.11 Docs](https://jinja.palletsprojects.com/en/2.11.x/templates/)
* [Jinja 2.7 Code - filters](https://github.com/pallets/jinja/blob/2.7.3/jinja2/filters.py)
* [Jinja 2.7 Code - tests](https://github.com/pallets/jinja/blob/2.7.3/jinja2/tests.py)
* [Rich's Ansible Sandbox](https://github.com/richm/ansible_sandbox)
* [Strings in YAML - To Quote or not to Quote](https://blogs.perl.org/users/tinita/2018/03/strings-in-yaml---to-quote-or-not-to-quote.html)
