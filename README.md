linux-system-roles.github.io web page
***

For more information about the roles/collection please refer to our website [linux-system-roles.github.io](https://linux-system-roles.github.io/)

A more direct readme concerning the roles/collection can be found [here](index.md)

This page bases on the [slim-pickins-jekyll-theme](http://chrisanthropic.github.io/slim-pickins-jekyll-theme/) with several changes on top.

When including examples of Ansible code with jinja2 templating,
you will typically have to tell jekyll and its templating engine
to disable brace expansion.  One technique is to use `{% raw %}`
at the beginning of the file and `{% endraw %}` at the end of
the file, or use
```
<!-- {% raw %} -->
Ansible/jinja2 goes here
<!-- {% endraw %} -->
```
blocks.
