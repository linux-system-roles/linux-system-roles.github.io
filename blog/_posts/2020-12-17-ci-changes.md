---
layout: post
title: "CI changes - Github Actions and tox-lsr"
section: Blog
date: 2020-12-17T12:00:00
author: Rich Megginson
category: talk
---
We have recently moved our github CI to use [Github
Actions](https://docs.github.com/en/free-pro-team@latest/actions) instead of
Travis.  Our organization template is here:
[https://github.com/linux-system-roles/.github](https://github.com/linux-system-roles/.github)

We currently aren't using any of the more advanced features of Github Actions,
as we wanted to achieve parity with Travis as soon as possible.

We have also replaced all of the local scripts used for CI testing with
[tox-lsr](https://github.com/linux-system-roles/tox-lsr).  If you are a system
roles developer, you will need to modify your workflow in order to use the new
plugin.  See
[README.md](https://github.com/linux-system-roles/tox-lsr/blob/main/README.md)
for more information.
