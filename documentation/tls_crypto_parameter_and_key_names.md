---
layout: page
title: "TLS/Crypto Parameter and Key Names"
---
Many system roles have parameter and configuration key names that relate to TLS and other common cryptographic concepts.  This document describes the naming convention we are using in system roles for things like: the name of the parameter used for the full path to X509 certificate files on managed nodes; the name of the parameter which holds the value used for the LUKS encryption passphrase; and so on.

## Description
Roles will implement support for the following variables/keys if they need the concept (e.g. some roles may not need a CA cert, so no need to implement support for `ROLENAME_ca_cert`).  Each full parameter name consists of:
* The `ROLENAME_` prefix (if this is a top level parameter and not a subkey of another top level parameter)
* an optional type prefix e.g. "client_", "server_", etc.
* a basename e.g. "cert", "key"
* an optional suffix e.g. "src", "content"

The type prefix is used to further specify what type of thing it is e.g. `server_ + cert == server_cert`.  The suffix is used to specify the source of the data - `cert + _content = cert_content`.  The suffix is only applicable for those parameters/keys which have a filename form (e.g. not applicable to `private_key_password`, `encryption_password`)
For example - `server_cert_content` would be a string blob consisting of a TLS server certificate.  `client_private_key_src` would be the path/filename of a file on the controller host containing the private key corresponding to the client certificate.
## Table of Base Names With Explanation
<table>
  <tr>
    <td>Param/Key Base Name</td>
    <td>Concept</td>
    <td>Notes</td>
  </tr>
  <tr>
    <td>cert/client_cert/server_cert/..._cert</td>
    <td>Path to file on managed host containing a certificate</td>
    <td>Use `client_cert`/`server_cert` etc depending on the type of cert. In case the role’s context makes the type of the certificate clear, consider just using `cert`</td>
  </tr>
  <tr>
    <td>ca_cert</td>
    <td>Path to file on managed host containing one or more CA certs</td>
    <td>This may contain one or more root CA certs or intermediate CA certs - use "root_ca_cert" or "intermediate_ca_cert" if you need to distinguish between different types of CA certs</td>
  </tr>
  <tr>
    <td>private_key</td>
    <td>Path to a file on managed host containing a private key which is part of a private/public asymmetric key pair like an x509 or ssh key</td>
    <td>This may be an x509 or ssh or other type of private key - it is assumed in the context of the role and the usage that its purpose is unambiguous</td>
  </tr>
  <tr>
    <td>private_key_password</td>
    <td>String - password, passphrase, or pin used to unlock the private_key</td>
    <td>This can be a phrase or a pin - the term "word" does not suggest the length or format of this string.</td>
  </tr>
  <tr>
    <td>key</td>
    <td>Path to a file on managed host containing some sort of encryption key that is not one of a pair of asymmetric keys (e.g. not an x509 key or an ssh key)</td>
    <td>This is typically a file containing the encryption key used to unlock a device such as with LUKS or clevis - not an x509 or ssh private or public key</td>
  </tr>
  <tr>
    <td>password</td>
    <td>String - password or passphrase or pin</td>
    <td>This can be a phrase or a pin - the term "word" does not suggest the length or format of this string.  Example usage: LUKS unlock passphrase, clevis unlock password, network wifi password</td>
  </tr>
  <tr>
    <td>public_key</td>
    <td>Path to file on managed host containing a public_key, one of a pair of asymmetric keys e.g. an ssh public key</td>
    <td>Typically used with ssh to denote an ssh public key</td>
  </tr>
  <tr>
    <td>tls</td>
    <td>Boolean value - `true` if the component should use TLS for encryption - `false` if not</td>
    <td>Typically used in roles that have some sort of network connection that can optionally use TLS</td>
  </tr>
  <tr>
    <td>name</td>
    <td>Used only by the certificate role as a special case.  May indicate the name of the cert in the cert provider, or the relative or absolute path to the cert file on the managed host.</td>
    <td>This is also used to construct the name for the corresponding private key file.</td>
  </tr>
</table>

**RATIONALE** for cert - I wanted to preserve the network role semantics (which uses the NetworkManager semantics), but it was too difficult to figure out how to make it so that e.g. "cert" could be either a path or a blob.  If someone can come up with a foolproof way, given a string, to determine if that string is a certificate (or key) blob or a filename with possibly a relative/absolute path, then we could go back to the NM semantics.  Also, it is better to be explicit and reduce the ambiguity.

**RATIONALE** for password - password is a more generic concept than passphrase, so the term "password" encompasses terms such as "passphrase", "pin", etc.

## Table of Name Suffixes With Explanation
<table>
  <tr>
    <td>Param/Key Suffix</td>
    <td>Concept</td>
    <td>Notes</td>
  </tr>
  <tr>
    <td>content</td>
    <td>a string containing the value to be used on the managed host e.g. a base64 encoded PEM blob used to populate a cert file on the managed host</td>
    <td>provide an unambiguous way for users to specify a blob value.  Also, the Ansible "copy" module uses "content" for the same purpose.  https://docs.ansible.com/ansible/latest/modules/copy_module.html#copy-module
Note that "key_content" is virtually identical to "password" - it is up to the role author to determine which usage is better for the role</td>
  </tr>
  <tr>
    <td>src</td>
    <td>path to file on controller host containing a certificate, ca_cert, key</td>
    <td>we have pre-existing use cases where the user wants to specify the name of a file on the controller node, and doesn't want to or cannot specify the value as a blob in "contents".  Also, the Ansible "copy" module uses "src" for the same purpose.  https://docs.ansible.com/ansible/latest/modules/copy_module.html#copy-module</td>
  </tr>
</table>

## Table of Name Prefixes With Explanation
<table>
  <tr>
    <td>Param/Key Prefix</td>
    <td>Concept</td>
    <td>Notes</td>
  </tr>
  <tr>
    <td>client</td>
    <td>Used with "cert" and "private_key" to denote that this is the client cert and key</td>
    <td>Use this if you need to emphasize that the cert specified is for client purposes only, or if you need to distinguish between client and server certificates</td>
  </tr>
  <tr>
    <td>server</td>
    <td>Used with "cert" and "private_key" to denote that this is the server cert and key</td>
    <td>Use this if you need to emphasize that the cert specified is for server purposes only, or if you need to distinguish between client and server certificates</td>
  </tr>
  <tr>
    <td>x509</td>
    <td>Used with "private_key" to denote that this is an x509 private key</td>
    <td>Only use this if you need to distinguish between different private key types e.g. if your role can take both x509 and ssh keys or other types of private keys</td>
  </tr>
  <tr>
    <td>ssh</td>
    <td>Used with "private_key" or "public_key" to denote that this is an ssh key</td>
    <td>Only use this if you need to distinguish between different private key types e.g. if your role can take both x509 and ssh keys or other types of private keys - the use of "ssh_public_key" is optional, but your role may choose to support it if it makes the role look more consistent to have both "ssh_public_key" and "ssh_private_key".</td>
  </tr>
  <tr>
    <td>encryption</td>
    <td>Used with "key" and "password"</td>
    <td>For example, "encryption_key_src" and "encryption_password" are used in storage to denote the LUKS unlock key file/passphrase.  Similar usage in nbde_client for clevis.</td>
  </tr>
  <tr>
    <td>root</td>
    <td>Used with "ca_cert" to denote that this is one or more root CA certs</td>
    <td>Only use this if you need to distinguish between root CA certs and intermediate CA certs</td>
  </tr>
  <tr>
    <td>intermediate</td>
    <td>Used with "ca_cert" to denote that this is one or more intermediate CA certs</td>
    <td>Only use this if you need to distinguish between root CA certs and intermediate CA certs</td>
  </tr>
</table>
