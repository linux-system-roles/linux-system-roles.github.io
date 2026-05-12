---
layout: page
title: Contribute
---

## System Roles - Directories and Files

Each role repository is structured as an
[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html).
The linked document has more information:
* What is a role?
* What is the directory structure?
* What are the files used in the role?  The role must have the file
  `tasks/main.yml` which is the main entry point of the role.
* How to use a role, how to pass parameters to a role

NOTE: Not all system roles use all of these directories.  For example, roles
that do not provide modules will not have a `library/` or `module_utils/`
directory.

In addition to these, system roles use the following:
* `README.md` - The main role description and role usage documentation.  This
  should list the role requirements, dependencies, all of the role public API
  parameters, and examples of role usage.
* `examples/` - Example Ansible playbooks for different configurations.
* `meta/collection-requirements.yml` - External collections used by the role.
  Install these with `ansible-galaxy collection install -vv -r meta/collection-requirements.yml`
* `module_utils/$ROLENAME_lsr/` - Scripts providing functionality
  used by the modules in `library/`.  Note that every file in the `library/`
  directory is a distinct Ansible module, and you cannot have subdirectories in
  `library/`, so any additional files you want to use to logically organize the
  code, or provide common functionality for more than one module, must be in the
  `module_utils/$ROLENAME_lsr/` directory.
* `tests/` - Role unit tests, integration tests, and test helpers.
  * `tests/tests_*.yml` - Test playbooks
  * `tests/unit/` - Python unit tests for roles that provide Python code
  * `tests/tasks/` - Test helper code (e.g. common test setup, common verifications)
  * `tests/playbooks/` - In some roles, the `tests/tests_*.yml` playbooks are
    wrappers around the actual playbooks in `tests/playbooks/`
  * `tests/collection-requirements.yml` - External collections used by the role
    tests, not used at runtime. Install these with `ansible-galaxy collection
    install -vv -r tests/collection-requirements.yml`

## Using tox and tox-lsr

All checks and tests can be run with
[tox](https://tox.readthedocs.io/en/latest/).  You will typically install this
using your platform packages e.g. `dnf install python3-tox`.  You can also
install this using `pip` e.g. `pip install tox --user` (and you will need to
install `pip` using your platform packages e.g. `dnf install python3-pip`).

We use a special linux-system-roles tox plugin called
[tox-lsr](https://github.com/linux-system-roles/tox-lsr) which provides all of
the linters, unit test runners, qemu/kvm test runners, etc.  See the
[README.md](https://github.com/linux-system-roles/tox-lsr/blob/main/README.md)
for information about how to install and use this plugin.

After making changes, you should run `tox` to check that your changes conform to
project coding standards.  Otherwise, your pull request will likely fail one or more CI tests.

You can run individual tests e.g. `tox -e ansible-lint`

## Running tests with tox-lsr and qemu

You can run the test playbooks in `tests/tests_*.yml` with `tox` and `tox-lsr`
using qemu/kvm.

* Install `tox` and `tox-lsr` (see above)
* Use yum or dnf to install `standard-test-roles-inventory-qemu`
* Download the config file to `~/.config/linux-system-roles.json` from [here](https://raw.githubusercontent.com/linux-system-roles/linux-system-roles.github.io/master/download/linux-system-roles.json)

NOTE: linux-system-roles.json has support for `extra_images_file` - if you have additional images defined in
another file, copy that file to `~/.config/extra-images.json`.

Assuming you are in a git clone of a role repo which has a `tox.ini` file - you can use e.g.

```
tox -e qemu-ansible-core-2-20 -- --image-name centos-9 tests/tests_default.yml
```

NOTE: This will download a qcow image to `~/.cache/linux-system-roles`. The
first time you do this it will take a while, and it will appear that `tox` is
not doing anything.  Check the contents of the cache directory to see the file
download progress.  For subsequent runs, `tox` will check if the qcow image is
up-to-date, and will automatically download a new image if the current image is
not up-to-date.

There are many command line options and environment variables which can be used to control the behavior, and you can customize the testenv in tox.ini.  See its [documentation](https://github.com/linux-system-roles/tox-lsr#qemu-testing) for details.

Running a qemu test will create a directory named `artifacts/` in the current
directory which may contain additional logs useful for debugging.

If you want to configure and run integration tests without using `tox`, use a cloud image like the
[CentOS 8.1
VM](https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2)
and execute the command and download the package
`standard-test-roles-inventory-qemu` from the Fedora repository:

`dnf install standard-test-roles-inventory-qemu`

Then `cd tests` to change to the `tests` subdirectory, and run the test playbook like this:
```
TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2
ansible-playbook -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2
tests_default.yml
```
Replace `tests_default.yml` with the actual test you want to run.

## Writing good Ansible code and tests

Please refer to [Recommended Practices](https://github.com/redhat-cop/automation-good-practices) for recommended practices to follow while making a contribution.

The following sections are a good place to start:

* [Naming Things](https://github.com/redhat-cop/automation-good-practices/blob/main/roles/README.adoc#naming-things)
* [Providers](https://github.com/redhat-cop/automation-good-practices/blob/main/roles/README.adoc#providers)
* [Supporting Multiple providers](https://github.com/redhat-cop/automation-good-practices/blob/main/roles/README.adoc#supporting-multiple-providers)
* [Check Mode and Idempotency Issues](https://github.com/redhat-cop/automation-good-practices/blob/main/roles/README.adoc#check-mode-and-idempotency-issues)
* [YAML and Jinja2 Syntax](https://github.com/redhat-cop/automation-good-practices/blob/main/coding_style/README.adoc#yaml-and-jinja2-syntax)
* [Ansible Best Practices](https://github.com/redhat-cop/automation-good-practices/blob/main/coding_style/README.adoc#ansible-guidelines)
* [Vars vs Defaults](https://github.com/redhat-cop/automation-good-practices/blob/main/roles/README.adoc#vars-vs-defaults)
* [Documentation conventions](https://github.com/redhat-cop/automation-good-practices/blob/main/roles/README.adoc#documentation-conventions)

## Writing Ansible code for System Roles

When writing Ansible code for System Roles, you must consider specific practices that we use for different purposes.
Some of the practices are included in the [template role](https://github.com/linux-system-roles/template) repository, so that you don't need to do anything.
But others should be included in the code, these are things that developers should know in advance.

Some of this code is managed centrally from the [linux-system-roles/.github](https://github.com/linux-system-roles/.github) repository.  Before editing a role file, check its header to see if it is managed.  If it is, and you need to change it, consider submitting a PR to the `.github` repository.

### Installing packages

Tasks should install packages with the `package` module.
This is required for roles to work on all operating systems because the package module has the logic to identify system's package manager.

The package module must use the `use` option to force the use of the `ansible.posix.rhel_rpm_ostree` module on OSTree systems.

It's a good practice to use a variable for the list of packages to be installed in different scenarios.
But this can be omitted, use common sense.

Example test file check_header.yml:

```yaml
- name: Install audit packages
  ansible.builtin.package:
    name: "{{ __auditd_packages }}"
    state: present
    use: "{{ (__auditd_is_ostree | d(false)) |
             ternary('ansible.posix.rhel_rpm_ostree', omit) }}"
```

The task to be included in a test playbook:

```yaml
- name: Check header for ansible_managed, fingerprint
  ansible.builtin.include_tasks: tasks/check_header.yml
  vars:
    __file: /etc/audit/auditd.conf
    __fingerprint: system_role:auditd
```

### Running Role in test playbooks

Each role has a centrally managed task file `tests/tasks/run_role_with_clear_facts.yml` that runs roles with clearing Ansible facts prior to invocation.
You must run roles by including this task file instead of the `include_role` and `import_role` modules, or instead of using the `roles` keyword.
This is required to ensure that roles gather all facts that they use, hence work fine with `ANSIBLE_GATHERING=explicit`.
For more information, see https://github.com/linux-system-roles/.github/pull/159.

Example:

```yaml
- name: Run auditd role again with identical purge and rules
  ansible.builtin.include_tasks: tasks/run_role_with_clear_facts.yml
  vars:
    auditd_start_service: false
    auditd_purge_rules: true
    auditd_manage_rules: true
    auditd_rules:
      - file: /etc/issue
        permissions:
          - read
        keyname: lsr_auditd_purge_test
```

### Writing templates

Jinja templates should contain an `ansible_managed` header at the top, and a role fingerprint to make it clear which role owns the generated file.

Example:

```yaml
{{ ansible_managed | comment }}
{{ "system_role:auditd" | comment(prefix="", postfix="") }}
```

In the case when the role generates a template, there should be a test task in one of the tests that checks whether `ansible_managed` and the fingerprint are present in the generated file.

Example:

```yaml
# SPDX-License-Identifier: MIT
---
- name: Get file
  slurp:
    path: "{{ __file }}"
  register: __content
  when: not __file_content is defined

- name: Check for presence of ansible managed header, fingerprint
  assert:
    that:
      - __ansible_managed in content
      - __fingerprint in content
  vars:
    content: "{{ (__file_content | d(__content)).content | b64decode }}"
    __ansible_managed: "{{ lookup('template', 'get_ansible_managed.j2') }}"
```

### Checking managed node distribution

Each role includes a file `tests/vars/rh_distros_vars.yml` that you can include in tests to set variables related to managed nodes distribution.

### Covering new functionality by tests and documentation

If your PR introduces new functionality to be used by users, you must describe it in README.md.

If your PR introduces new untested functionality, you should add tests for it.
This can be omitted if the functionality cannot be tested in our infrastructure.

### Defining role variables in the correct directory

Variables in `defaults/main.yml` are the variables that the role expects users to change.
They should be prefixed with `<role_name_>`.

Variables in the `vars` directory are internal to the role.
They should be prefixed with `__` to be marked as internal.
You should place variables that are common to all OSes to `vars/main.yml`, and variables that have different values in different OSes to the OS file, e.g. `vars/RedHat_9.yml`. 

### Using third-party content

We avoid using third-party Ansible content to keep the System Roles self-contained.
So instead of using modules from community.general, ansible.posix and other collections, we try to use the `command` module, or other System Roles to perform those tasks.

Example - instead of using `community.general.archive`, we can do a series of tasks like this:

```yaml
    - name: leapp_old_postgresql_data | Process remediation
      when: pgsql_data_stat.stat.exists
      vars:
        backup_file_name: pgsql_data_backup_{{ ansible_facts['date_time'].iso8601_basic_short }}.tar.gz
      block:
        - name: leapp_old_postgresql_data | Ensure tar is installed
          ansible.builtin.package:
            name: tar
            state: present

        - name: leapp_old_postgresql_data | Ensure /var/backups exists
          ansible.builtin.file:
            path: "{{ postgresql_backup_path }}"
            state: directory
            mode: "0755"

        - name: leapp_old_postgresql_data | Create tar.gz archive of postgresql data
          ansible.builtin.command: # noqa: command-instead-of-module
            cmd: tar -czf {{ postgresql_backup_path }}/{{ backup_file_name }} {{ postgresql_data_path }}
          changed_when: true

        - name: leapp_old_postgresql_data | Set permissions on backup archive
          ansible.builtin.file:
            path: "{{ postgresql_backup_path }}/{{ backup_file_name }}"
            mode: "0755"

        - name: leapp_old_postgresql_data | Remove original postgresql data
          ansible.builtin.file:
            path: "{{ postgresql_data_path }}"
            state: absent
```

### TLS/Crypto Parameter and Key Names

Many system roles have parameter and configuration key names that relate to TLS and other common cryptographic concepts.  This document describes the naming convention we are using in system roles for things like: the name of the parameter used for the full path to X509 certificate files on managed nodes; the name of the parameter which holds the value used for the LUKS encryption passphrase; and so on.

#### Description
Roles will implement support for the following variables/keys if they need the concept (e.g. some roles may not need a CA cert, so no need to implement support for `ROLENAME_ca_cert`).  Each full parameter name consists of:
* The `ROLENAME_` prefix (if this is a top level parameter and not a subkey of another top level parameter)
* an optional type prefix e.g. "client_", "server_", etc.
* a basename e.g. "cert", "key"
* an optional suffix e.g. "src", "content"

The type prefix is used to further specify what type of thing it is e.g. `server_ + cert == server_cert`.  The suffix is used to specify the source of the data - `cert + _content = cert_content`.  The suffix is only applicable for those parameters/keys which have a filename form (e.g. not applicable to `private_key_password`, `encryption_password`)
For example - `server_cert_content` would be a string blob consisting of a TLS server certificate.  `client_private_key_src` would be the path/filename of a file on the controller host containing the private key corresponding to the client certificate.

#### Table of Base Names With Explanation
<table>
  <tr>
    <td>Param/Key Base Name</td>
    <td>Concept</td>
    <td>Notes</td>
  </tr>
  <tr>
    <td>cert/client_cert/server_cert/..._cert</td>
    <td>Path to file on managed host containing a certificate</td>
    <td>Use `client_cert`/`server_cert` etc depending on the type of cert. In case the role’s context makes the type of the certificate clear, consider just using `cert`</td>
  </tr>
  <tr>
    <td>ca_cert</td>
    <td>Path to file on managed host containing one or more CA certs</td>
    <td>This may contain one or more root CA certs or intermediate CA certs - use "root_ca_cert" or "intermediate_ca_cert" if you need to distinguish between different types of CA certs</td>
  </tr>
  <tr>
    <td>private_key</td>
    <td>Path to a file on managed host containing a private key which is part of a private/public asymmetric key pair like an x509 or ssh key</td>
    <td>This may be an x509 or ssh or other type of private key - it is assumed in the context of the role and the usage that its purpose is unambiguous</td>
  </tr>
  <tr>
    <td>private_key_password</td>
    <td>String - password, passphrase, or pin used to unlock the private_key</td>
    <td>This can be a phrase or a pin - the term "word" does not suggest the length or format of this string.</td>
  </tr>
  <tr>
    <td>key</td>
    <td>Path to a file on managed host containing some sort of encryption key that is not one of a pair of asymmetric keys (e.g. not an x509 key or an ssh key)</td>
    <td>This is typically a file containing the encryption key used to unlock a device such as with LUKS or clevis - not an x509 or ssh private or public key</td>
  </tr>
  <tr>
    <td>password</td>
    <td>String - password or passphrase or pin</td>
    <td>This can be a phrase or a pin - the term "word" does not suggest the length or format of this string.  Example usage: LUKS unlock passphrase, clevis unlock password, network wifi password</td>
  </tr>
  <tr>
    <td>public_key</td>
    <td>Path to file on managed host containing a public_key, one of a pair of asymmetric keys e.g. an ssh public key</td>
    <td>Typically used with ssh to denote an ssh public key</td>
  </tr>
  <tr>
    <td>tls</td>
    <td>Boolean value - `true` if the component should use TLS for encryption - `false` if not</td>
    <td>Typically used in roles that have some sort of network connection that can optionally use TLS</td>
  </tr>
  <tr>
    <td>name</td>
    <td>Used only by the certificate role as a special case.  May indicate the name of the cert in the cert provider, or the relative or absolute path to the cert file on the managed host.</td>
    <td>This is also used to construct the name for the corresponding private key file.</td>
  </tr>
</table>

**RATIONALE** for cert - I wanted to preserve the network role semantics (which uses the NetworkManager semantics), but it was too difficult to figure out how to make it so that e.g. "cert" could be either a path or a blob.  If someone can come up with a foolproof way, given a string, to determine if that string is a certificate (or key) blob or a filename with possibly a relative/absolute path, then we could go back to the NM semantics.  Also, it is better to be explicit and reduce the ambiguity.

**RATIONALE** for password - password is a more generic concept than passphrase, so the term "password" encompasses terms such as "passphrase", "pin", etc.

#### Table of Name Suffixes With Explanation
<table>
  <tr>
    <td>Param/Key Suffix</td>
    <td>Concept</td>
    <td>Notes</td>
  </tr>
  <tr>
    <td>content</td>
    <td>a string containing the value to be used on the managed host e.g. a base64 encoded PEM blob used to populate a cert file on the managed host</td>
    <td>provide an unambiguous way for users to specify a blob value.  Also, the Ansible "copy" module uses "content" for the same purpose.  https://docs.ansible.com/ansible/latest/modules/copy_module.html#copy-module
Note that "key_content" is virtually identical to "password" - it is up to the role author to determine which usage is better for the role</td>
  </tr>
  <tr>
    <td>src</td>
    <td>path to file on controller host containing a certificate, ca_cert, key</td>
    <td>we have pre-existing use cases where the user wants to specify the name of a file on the controller node, and doesn't want to or cannot specify the value as a blob in "contents".  Also, the Ansible "copy" module uses "src" for the same purpose.  https://docs.ansible.com/ansible/latest/modules/copy_module.html#copy-module</td>
  </tr>
</table>

#### Table of Name Prefixes With Explanation
<table>
  <tr>
    <td>Param/Key Prefix</td>
    <td>Concept</td>
    <td>Notes</td>
  </tr>
  <tr>
    <td>client</td>
    <td>Used with "cert" and "private_key" to denote that this is the client cert and key</td>
    <td>Use this if you need to emphasize that the cert specified is for client purposes only, or if you need to distinguish between client and server certificates</td>
  </tr>
  <tr>
    <td>server</td>
    <td>Used with "cert" and "private_key" to denote that this is the server cert and key</td>
    <td>Use this if you need to emphasize that the cert specified is for server purposes only, or if you need to distinguish between client and server certificates</td>
  </tr>
  <tr>
    <td>x509</td>
    <td>Used with "private_key" to denote that this is an x509 private key</td>
    <td>Only use this if you need to distinguish between different private key types e.g. if your role can take both x509 and ssh keys or other types of private keys</td>
  </tr>
  <tr>
    <td>ssh</td>
    <td>Used with "private_key" or "public_key" to denote that this is an ssh key</td>
    <td>Only use this if you need to distinguish between different private key types e.g. if your role can take both x509 and ssh keys or other types of private keys - the use of "ssh_public_key" is optional, but your role may choose to support it if it makes the role look more consistent to have both "ssh_public_key" and "ssh_private_key".</td>
  </tr>
  <tr>
    <td>encryption</td>
    <td>Used with "key" and "password"</td>
    <td>For example, "encryption_key_src" and "encryption_password" are used in storage to denote the LUKS unlock key file/passphrase.  Similar usage in nbde_client for clevis.</td>
  </tr>
  <tr>
    <td>root</td>
    <td>Used with "ca_cert" to denote that this is one or more root CA certs</td>
    <td>Only use this if you need to distinguish between root CA certs and intermediate CA certs</td>
  </tr>
  <tr>
    <td>intermediate</td>
    <td>Used with "ca_cert" to denote that this is one or more intermediate CA certs</td>
    <td>Only use this if you need to distinguish between root CA certs and intermediate CA certs</td>
  </tr>
</table>

### Working with sensitive data

Tasks that handle sensitive data (credentials, secrets, private keys, passwords, etc.) must use `no_log` to prevent sensitive information from appearing in Ansible logs and console output. The role must provide a way for users to disable this for debugging purposes.

If a task uses sensitive data, it must have the option `no_log: "{{ <rolename>_secure_logging }}"` on the task level.
The role must define the `<rolename>_secure_logging: true` variable in `defaults/main.yml` and document the use of this variable in `README.md`.

**IMPORTANT**: Do NOT use the `| bool` filter with the variable - the variable is already boolean.

Example:

```yaml
- name: Read key from remote host
  ansible.builtin.slurp:
    src: "{{ __cvm_deploy_tmp_key.path }}"
  register: slurped_key
  no_log: "{{ trustee_client_secure_logging }}"
```

The `<rolename>_secure_logging` variable should be documented in `README.md` with guidance similar to this:

```markdown
### <rolename>_secure_logging

If `true`, suppress potentially sensitive output from tasks that handle
credentials, secrets, and other sensitive data by setting `no_log: true` on
those tasks. This prevents passwords, API tokens, private keys, and similar
sensitive information from appearing in Ansible logs and console output.

If you need to debug issues with credential handling or secret management, you
can temporarily set `<rolename>_secure_logging: false` to see the full output from
these tasks. However, be aware that this may expose sensitive information in
logs, so it should only be used in development or troubleshooting scenarios.

Default: `true`
```

### Reducing verbosity of facts modules

Facts gathering modules like `package_facts`, `service_facts`, and custom facts modules (e.g., `firewall_lib_facts`, `selinux_modules_facts`) produce verbose output that clutters logs during normal operation. To reduce log clutter while still allowing full output when debugging, use verbosity-based `no_log`:

```yaml
- name: Gather package facts
  package_facts:
  no_log: "{{ ansible_verbosity < 3 }}"

- name: Gather service facts
  service_facts:
  no_log: "{{ ansible_verbosity < 3 }}"
```

This pattern hides verbose facts output unless the playbook is run with `-vvv` or higher verbosity. This does NOT require adding a new variable to `defaults/main.yml` or documenting it in `README.md`, as it's purely an implementation detail to improve log readability.

## Python plugin development

For Python code, in the source file, the imports will generally come first, followed by constants, classes, and methods. The style of python coding for this project
is [**PEP 8**](https://www.python.org/dev/peps/pep-0008/),  with automatic formatting
thanks to [Python Black](https://black.readthedocs.io/en/stable/). Use `tox -e black` to
run formatting tests, and also `tox -e flake8`.

Unit tests should go into the `tests/unit/` directory.  You can use `tox -e
py$VER` to run the tests with a specific version of Python e.g. `tox -e py39`.

## Configuring Git

Before starting to contribute, make sure you have the basic git configuration:
Your name and email. This will be useful when signing your contributions. The
following commands will set your global name and email, although you can change
it later per repo:

```
git config --global user.name "Jane Doe"
git config --global user.email janedoe@example.com`
```

The git editor is your system's default. If you feel more comfortable with a
different editor for writing your commits (such as Vim), change it with:

```
git config --global core.editor vim
```

If you want to check your settings, use `git config --list` to see all the
settings Git can find.

You are strongly encouraged to use [gh](https://cli.github.com/), the official
GitHub CLI.  This will allow you to fork repos, submit pull requests, and much
more, without leaving the comfort of your cli.

## How to submit a pull request

1. Make a
   [fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
of the role repository.  For example:
```
gh repo clone linux-system-roles/network
cd network
gh repo fork
```

2. Create a new git branch on your local fork (the name is not relevant) and
   make the changes you need to complete an issue.

3. Do not forget to run unit and integration tests before pushing any changes!
   See above for how to use `tox` and `tox-lsr` to run checks and tests.

  - For Python code, check the formatting of the code with
    [Python Black](https://black.readthedocs.io/en/stable/) using `tox -e black,flake8`.

  - Check the Ansible files are correctly formatted using `tox -e ansible-lint`.

  - Check your integration tests e.g.
    `tox -e qemu-ansible-core-2-20 -- --image-name centos-9 tests/tests_mynewtest.yml`

4. Once the work is ready, create a git commit.  Use `git commit -s` to create
   a signed commit.  See below `Write a good commit message`.

5. Push the branch to your remote fork. The response message will usually
   contain a link and instructions about how to use the GitHub UI to submit a
   pull request.  You can also use `gh`: `gh create PR`
   This will prompt you for which repo is the upstream, which one is your private
   one, the PR title and body (default is to use the git commit message), and if
   you want the PR to be a Draft or not.

6. Check the CI test results.  If there are any errors, fix them and re-push
   your commits. If there is no problem with your contribution, the maintainer
   will merge it to the main project.  A project maintainer will review the PR
   and add a `[citest]` comment to run integration tests.

### Some important tips

- Make sure your fork and branch are up-to-date with the main project. First of
  all,
  [configure a remote upstream for your fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/configuring-a-remote-for-a-fork),
  and keep your branch up-to-date with the upstream using
  `git pull --rebase upstream main`

- Try to make a commit per issue.

- If you are asked to make changes to your PR, don't panic! Many times it is
  enough to amend your previous commit adding the new content to it
  (`git commit --amend`). Be sure to pull the latest upstream changes after that, and use `git push --force-with-lease` to re-upload your commit with the changes!  Note that PRs can squash the commits into 1 when merging [squashing
commits](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-request-merges#squash-and-merge-your-pull-request-commits).

- There are times when someone has made changes on a file you were modifying
  while you were making changes to your unfinished commit. At times like this,
  you need to make a
  [**rebase**](https://help.github.com/en/github/using-git/about-git-rebase) with
  conflicts. On the rebase you have to compare what the other person added to what
  you added, and merge both file versions into one that combines it all.

- If you have any doubt, do not hesitate to ask! You can join IRC channel
  \#systemroles on Libera.chat, or ask on the PR/issue itself.

### Write a good commit message

Here are some general best practice rules taken from [chris beams git commit](https://chris.beams.io/posts/git-commit/).
You may want to read this for a more detailed explanation (and links to other posts on how to write a good commit message).
This content is licensed under [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/).

1. Separate the subject from the body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

A good commit message looks something like this
```
Summarize changes in around 50 characters or less

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequences of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

 - Bullet points are okay, too

 - Typically a hyphen or asterisk is used for the bullet, preceded
   by a single space, with blank lines in between, but conventions
   vary here

If you use an issue tracker, put references to them at the bottom,
like this:

Resolves: rhbz#123456
```
Do not forget to sign your commit! Use `git commit -s`.

Now continue to the following section to write a good PR title and description.

## Write a good PR title and description

For PR titles, system roles follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format, repositories have a Commitlint GitHub action that ensures that all PR titles follow the format.
It makes it possible to generate the changelog and update the release version fully automatically.

Note that we ensure the conventional commits format only on PR titles and not on commits to let developers keep commit messages targeted for other developers i.e. describe actual changes to code that users should not care about.
And PR titles, on the contrary, must be aimed at end users.

We automatically collect PR titles and descriptions to changelog and release notes based on the set type.
Therefore, please ensure that you write PR titles and descriptions properly and treat them as a customer facing content.

### PR titles format

PR titles should be structured as follows:

```
<required type><optional !>: <your PR title>
```

Here are rules that you must follow while writing a conventional PR title:

1. You must include a type of the change at the beginning of the title, followed by a colon and a space, e.g. `feat: <your PR title>`.

    The type `feat` MUST be used when you add a new feature.
    The type `fix` MUST be used when you fix a bug.
    Other allowed types are `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refractor`, `revert`, `style`, `test`, `tests`.
    Let us know if you want to add some other type to the allowed list.

    Considering [Semantic Versioning](http://semver.org/#summary):
    - The type `feat` correlates with `MINOR`
    - All other types correlate with `PATCH`
    - For `MAJOR`, see point 2 below.

    Considering changelog and release notes categories:
    - The type `feat` correlates with `New Features`
    - The type `fix` correlates with `Bug Fixes`
    - All other types correlate with `Other Changes`

2. You must mark PRs that introduce a breaking API change by appending `!` after the type, e.g. `fix!: <your PR title>`.
Considering [Semantic Versioning](http://semver.org/#summary), this correlates with `MAJOR`.
A BREAKING CHANGE can be part of PR of any type.

### PR description format

For the PR description, write it as a release not that you want end users to see.
When creating a PR, you will see the following template, please fill it in to ensure that users get informed about what causes the change and how to make use of it:

```Markdown
Enhancement:

Reason:

Result:

Issue Tracker Tickets (Jira or BZ if any):
```

### Example PR title and desctiption

feat: Support custom data and logs storage paths

Enhancement: Custom data and logs storage paths

Reason: Previously, the role was configuring the default data and logs storage paths.

Result: Currently, you can optionally provide custom storage paths with variables `mssql_datadir` and `mssql_logdir`.
And optionally set permissions for the custom paths with `mssql_datadir`_mode and `mssql_logdir`_mode variables.

Issue Tracker Tickets (Jira or BZ if any):
https://issues.redhat.com/browse/RHEL-528
https://issues.redhat.com/browse/RHEL-529

## Debugging Integration Tests

For debugging, use `tox` with `qemu` (see above), and use the `--debug`
flag.
```
tox -e qemu-ansible-core-2-20 -- --image-name centos-9 --debug tests/tests_mytest.yml
grep ssh artifacts/default_provisioners.log | tail -1
```
Then use that `ssh` command to log into the VM.

For the manual method, use `TEST_DEBUG=true`.  Remember that the last path is one of the test you want to run.
```
cd tests
TEST_DEBUG=true ANSIBLE_STDOUT_CALLBACK=debug \
TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 \
ansible-playbook -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2 \
tests_default.yml
```
Using debug will allow you to `ssh` into the managed host after the test has
run. It will print out instructions about the exact command to use to `ssh`, and
how to destroy the managed host after you are done.  Or, check the
`artifacts/default_provisioners.log` for the ssh command.

When you are done with the VM, use `pkill -f standard-inventory` to destroy
the VM and clean up.

## CI Testing in GitHub Pull Requests

There are many tests run when you submit a PR.  Some of them are immediately
triggered when pushing new content to a PR (i.e. the tests hosted on Github
Actions such as `Ansible Lint`), while other need to be triggered by members of
the project.  The latter are typically the integration tests - CI runs all of
the tests in `tests/tests_*.yml` with a couple of versions of Ansible and on
several platforms (the ones listed in your meta/main.yml).  Platforms that the
role does not support will report the status as `Passed` with a message like "role
does not support this platform".  The integration tests need to be triggered by
a project maintainer.  To trigger them, write a command as a PR comment. The
available commands are:

- `[citest]` - Trigger a re-test for all machines.
- `[citest bad]` - Trigger a re-test for all machines with an error or failure
  status.
- `[citest pending]` - Trigger a re-test for all machines with a pending status.
- `[citest commit:<sha1>]` - specify a commit to be tested if the submitter is
  not trusted.
- `[citest skip]` - if you have a change to the documentation, or otherwise it
  would be a waste of time to do integration CI testing on your change, you can
  put `[citest skip]` in the title of your pull request.  This will save a lot
  of time.

## Blog Post Contribution

Create a new file in the `blog/_posts/` directory.  The file should be in
markdown format, and the filename should begin with the date in this format -
`YYYY-MM-DD-` - and end in `.md`.  The file should begin with a header like
this:
```yaml
---
layout: post
title: "The Title of My Post"
section: Blog
date: YYYY-MM-DDTHH:MM:SS
author: Your Name
category: talk
---
```
Change the values for the `title`, `date`, and `author` fields.  Use `category:
release` if this is an announcement of a new release.  NOTE: If you have
examples of Jinja2 templates in your blog post e.g. an excerpt from an Ansible
file, you should enclose the code using `raw` and `endraw` directives:
```
{%- assign lcub = '{' %}
{%- assign rcub = '}' %}
<!-- {{ lcub }}% raw %{{ rcub }} -->
Ansible/jinja2 goes here
<!-- {{ lcub }}% endraw %{{ rcub }} -->
```
Then submit a PR to
https://github.com/linux-system-roles/linux-system-roles.github.io/pulls - once
your PR is merged, it may take a few minutes before it is published at
https://linux-system-roles.github.io/blog/  NOTE: If you are viewing the above in plain text or github markdown render, replace the `lcub` template with `{` and the `rcub` template with `}`.

## Update Changelogs, Tag, and Release a Role Repo

Tagging and releasing a role repo is now automated by updating the CHANGELOG.md
file. Please see {% link documentation/howto/tag-and-release-role.md %} for more
details.

## How to reach us
The mailing list for developers: systemroles@lists.fedorahosted.org

[Subscribe to the mailing list](https://lists.fedorahosted.org/admin/lists/systemroles.lists.fedorahosted.org/)

[Archive of the mailing list](https://lists.fedorahosted.org/archives/list/systemroles@lists.fedorahosted.org/)

If you are using IRC, join the `[#systemroles](irc://irc.libera.chat/systemroles)` IRC channel on
[Libera.chat](https://libera.chat)


*Thanks for contributing and happy coding!!*
