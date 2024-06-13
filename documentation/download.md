---
layout: page
title: Downloads and Releases
---
## Downloads

The roles are available in a few places and a couple of different formats.  The usual way
to install is using the `ansible-galaxy role install` (to install individual roles),
or `ansible-galaxy collection install` (to install the collection containing all of the roles)
command.

If you use Fedora or EL, you can install the RPM package `linux-system-roles` or
`rhel-system-roles` which provides the roles in the legacy role format and in the
collection format.

If you are a Red Hat Ansible customer, the `redhat.rhel_system_roles` collection is published
in [Automation Hub](https://console.redhat.com/ansible/automation-hub).

## Releases

The release process starts with a role maintainer doing a GitHub release in the individual role repo.
For example, here is the [latest network role release](https://github.com/linux-system-roles/network/releases).
Each role release has a SemVer release number which is also used as the git tag.
Each role also has a CHANGELOG.md file which describes the changes in that release and prior releases.
The GitHub release page also has the CHANGELOG with links to the GitHub PRs.
The [github action](https://github.com/linux-system-roles/network/blob/main/.github/workflows/changelog_to_tag.yml)
that handles the release will also publish the new role to [Galaxy](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/network/versions/)

The next step is the collection release process.
A [nightly GitHub action](https://github.com/linux-system-roles/auto-maintenance/blob/main/.github/workflows/publish_collection.yml)
checks if any roles have been released.
If so, the action will create a new collection and publish it to [Galaxy](https://galaxy.ansible.com/ui/repo/published/fedora/linux_system_roles/)

The Fedora RPM release is built from this, using [Packit](https://packit.dev/).  There is a [packit config](https://github.com/linux-system-roles/auto-maintenance/blob/main/.packit.yaml)
in the upstream project which initiates the `propose_downstream` workflow when there is a new collection release.
This works in conjunction with the [downstream packit config](https://src.fedoraproject.org/rpms/linux-system-roles/blob/rawhide/f/.packit.yaml).
This will create [PRs](https://src.fedoraproject.org/rpms/linux-system-roles/pull-request/480) in Fedora dist-git.
Once the PR is reviewed and merged by the package maintainers, the RPM will be built and eventually published by the automation.

### How to find out the version and changes in a given role

Each role has a `CHANGELOG.md` file which lists the versions, the release dates, and the changes in each version.
The latest version is at the top of the file, which should be the version of the role you are currently using.
That version corresponds to a GitHub release version and tag.  The GitHub release page for that release will list the PRs with
links, and you can also get a git diff of the changes that went into that release.

For example: I'm using a `fedora.linux_system_roles` collection release that I installed from Galaxy, and I want
to know the recent changes to the network role, and look at the code diffs.

Find where you installed the collection, either in `/usr/share/ansible` or `~/.ansible`.

Look at the CHANGELOG.md file for the network role in the collection root directory under `fedora/linux_system_roles/roles/network/CHANGELOG.md`.
The latest release is e.g. `1.15.2 - 2024-04-04`.  The summary changes for this release are listed.  You can also look at the
changes from older releases.

Go to the [release page in GitHub](https://github.com/linux-system-roles/network/releases/tag/1.15.2).  From here, you can

* see an individual [PR](https://github.com/linux-system-roles/network/pull/675) that went into the release
* use the `Compare` menu to see all of the changes between this release and any other release
* see [the changes](https://github.com/linux-system-roles/network/compare/1.15.2...main) to the main branch since this release

Go to the [Releases](https://github.com/linux-system-roles/network/releases) page to see if there have been any
newer releases.
