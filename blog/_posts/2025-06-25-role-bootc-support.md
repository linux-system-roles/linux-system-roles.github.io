---
layout: post
title: "System Roles support for image mode (bootc) builds"
section: Blog
date: 2025-06-25T09:45:00
author: Martin Pitt
category: announcement
---

## Goal

Image mode, aka. "bootable containers", aka. "bootc" is an exciting new way to
build and deploy operating systems. A bootable container image can be used to
install or upgrade a real or virtual machine, similar to container images for
applications. This is currently supported for
[Red Hat Enterprise Linux 9/10](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/index)
and [Fedora/CentOS](https://docs.fedoraproject.org/en-US/bootc/), but also in
other projects like [universal-blue](https://universal-blue.org/).

With system roles being the supported high-level API to set up
Fedora/RHEL/CentOS systems, we want to make them compatible with image mode
builds. In particular, we need to make them detect the "non-booted" environment
and adjust their behaviour to not e.g. try to start systemd units or talk to
network services, and defer all of that to the first boot. We also need to add
full bootc end-to-end integration tests to ensure this keeps working in the
future on all supported platforms.

## Build process

This can work in two ways. Both ought to work, and which one you choose depends
on your available infrastructure and preferences.

### Treat a container build as an Ansible host

Start a container build with e.g.

```sh
buildah from --name buildc quay.io/centos-bootc/centos-bootc:stream10
```

Create an inventory for the [buildah connector](https://docs.ansible.com/ansible/latest/collections/containers/podman/buildah_connection.html):

```
buildc ansible_host=buildc ansible_connection=buildah ansible_become=false ansible_remote_tmp=/tmp
```

Then run the system-roles playbooks on the "outside" against that inventory.

That matches the spirit of Ansible and is cleaner as Ansible itself and
system-roles do not need to be installed into the container. This is the
approach outlined in ["Building Container Images with Buildah and
Ansible"](https://blog.tomecek.net/post/building-containers-with-buildah-and-ansible/)
and [Ansible and Podman Can Play Together
Now](https://blog.tomecek.net/post/ansible-and-podman-can-play-together-now/)
and implemented in the
[ansible-bender](https://github.com/ansible-community/ansible-bender) proof of
concept (⚠️ Warning: currently unmaintained).

### Install Ansible and the system roles into the container

The `Containerfile` looks roughly like this:

```
FROM quay.io/centos-bootc/centos-bootc:stream10
RUN dnf -y install ansible-core rhel-system-roles
COPY ./setup.yml .
RUN ansible-playbook setup.yml
```

Everything happens inside of the image build, and the playbooks run against
`localhost`. This could use a [multi-stage
build](https://docs.docker.com/build/building/multi-stage/) to avoid having
Ansible and the roles in the final image. This is entirely self-contained and
thus works well in automatic container build pipelines.

⚠️  Warning: Unfortunately this is currently broken for many/most roles because
of an Ansible bug: [`service:` fails in a container build environment](https://github.com/ansible/ansible/issues/85380).
Once that is fixed, this approach will work well and might often be the
preferred choice.

## Status

This effort is tracked in the [RHEL-78157](https://issues.redhat.com/browse/RHEL-78157) epic.
At the time of writing, 15 roles are already supported, the other 22 still need to be updated.

Roles which support image mode builds have the `containerbuild` tag, which you
can see in the [Ansible Galaxy view](https://galaxy.ansible.com/ui/standalone/roles/linux-system-roles/firewall/) (expand the tag list at the top), or in the source code in [meta/main.yml](https://github.com/linux-system-roles/firewall/blob/main/meta/main.yml).

Note that some roles also have a `container` tag, which means that they are
tested and supported in a running system container (i.e. a docker/podman
container with the `/sbin/init` entry point, or LXC/nspawn etc.), but not
during a non-booted container build.

## Steps for converting a role

Helping out with that effort is very much appreciated! If you are interested in
making a particular role compatible with image mode builds, please follow these steps:

1. Clone the role's upstream git repository. Make sure that its `meta/main.yml`
   file does _not_ yet have a `containerbuild` tag – if it does, the role was
   already converted. In that case, please update the status in the epic.

1. Familiarize yourself with the purpose of the role, have a look at README.md,
   and think about whether running the role in a container generally makes
   sense. That should be the case for most of them, but e.g `storage` is
   hardware specific and for the most part does not make sense in a container
   build environment.

1. Make sure your developer machine can run tests in in general. Do the
   [integration test setup](https://github.com/linux-system-roles/tox-lsr?tab=readme-ov-file#integration-test-setup) and also read the following sections about running QEMU and container tests.
   E.g. running a QEMU test should work:
   ```sh
   tox -e qemu-ansible-core-2.16 -- --image-name centos-9 --log-level=debug -- tests/tests_default.yml
   ```

1. Do an initial run of the default or other test during a bootc container build, to get a first impression:
   ```sh
   LSR_CONTAINER_PROFILE=false LSR_CONTAINER_PRETTY=false tox -e container-ansible-core-2.16 -- --image-name centos-9-bootc tests/tests_default.yml
   ```

1. The most common causes of failures are `service_facts:` which just simply
   doesn't work in a container, and trying to set the `state:` of a unit in
   `service:`. The existing PRs linked from [RHEL-78157](https://issues.redhat.com/browse/RHEL-78157)
   have plenty of examples what to do with these.

   The [logging role PR](https://github.com/linux-system-roles/logging/pull/444)
   is a good example for the standard approach of adding a
   `__rolename_is_booted` flag to the role variables, and use that to
   conditionalize operations and tests which
   can't work in a container. E.g. the above `service: status:` can be fixed
   with
   ```yaml
   state: "{{ 'started' if __myrole_is_booted else omit }}"
   ```

   `service_facts:` can be replaced with `systemctl is-enabled` or similar, see e.g. the corresponding
   [mssql fix](https://github.com/linux-system-roles/mssql/commit/e9d16e0eafaf1859f65e28a00c3de6a5283b2536) or
   [firewall fix](https://github.com/linux-system-roles/firewall/commit/e88b15ea3821b6b90443d1c9f76987bafdad5595).

   Do these "standard recipe" fixes to clear away the easy noise.

1. Create a branch on your fork, and add a
   [temporary commit to run tests on branch pushes](https://github.com/martinpitt/lsr-selinux/commit/58c1065b4751f13a9201ca767b7eaa0f09aaa92b), and another commit to
   [enable tests on container builds and in system containers](https://github.com/martinpitt/lsr-selinux/commit/56b18070f67c04d6f37a62bfa50f27cefd0a0779).
   With that you can iterate on your branch and get testing feedback without
   creating a lot of PR noise for other developers on the project. Push to your
   fork, go to the Actions page, and wait for the first test result.

1. As described above, the `container` tag means that the role is supported and
   works in (booted) system containers. In most cases this is fairly easy to
   fix, and nice to have, as running tests and iterating is faster, and
   debugging is also a bit easier. In some cases running in system containers
   is hard (like in the selinux or podman roles), in that case don't bother and
   remove that tag again.

1. Go through the other failures. You can download the log archive and/or run
   the individual tests locally. The following command helps for easier debugging – it
   keeps the container running for inspection after a failure, and removes
   containers and temp files from the previous run:

   ```sh
   buildah rm --all; rm -rf /tmp/runcontainer.*; LSR_DEBUG=1 LSR_CONTAINER_PROFILE=false LSR_CONTAINER_PRETTY=false tox -e container-ansible-core-2.16 -- --image-name centos-9-bootc tests/tests_default.yml
   ```

   You can enter the container and debug with `buildah run tests_default bash`.
   The container name corresponds to the test name; check `buildah ps`.

1. Fix the role and tests until you get a green result. Finally clean up and
   sort your commits into
   [fix: Skip runtime operations in non-systemd environments](https://github.com/linux-system-roles/postgresql/commit/089421478730b6bff88c42f1ac56eec9836ae852),
   and [feat: Support this role in container builds](https://github.com/linux-system-roles/postgresql/commit/fea9e802473805344d6e062f99961a4231b4f129).
   Any role specific or more intrusive and self-contained change should be in
   separate commits before these.

1. Add an end-to-end integration test which ensures that running the role
   during a container build actually works as intended in a QEMU deployment.
   If there is an existing integration test which has representative complexity
   and calls the role just once (i.e. tests one scenario), you can convert it
   like
   [sudo's bootc e2e test](https://github.com/linux-system-roles/sudo/commit/2a1569f846b24e427ba4bbe078ee5ce7bf81e13d).
   If there is no existing test, you can also add a specific bootc e2e test
   like in
   [this demo PR](https://github.com/linux-system-roles/sudo/pull/58/commits/42df7f14e54813e4d6d97bbc9d388f59cc25e09d)
   or the
   [postgresql role](https://github.com/linux-system-roles/postgresql/commit/18be022885c3953678c70278f7503f0df3283f04).

1. To locally run the bootc e2e test, see [Image mode testing tox-lsr docs](https://github.com/linux-system-roles/tox-lsr?tab=readme-ov-file#image-mode-testing).

1. Push the e2e test to your branch, iterate until green.

1. Send a PR, link it from the Jira epic, get it landed, update the list in the
   Jira epic again.

1. Celebrate 🎉 and brag about your contribution!
