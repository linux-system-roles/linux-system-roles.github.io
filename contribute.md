---
layout: page
title: Contribute
---

Each subsystem is separated into individual repositories within the
[linux-system-roles](https://github.com/linux-system-roles) GitHub project.
Open a new issue against the appropriate subsystem's issue tracker to
report bugs or request enhancements. New subsystem requests or feedback can be
provided to the project's landing page at
[linux-system-roles.github.io](https://linux-system-roles.github.io) Pull
requests welcome!

## Using tox and tox-lsr

Local unit tests and linting is done using
[tox](https://tox.readthedocs.io/en/latest/).  You will typically install this
using your platform packages e.g. `dnf install python3-tox`.  You can also
install this using `pip` e.g. `pip install tox --user` (and you will need to
install `pip` using your platform packages e.g. `dnf install python3-pip`).

We use a special linux-system-roles tox plugin called
[tox-lsr](https://github.com/linux-system-roles/tox-lsr) which provides all of
the linters, unit tests, etc.  See the
[README.md](https://github.com/linux-system-roles/tox-lsr/blob/main/README.md)
for information about how to install and use this plugin.

After making changes, you should run `tox` to check that your changes conform to
project coding standards.  Otherwise, your pull request will likely fail one or more tests.

### Use tox-lsr with qemu

The latest version of tox-lsr supports qemu testing.  https://github.com/linux-system-roles/tox-lsr#qemu-testing

After you have installed `tox` and `tox-lsr` (see above), use yum or dnf to
install `standard-test-roles-inventory-qemu`

* Download the config file to `~/.config/linux-system-roles.json` from [here](https://raw.githubusercontent.com/linux-system-roles/linux-system-roles.github.io/master/download/linux-system-roles.json)

Assuming you are in a git clone of a role repo which has a `tox.ini` file - you can use e.g.

```
tox -e qemu-ansible-core-2.12 -- --image-name centos-8 tests/tests_default.yml
```

There are many command line options and environment variables which can be used to control the behavior, and you can customize the testenv in tox.ini.  See  https://github.com/linux-system-roles/tox-lsr#qemu-testing

This will create a directory named `artifacts/` in the current directory which
may contain additional logs useful for debugging.

## Code structure
The repository is structured as described in [Ansible Roles documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#role-directory-structure)

In addition to the standard roles files described in the roles documentation, there may be some additional directories:

- `./examples/` - Contains YAML examples for different configurations.

- `./tests/tests_*.yml` - Contains the complete tests for the role.`./tests/tasks/` 
  contains task snippets that are used in multiple tests to avoid having the same 
  code repeated multiple times.  
  Note that for the `network` role, `./tests/tests_*.yml` are shims to run tests 
  once for every provider and `./tests/playbooks/` contain the actual tests. 

The rest of files in the root folder mostly serve as configuration files for different
testing tools and bots that help with the maintenance of the project.

For Python code, in the source file, the imports will generally come first, followed by constants, classes, and methods. The style of python coding for this project
is [**PEP 8**](https://www.python.org/dev/peps/pep-0008/),  with automatic formatting
thanks to [Python Black](https://black.readthedocs.io/en/stable/). Use `tox -e black` to 
run formatting tests or use `tox` to run all configured tests.

## Configuring Git

Before starting to contribute, make sure you have the basic git configuration: Your name
and email. This will be useful when signing your contributions. The following commands
will set your global name and email, although you can change it later per repo:

```
git config --global user.name "Jane Doe"
git config --global user.email janedoe@example.com`
```

The git editor is your system's default. If you feel more comfortable with a different
editor for writing your commits (such as Vim), change it with:

`
git config --global core.editor vim
`

If you want to check your settings, use `git config --list` to see all the settings Git can find.

If you prefer using the command line to interact with github, you are strongly encouraged to use a tool like [gh](https://cli.github.com/) or [hub](https://hub.github.com/).  These tools will allow you to fork repos, submit pull requests, and much more, without leaving the comfort of your cli.

## How to contribute

1. Make a
   [fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
of this repository.

2. Create a new git branch on your local fork (the name is not relevant) and make the
   changes you need to complete an issue.

3. Do not forget to run unit and integration tests before pushing any changes!

  - This project uses [tox](https://tox.readthedocs.io/en/latest/) to run unit tests.
    You can try it with `tox -e py36` in case you want to try it using Python 3.6, or
    just `tox` if you want to run all the tests.

  - Check the formatting of the code with [Python Black](https://black.readthedocs.io/en/stable/) using `tox -e black`.

  - Check the YAML files are correctly formatted using `tox -e yamllint`.

  - Integration tests are executed as
    [ansible-playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html).

To run integration tests, use `tox` with `qemu` (see above).

If you want to configure and run everything manually, use a cloud image like the
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

4. Once the work is ready and committed, push the branch to your remote fork and click on
   "new Pull Request" on Github (or use `gh` or `hub`).

5. Check the continuous integration test results.  If
   there are any errors, fix them and re-push your commits. If there is no problem with your contribution, the maintainer
   will merge it to the main project.

### Running integration tests with CentOS7 container from CI

CI testing runs Ansible 2.8 tests in a CentOS7 container using Python 2.7 and Jinja 2.7.
If you are getting a test failure in this environment that you cannot reproduce outside of
this environment, you can run tests locally using `podman`.  This assumes you have a qcow2
image somewhere that can be accessed from the container.  The simplest way to handle this
is to copy the qcow2 image you want to use to `$HOME/linux-system-roles/ROLENAME/tests` and
refer to it as `TEST_SUBJECTS=./IMAGE.qcow2`.  This assumes you have cloned the
role at `$HOME/linux-system-roles/ROLENAME`.  If not, adjust the argument to `podman -v`.

```bash
git clone https://github.com/linux-system-roles/test-harness
cd test-harness
buildah bud -f Dockerfile.centos7 -t lsr:centos7
podman run -it --entrypoint /bin/bash -v $HOME:$HOME -u 0 --privileged lsr:centos7
```
then inside the container
```
cd /home/USER_FROM_HOST/linux-system-roles/ROLENAME/tests
TEST_SUBJECTS=./IMAGE.qcow2 ANSIBLE_STDOUT_CALLBACK=debug \
ansible-playbook -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2 \
tests_MYTEST.yml
```
NOTE: you probably don't want to write to `$HOME` unless you know what you are doing.
If you want to write out a log file, use `/tmp`.

### Some important tips

- Make sure your fork and branch are up-to-date with the main project. First of all, 
  [configure a remote upstream for your
fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/configuring-a-remote-for-a-fork), 
and keep your branch up-to-date with the upstream using `git pull --rebase upstream master`

- Try to make a commit per issue.

- If you are asked to make changes to your PR, don't panic! Many times it is enough to
  amend your previous commit adding the new content to it (`git commit --amend`). Be
sure to pull the latest upstream changes after that, and use `git push
--force-with-lease` to re-upload your commit with the changes!  Another way of doing
changes to a PR is by [squashing
commits](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-request-merges#squash-and-merge-your-pull-request-commits).

- There are times when someone has made changes on a file you were modifying while you
  were making changes to your unfinished commit. At times like this, you need to make a
[**rebase**](https://help.github.com/en/github/using-git/about-git-rebase) with
conflicts. On the rebase you have to compare what the other person added to what you
added, and merge both file versions into one that combines it all.

- If you have any doubt, do not hesitate to ask! You can join IRC channel \#systemroles
  on Libera.chat, or ask on the PR/issue itself.

### Recommended Practices

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


### Write a good commit message
Here are a few rules to keep in mind while writing a commit message

   1. Separate subject from body with a blank line
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

 Resolves: #123
 See also: #456, #789

Do not forget to sign your commit! Use `git commit -s`

```

This is taken from [chris beams git commit](https://chris.beams.io/posts/git-commit/). 
You may want to read this for a more detailed explanation (and links to other posts on
how to write a good commit message). This content is licensed under 
[CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/).

### Debugging
For debugging, use `tox` with `qemu` (see above), and use the `--debug`
flag.  For the manual method, use `TEST_DEBUG=true`.  Remember that the last path is one of the test you want to run.
```
cd tests
TEST_DEBUG=true ANSIBLE_STDOUT_CALLBACK=debug \
TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 \
ansible-playbook -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2 \
tests_default.yml
```
Using debug will allow you to `ssh` into the managed host
after the test has run. It will print out instructions about the exact command to use 
to `ssh`, and how to destroy the managed host after you are done.  Or,
check the `artifacts/default_provisioners.log` for the ssh command.

**The next part is specific for debugging the network role**

When using the `nm` provider, NetworkManager create a checkpoint and reverts the changes
on failures. This makes it hard to debug the error. To disable this, set the Ansible
variable `__network_debug_flags` to include the value `disable-checkpoints`. Also tests
clean up by default in case there are failures. They should be tagged as
`tests::cleanup` and can be skipped. To use both, run the test playbooks like this:
```bash
cd tests
ANSIBLE_STDOUT_CALLBACK=debug \
TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 \
ansible-playbook --skip-tags tests::cleanup \
    -e "__network_debug_flags=disable-checkpoints" \
    -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2 playbooks/tests_802_1x.yml
```
### Continuous integration

The [continuous integration](https://en.wikipedia.org/wiki/Continuous_integration) (CI)
contains a set of automated tests that are triggered on a remote server. Some of them
are immediately triggered when pushing new content to a PR (i.e. the tests hosted on
Github Actions) while other need to be triggered by members of the project. This second
set of tests can be manually triggered. To trigger them, write a command as a PR
comment. The available commands are:

- `[citest]` - Trigger a re-test for all machines.
- `[citest bad]` - Trigger a re-test for all machines with an error or failure status.
- `[citest pending]` - Trigger a re-test for all machines with a pending status.
- `[citest commit:<sha1>]` - specify a commit to be tested if the submitter is not trusted.
- `[citest skip]` - if you have a change to the documentation, or otherwise it
would be a waste of time to do integration CI testing on your change, you can
put `[citest skip]` in the title of your pull request.  This will save a lot of
time.

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

## How to reach us
The mailing list for developers: systemroles@lists.fedorahosted.org

[Subscribe to the mailing list](https://lists.fedorahosted.org/admin/lists/systemroles.lists.fedorahosted.org/)

[Archive of the mailing list](https://lists.fedorahosted.org/archives/list/systemroles@lists.fedorahosted.org/)

If you are using IRC, join the `[#systemroles](irc://irc.libera.chat/systemroles)` IRC channel on 
[Libera.chat](https://libera.chat)


*Thanks for contributing and happy coding!!*
