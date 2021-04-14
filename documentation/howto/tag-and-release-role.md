---
layout: page
title: System Roles - How to Tag and Release a Role Repo
---
We use [Semantic Versioning](https://semver.org) for release numbering.  We use
the release number for the git tag and for the version number used when
publishing to [Ansible Galaxy](https://galaxy.ansible.com)

## Version Number format

The version is required to be in the form `X.Y.Z` where `X`, `Y`, and `Z` are
non-negative integers.  For a new role, start at `0.0.1` until the code
stabilizes. During this stabilization period, just increase the `Z` number for a
new release.  Once the code is stable, change the version to `1.0.0` and follow
the normal semantic versioning rules.  According to `Semantic Versioning` the
`X` number should increase by 1 if there is a change which breaks the existing
API, or other radical changes are made.  The `Y` number should be increased by 1
if the API changes in a non-breaking way (e.g. adding a new parameter).  The `Z`
number should be increased by 1 for other changes, bug fixes, etc.  If you
increase the `X` number, be sure to change the `Y` and `Z` to 0.  If you
increase the `Y` number, be sure to change the `Z` to 0.

This includes the git tag - the git tag should be **identical** to the version
number - do not use git tags like `v1.1.0` or `1.1.0-rc` - it must be strictly
`X.Y.Z`.

## Create Git Tag and Release on Github

Go to the page `https://github.com/linux-system-roles/$ROLENAME/releases/new`
e.g. https://github.com/linux-system-roles/network/releases/new

Fill in the version in `X.Y.Z` format - this will also create the git tag if you
have not already done so.  Select the branch to tag (usually `main` or
`master`).

Give the release a descriptive title, and provide release notes in the text
field.

For an example of a good release, see
https://github.com/linux-system-roles/network/releases/tag/1.3.0

## Publish on Ansible Galaxy

Go to https://galaxy.ansible.com/my-content/namespaces

Select your namespace e.g. `linux-system-roles`

Find the repository you are interested in.  On the right hand side of the window
will be a button called `Import`. Click this button to start importing.  Galaxy
will import and create releases for each release under
`https://github.com/linux-system-roles/$ROLENAME/releases`.  Once the import is
complete, go to the role's page on Galaxy e.g.
`https://galaxy.ansible.com/linux-system-roles/network`.  You should see your
release version listed under `Versions`.  If you do not, check the import log
for errors.

## Test role install

Use `ansible-galaxy role install linux-system-roles.$ROLENAME` e.g.
`ansible-galaxy role install linux-system-roles.network`.
