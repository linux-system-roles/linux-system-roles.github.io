---
layout: page
title: "Introduction to Ansible for Linux System Roles"
---

Linux System Roles are implemented using Ansible.

If you are not familiar with Ansible, please visit
["How Ansible works"](https://www.ansible.com/overview/how-ansible-works).
The documentation on the docs.ansible.com page has many good links
to get started. Red Hat also provides good readings on Ansible such as
["What is Ansible"](https://www.redhat.com/en/technologies/management/ansible/what-is-ansible) and
["Learning Ansible basics"](https://www.redhat.com/en/topics/automation/learning-ansible-tutorial).

This section provides a brief introduction to Ansible and how to use it.

## How to Run Ansible

Ensure that `ansible-core` is installed on the host where you are executing
`ansible-playbook`.
Note: If you are on RHEL 7, use `ansible` instead of `ansible-core`.

Here is a very simple playbook YAML file `playbook.yml` that executes
`echo hello world` on the `localhost` as a managed host:
```
---
- name: Simple playbook example
  hosts: localhost

  tasks:
    - name: Echo hello world
      command: echo "hello world"
```
To run the playbook, use the following command-line:
```
ansible-playbook -vv playbook.yml
```
In the output, you will see the task named "Echo hello world" and
a string "hello world" in the `stdout`, followed by the result that
the playbook was executed successfully `failed=0`.
```
TASK [Echo hello world] *****************************************************************
task path: /path/to/playbook.yml:6
changed: [localhost] => {"changed": true, "cmd": ["echo", "hello world"], "delta": "0:00:00.003655", "end": "2023-03-13 13:13:00.588067", "msg": "", "rc": 0, "start": "2023-03-13 13:13:00.584412", "stderr": "", "stderr_lines": [], "stdout": "hello world", "stdout_lines": ["hello world"]}
META: ran handlers
META: ran handlers

PLAY RECAP ******************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
For more details, visit this page:
["Ansible playbooks"](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)

## How to Create an Inventory

To run Ansible, you have to define the `managed nodes` on which you want to
install systems and configure them. The inventory or inventory file is used
for this purpose. In the above "Simple playbook example," the playbook is
executed on `localhost`, which is the same as the host where you run `
ansible-playbook`. The host is called a `control node`.

There are multiple ways to specify the `managed nodes`.
You can embed it in the playbook. Or you can specify it in the `ansible-playbook`
option directly or in the inventory file.
```
  -i INVENTORY, --inventory INVENTORY
          specify inventory host path or comma separated host list.
```
For more details about inventory, you can start here:
["How to build your inventory"](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)

## How to Create a Playbook

As presented in the "How to run Ansible" section, this Ansible documentation
["Ansible playbooks"](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
is a good place to start.

To use Linux System Roles from your playbook, you can include them in a legacy
style, as described in
["Roles"](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html),
for example,
```
- name: Manage logging on my systems
  hosts: all
  vars:
    logging_inputs: basic
  roles:
    - linux-system-roles.logging
```
or in the collection format, as described in
["Using collections in playbooks"](https://docs.ansible.com/ansible/latest/collections_guide/collections_using_playbooks.html#using-collections-in-playbooks),
for example,
```
- name: Manage logging on my systems
  hosts: all
  vars:
    logging_inputs: basic
  roles:
    - fedora.linux_system_roles.logging
```
The Linux System Roles support both styles.

## How to Use Vault

You may need to define parameters such as passwords and other secrets
in your playbook. Some of the Linux System Roles require such sensitive
parameters to configure them in the supported system.
If you use the `ansible-vault` tool included in the Ansible package,
they are encrypted and stored safely in your playbook.

The following command-line encrypts a secret value "my_secret_value"
using the vault password stored in /path/to/vault_pwd and stores the encrypted
secret in /path/to/vault-variables.txt:
```
ansible-vault encrypt_string --vault-password-file /path/to/vault_pwd \
my_secret_value --name my_secret_var_name > /path/to/vault-variables.txt
```

The generated /path/to/vault-variables.txt file looks like this:
```
my_secret_var_name: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          62393438633534323463643838313865386265363962313861303564383137653862363237323332
          <<snip>>
```
Instead of specifying the real secret value "my_secret_value", you can use
"my_secret_var_name" in your playbook as follows.
```
- name: Use the secret
  some_task:
    password: "{{ my_secret_var_name }}"
  ...
  no_log: true
```
Ansible will keep the value of "my_secret_var_name" encrypted until needed
(and use no_log: true to avoid leaking the value in the Ansible logs).

Then, run `ansible-playbook` as follows:
```
ANSIBLE_VAULT_PASSWORD_FILE=/path/to/vault_pwd ansible-playbook \
  --extra-vars=@/path/to/vault-variables.txt <<your_options>> your_playbook.yml
```
Please note that the vault variable file, vault-variables.txt, can have
the vault variables in either YAML or JSON format.

For more details, please read
["ansible-vault"](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html).
