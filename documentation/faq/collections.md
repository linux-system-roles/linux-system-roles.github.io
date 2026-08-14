---
layout: page
title: Preparation for Converting Your Role to the Collections Format
---

If you are developing a role in linux-system-roles, you may find your question already answered here.

## Module and Module_utils Name

<div class="admonition note">
<p class="admonition-title">My role has a custom module in the <code>library/</code> directory. Are there anything I should know of?</p>
<p>All of the files in the <code>library/</code> directory should have a <code>YOUR_ROLENAME_</code> prefix. For instance, if you are planning to name your module <code>getinfo</code>, please name it <code>YOUR_ROLENAME_getinfo</code>. This will help preventing the module name conflict when your role is converted to the collections format. In the format, all the modules are placed in the same directory <code>ansible_collections/NAMESPACE/COLLECTION_NAME/plugins/modules/</code>, where popular names could get conflicted.</p>
</div>

<div class="admonition note">
<p class="admonition-title">How about module_utils?</p>
<p>The <code>module_utils/</code> directory in the collections format is allowed to have sub-directories. Please put all the files in your <code>module_utils/</code> directory in the <code>module_utils/YOUR_ROLENAME_lsr/</code> sub-directory.</p>
</div>

<div class="admonition note">
<p class="admonition-title">What is the problem that you are trying to solve?</p>
<p>With collections, all of our modules are part of the public API - users can use them directly e.g. <code>fedora.system_roles.blivet:</code>. There is currently no mechanism in Ansible to make these private (although Thomas Woerner has asked Ansible to provide this), and there is currently no convention to denote such modules as "private" e.g. use "_" as the first character in the module name (and a convention won't prevent usage anyway).</p>
<p>With collections, the user can use the collections: keyword, and we're back to global namespace collisions:</p>

```
collections:
  - somenamespace.somename
  - fedora.system_roles
...
- name: use blivet
  blivet:
    ...
```

<p>This will use somenamespace.somename.blivet instead of the one from system roles. Although we can strongly recommend that users always use the FQCN fedora.system_roles.blivet we cannot guarantee that they will.</p>
</div>

<div class="admonition note">
<p class="admonition-title">Why not use a <code>YOUR_ROLENAME</code> subdir under library/ ?</p>
<p>Because it is not currently supported by galaxy.</p>
</div>

<div class="admonition note">
<p class="admonition-title">Why not use a <code>YOUR_ROLENAME_</code> prefix for module_utils file? Why use a subdir?</p>
<p>Ease of conversion - the sub-directory style module_utils have been used in multiple roles and guaranteed to work.</p>
</div>

## Sub-role Name

<div class="admonition note">
<p class="admonition-title">My role contains a sub-role. Are there any guidance for the sub-role naming?</p>
<p>A sub-role in a linux system role is completely private to the role. Thus, there is no restriction in naming. But now we have to consider how they are converted to the collections format. In short, the sub-role is promoted to the same level as the parent role is. The sub-role becomes reusable by the roles other than the original parent role in the collections format. But at the same time, it increases the risk of the naming conflict with the sub-roles from the other roles if the naming is too generic. We strongly recommend to name the sub-role name to be clear enough to reduce the risk. Although this is an imaginary example, if your main role is <code>rsyslog</code> and it has a sub-role named <code>relp</code>, it should be named <code>rsyslog_relp</code> which is more descriptive and less chance to conflict.</p>
</div>
