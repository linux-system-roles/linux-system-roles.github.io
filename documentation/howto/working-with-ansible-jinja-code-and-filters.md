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
- hosts: localhost
  gather_facts: false
  vars:
    foo: bar
  tasks:
    - debug:
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
- hosts: localhost
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
    - debug:
        msg: blocks {{ result.vpc.cidr_block_association_set | map(attribute="cidr_block") | list | to_nice_json }}
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
- hosts: localhost
  tasks:
    - set_fact:
        facts: "{{ ansible_facts }}"
        separators: [ "-", "_" ]
        versions: 
          - "{{ ansible_facts['distribution_version'] }}"
          - "{{ ansible_facts['distribution_major_version'] }}"
    - set_fact:
        varfiles: "{{ [facts['distribution']] | product(separators) |
          map('join') | product(versions|unique) | map('join') | list +
          [facts['distribution'], facts['os_family']] }}"
    - debug:
        msg: varfiles {{ varfiles | to_nice_json }}
```
<!-- {% endraw %} -->

Here is an example that parses `service_facts`:

<!-- {% raw %} -->
```yaml
---
- hosts: localhost
  tasks:
    - name: service facts
      service_facts:
    - debug:
        msg: |
          service_facts {{ ansible_facts.services | to_nice_json }}
          again {{ ansible_facts.services | dict2items | selectattr('key', 'match', '^systemd-cryptsetup@') | map(attribute='value') | map(attribute='name') | list }}
```
<!-- {% endraw %} -->

## Using Different Jinja2 Versions

System Roles still has to support Jinja2 2.7 for EL7.  The easiest way to test
with this is to use a python `virtualenv`:

```bash
python -mvenv ~/.venv-ans28-jinja27
. ~/.venv-ans28-jinja27/bin/activate
pip install 'ansible<2.9' 'jinja2<2.8' 'jmespath' 'netaddr'
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -vv debug.yml
```
This will run your playbook with ansible 2.8 and jinja 2.7.  `jmespath` is
required if you want to test using `json_query`.  `netaddr` is required in order
to use `ipaddr`.

When you are done testing, type `deactivate` to "leave" the virtualenv.  For
more information about virtualenv see [python
venv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment)

## Coding for multiple versions of Ansible and Jinja

In general, use the filters and tests provided by Ansible 2.8 wherever possible:
https://docs.ansible.com/ansible/2.8/user_guide/playbooks_templating.html

If you must use a Jinja2 feature (like `map` or `selectattr`), and you want to
make sure it works with Jinja 2.7, it is a bit tricky, because there are no
docs.  If you use the Jinja 2.10 and later docs at [Jinja2
docs](https://jinja.palletsprojects.com/en/2.11.x/templates/), you'll have to be
very careful because some of the features are not supported in jinja 2.7, and
you'll have to reference the code at
https://github.com/pallets/jinja/blob/2.7.3/jinja2/filters.py and https://github.com/pallets/jinja/blob/2.7.3/jinja2/tests.py to see if your
filter/test is supported.  Some notable differences:

* `namespace` is not available
* the filters `eq`, `equalto`, and `==` are not available

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
Fortunately, ansible 2.8 provides the `match` test, so you can rewrite the above
like this:

<!-- {% raw %} -->
```
{{ somelistofdicts | selectattr('someattr', 'match', '^somevalue$') | list }}
```
<!-- {% endraw %} -->

which will work on all versions of ansible and jinja2.

## References

* [Ansible 2.8 Filters, Tests, Jinja Templating](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_templating.html)
* [Jinja 2.11 Docs](https://jinja.palletsprojects.com/en/2.11.x/templates/)
* [Jinja 2.7 Code - filters](https://github.com/pallets/jinja/blob/2.7.3/jinja2/filters.py)
* [Jinja 2.7 Code - tests](https://github.com/pallets/jinja/blob/2.7.3/jinja2/tests.py)
* [Rich's Ansible Sandbox](https://github.com/richm/ansible_sandbox)
