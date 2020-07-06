---
layout: page
title: Documentation
---

The <b>Linux System Roles</b> are a collection of roles and modules executed by Ansible to assist Linux admins in the configuration of common GNU/Linux subsystems. Conceptually, the intent is to serve as a consistent “API” to a give Linux distribution that is consistent across multiple major and minor releases.

## Table of Contents

<ol>
{% for _node in site.data.nav %}{% assign level = 1 %}{% include toc.html level=level path="/" base_path=page.url node=_node %}{% endfor %}
</ol>
