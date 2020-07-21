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

To run integration tests, use a cloud image like the [CentOS 8.1
VM](https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2)
and execute the command and download the package
`standard-test-roles-inventory-qemu` from the Fedora repository:

`dnf install standard-test-roles-inventory-qemu`

Then `cd tests` to change to the `tests` subdirectory, and run the test playbook like this:
```
ANSIBLE_STDOUT_CALLBACK=debug TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2
ansible-playbook -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2
tests_default.yml
```
Use the stdout callback to format the output nicely.  Replace `tests_default.yml` with the actual test you want to run.

4. Once the work is ready and committed, push the branch to your remote fork and click on
   "new Pull Request" on Github (or use `gh` or `hub`).

5. Check the continuous integration test results.  If
   there are any errors, fix them and re-push your commits. If there is no problem with your contribution, the maintainer
   will merge it to the main project.

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
  on freenode, or ask on the PR/issue itself.

### Best Practices

Please refer to [Best Practices](https://github.com/oasis-roles/meta_standards/blob/master/README.md) for best practices to follow while making a contribution .

The following sections are a good place to start:

* [Naming Things](https://github.com/oasis-roles/meta_standards/blob/master/README.md#naming-things)
* [Providers](https://github.com/oasis-roles/meta_standards/blob/master/README.md#providers)
* [Supporting Multiple providers](https://github.com/oasis-roles/meta_standards/blob/master/README.md#supporting-multiple-providers)
* [Check Mode and Idempotency Issues](https://github.com/oasis-roles/meta_standards/blob/master/README.md#check-mode-and-idempotency-issues)
* [YAML and Jinja2 Syntax](https://github.com/oasis-roles/meta_standards/blob/master/README.md#yaml-and-jinja2-syntax)
* [Ansible Best Practices](https://github.com/oasis-roles/meta_standards/blob/master/README.md#ansible-best-practices)
* [Vars vs Defaults](https://github.com/oasis-roles/meta_standards/blob/master/README.md#vars-vs-defaults)
* [Documentation conventions](https://github.com/oasis-roles/meta_standards/blob/master/README.md#documentation-conventions)


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
For debugging, use `TEST_DEBUG=true`.  Remember that the last path is one of the test you want to run.
```
cd tests
TEST_DEBUG=true ANSIBLE_STDOUT_CALLBACK=debug \
TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 \
ansible-playbook -vv -i /usr/share/ansible/inventory/standard-inventory-qcow2 \
tests_default.yml
```
Using `TEST_DEBUG=true` will allow you to `ssh` into the managed host
after the test has run. It will print out instructions about the exact command to use 
to `ssh`, and how to destroy the managed host after you are done.

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
TravisCI) while other need to be triggered by members of the project. This second
set of tests can be manually triggered. To trigger them, write a command as a PR
comment. The available commands are:

- [citest] - Trigger a re-test for all machines.
- [citest bad] - Trigger a re-test for all machines with an error or failure status.
- [citest pending] - Trigger a re-test for all machines with a pending status.
- [citest commit:<sha1\>] - Whitelist a commit to be tested if the submitter is not
trusted.

## How to reach us
The mailing list for developers: systemroles@lists.fedorahosted.org

[Subscribe to the mailing list](https://lists.fedorahosted.org/admin/lists/systemroles.lists.fedorahosted.org/)

[Archive of the mailing list](https://lists.fedorahosted.org/archives/list/systemroles@lists.fedorahosted.org/)

If you are using IRC, join the `#systemroles` IRC channel on 
[freenode](https://freenode.net/kb/answer/chat)


*Thanks for contributing and happy coding!!*
