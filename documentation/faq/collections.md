---
layout: page
title: Preparation for Converting Your Role to the Collections Format
---

If you are developing a role in linux-system-roles, you may find your question already answered here.

## Module and Module_utils Name

<b>Q:</b> My role has a custom module in the `library/` directory. Are there anything I should know of?<br>
<b>A:</b> All of the files in the `library/` directory should have a `YOUR_ROLENAME_` prefix. For instance, if you are planning to name your module `getinfo`, please name it `YOUR_ROLENAME_getinfo`. This will help preventing the module name conflict when your role is converted to the collections format. In the format, all the modules are placed in the same directory `ansible_collections/NAMESPACE/COLLECTION_NAME/plugins/modules/`, where popular names could get conflicted.

<b>Q:</b> How about module_utils?<br>
<b>A:</b> The `module_utils/` directory in the collections format is allowed to have sub-directories. Please put all the files in your `module_utils/` directory in the `module_utils/YOUR_ROLENAME_lsr/` sub-directory.

<b>Q:</b> What is the problem that you are trying to solve?<br>
<b>A:</b> With collections, all of our modules are part of the public API - users can use them directly e.g. `fedora.system_roles.blivet:`. There is currently no mechanism in Ansible to make these private (although Thomas Woerner has asked Ansible to provide this), and there is currently no convention to denote such modules as "private" e.g. use "_" as the first character in the module name (and a convention won't prevent usage anyway).
With collections, the user can use the collections: keyword, and we're back to global namespace collisions:

```
collections:
  - somenamespace.somename
  - fedora.system_roles
...
- name: use blivet
  blivet:
    ...
```

This will use somenamespace.somename.blivet instead of the one from system roles. Although we can strongly recommend that users always use the FQCN fedora.system_roles.blivet we cannot guarantee that they will.

<b>Q:</b> Why not use a `YOUR_ROLENAME` subdir under library/ ?<br>
<b>A:</b> Because it is not currently supported by galaxy.

<b>Q:</b> Why not use a `YOUR_ROLENAME_` prefix for module_utils file? Why use a subdir?<br>
<b>A:</b> Ease of conversion - the sub-directory style module_utils have been used in multiple roles and guaranteed to work.

## Sub-role Name

<b>Q:</b> My role contains a sub-role. Are there any guidance for the sub-role naming?<br>
<b>A:</b> A sub-role in a linux system role is completely private to the role. Thus, there is no restriction in naming. But now we have to consider how they are converted to the collections format. In short, the sub-role is promoted to the same level as the parent role is. The sub-role becomes reusable by the roles other than the original parent role in the collections format. But at the same time, it increases the risk of the naming conflict with the sub-roles from the other roles if the naming is too generic. We strongly recommend to name the sub-role name to be clear enough to reduce the risk. Although this is an imaginary example, if your main role is `rsyslog` and it has a sub-role named `relp`, it should be named `rsyslog_relp` which is more descriptive and less chance to conflict.
