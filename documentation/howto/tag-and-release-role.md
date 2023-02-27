---
layout: page
title: System Roles - How to Update Changelogs, Tag, and Release a Role Repo
---
We use [Semantic Versioning](https://semver.org) for release numbering.  We use
the release number for the git tag and for the version number used when
publishing to [Ansible Galaxy](https://galaxy.ansible.com)

There are some helper scripts for updating changelogs, tagging, and publishing roles,
and releasing a collection by converting the roles into a collection, checking,
and publishing to Galaxy.  See
[role-make-version-changelog.sh](https://github.com/linux-system-roles/auto-maintenance#role-make-version-changelogsh)
and
[release_collection.py](https://github.com/linux-system-roles/auto-maintenance/#release_collectionpy)

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

## Update changelogs, Create Git Tag, and Release on Github

Script [role-make-version-changelog.sh](https://github.com/linux-system-roles/auto-maintenance#role-make-version-changelogsh) is used to create a new version,
tag, and release for a role. It will guide you through the process.
It will show you the changes in the role since the last tag, and ask you
what will be the new semantic version to use for the tag. It will then put
the changes in a file to use for the update to the CHANGELOG.md file for
the new version, and put you in your editor to edit the file. If you are
using this in conjunction with local-repo-dev-sync.sh, it will push the
changes to your repo and create a pull request for CHANGELOG.md. Once the
CHANGELOG.md PR is merged, there is github action automation to tag the
repo with the version, create a github release, and import the new version
into Ansible Galaxy.

For an example of a good changelog and the corresponding release, see
https://github.com/linux-system-roles/network/blob/main/CHANGELOG.md#1100---2022-11-01
https://github.com/linux-system-roles/network/releases/tag/1.10.0

The example network [1.10.0] shows all three sections have one or more items.
If there are no items in a section, omit the section.

## Publish on Ansible Galaxy

The github action automation should do everything for you - tag, github repo
release, and publish to Galaxy.

If for some reason you need to manually publish a role, you must first ensure
the role is tagged and there is a github release.  Then, use
```
ansible-galaxy role import -vv --branch main linux-system-roles $ROLENAME
```
The Galaxy UI import method might also work.  If you want to use that method:

Go to https://galaxy.ansible.com/my-content/namespaces

Select your namespace e.g. `linux-system-roles`

Find the repository you are interested in. On the right hand side of the
window will be a button called Import. Click this button to start importing.
Galaxy will import and create releases for each release under
`https://github.com/linux-system-roles/$ROLENAME/releases`.
Once the import is complete, go to the role's page on Galaxy e.g.
`https://galaxy.ansible.com/linux-system-roles/network`.
You should see your release version listed under `Versions`. If you do not,
check the import log for errors.

## Test role install

Use `ansible-galaxy role install linux-system-roles.$ROLENAME` e.g.
`ansible-galaxy role install linux-system-roles.network`.
