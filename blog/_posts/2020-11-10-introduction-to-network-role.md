---
layout: post
title: "Introduction to Network Role"
section: Blog
date: 2020-11-10T12:00:00
author: Wen Liang
category: talk
---
## Introduction

The network role supports two providers: NetworkManager(nm) and initscripts. For
CentOS/RHEL 6, we only use initscripts as providers. For CentOS/RHEL 7+, we use
initscripts and nm as providers. Various networking profiles can be configured via
customized Ansible module. Several tasks will run for host networking setup, including
but not limited to, package installation, starting/enabling services. Network role CI
system  consists of Tox running unit tests and Test-harness running integration
tests. When we use Tox to run unit tests,  we can check code formatting using
Python Black, check YAML files formatting etc. Integration tests run in internal
OpenShift, watch configured GitHub repositories for PRs, check out new PR, run
all testing playbooks against all configured images, fresh machine for every test
playbook, sets statuses of PR and uploads results. For better testing efficiency,
in some playbooks, we can call internal Ansible modules instead of role to skip
redundant tasks, we can also group Ansible modules into blocks for more targeted
unit testing. Furthermore, there are helper scripts to get coverage from integration
tests via Ansible, basic unit for argument parsing, additional helper files for
assertion/test setup/logging.

## Code structure

The repository is structured as follows:
- `./defaults/ ` – Contains the default role configuration.
- `./examples/` – Contains YAML examples for different configurations.
- `./library/network_connections.py` – Contains the internal Ansible module,
which is the main script. It controls the communication between the role and
Ansible, imports the YAML configuration and applies the changes to the provider
(i.e. NetworkManager, initscripts).
- `./meta/` – Metadata of the project.
- `./module_utils/network_lsr/` – Contains other files that are useful for the
network role (e.g. the YAML argument validator)
- `./tasks/` – Declaration of the different tasks that the role is going to execute.
- `./tests/playbooks/` – Contains the complete tests for the role.
- `./tests/tests_*.yml` are shims to run tests once for every provider.
- `./tests/tasks/` contains task snippets that are used in multiple tests to avoid
having the same code repeated multiple times.
- Each file matching `tests_*.yml` is a test playbook which is run by the CI system.

## How to run test

#### Tox Unit Tests
- `tox -l`, list all the unit testing, available unit testing options are:

  * black
  * pylint
  * flake8
  * yamllint
  * py26
  * py27
  * py36
  * py37
  * py38
  * collection
  * custom

- tox, run all the tests
- tox -e py36, `py36` is pyunit testing with Python 3.6
- tox -e yamllint, Check the YAML files are correctly formatted
- tox -e black, Check the formatting of the code with Python Black
- ...

#### Integration Test

- Download CentOS 6, CentOS 7, CentOS 8, Fedora images from
  * https://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud-1907.qcow2c
  * https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2003.qcow2c
  * https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2
  * https://kojipkgs.fedoraproject.org/compose/cloud/
- Install "standard-test-roles-inventory-qemu" package
  ```bash
  dnf install standard-test-roles-inventory-qemu
  ```
- [TEST_DEBUG=1] TEST_SUBJECTS=<image> ansible-playbook -v[v] -i <inventory file/script> <tests_….yml> 
  ```bash
  TEST_SUBJECTS=CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 ansible-playbook -v -i /usr/share/ansible/inventory/standard-inventory-qcow2 tests/tests_default.yml
  ```

## Overview

Network role enables users to configure the network on the target machine. This
role can be used to configure:

- Ethernet interfaces
- Bridge interfaces
- Bonded interfaces
- VLAN interfaces
- MacVLAN interfaces
- Infiniband interfaces
- Wireless (WiFi) interfaces
- IP configuration
- 802.1x authentication



## Examples of Connections

The network role updates or creates all connection profiles on the target system
as specified in the network_connections variable, which is a list of dictionaries
that include specific options.

#### Configuring Ethernet:

```yaml
network_connections:
  - name: eth0
    #persistent_state: present  # default
    type: ethernet
    autoconnect: yes
    mac: 00:00:5e:00:53:5d
    ip:
      dhcp4: yes
```

#### Configuring Bridge:

```yaml
network_connections:
  - name: internal-br0
    interface_name: br0
    type: bridge
    ip:
      dhcp4: no
      auto6: no
```

#### Configuring Bonded Interface:

```yaml
network_connections:
  - name: br0-bond0
    type: bond
    interface_name: bond0
    controller: internal-br0
    port_type: bridge

  - name: br0-bond0-eth1
    type: ethernet
    interface_name: eth1
    controller: br0-bond0
    port_type: bond
```

#### Configuring VLANs:

```yaml
network_connections:
  - name: eth1-profile
    autoconnet: no
    type: ethernet
    interface_name: eth1
    ip:
      dhcp4: no
      auto6: no

  - name: eth1.6
    autoconnect: no
    type: vlan
    parent: eth1-profile
    vlan:
      id: 6
    ip:
      address:
        - 192.0.2.5/24
      auto6: no
```

#### Configuring Infiniband:

```yaml
network_connections:
  - name: ib0
    type: infiniband
    interface_name: ib0

  # Create a simple infiniband profile
  - name: ib0-10
    interface_name: ib0.000a
    type: infiniband
    autoconnect: yes
    infiniband_p_key: 10
    parent: ib0
    state: up
    ip:
      dhcp4: no
      auto6: no
      address:
        - 198.51.100.133/30
```

#### Configuring MACVLAN:
```yaml
network_connections:
  - name: eth0-profile
    type: ethernet
    interface_name: eth0
    ip:
      address:
        - 192.168.0.1/24

  - name: veth0
    type: macvlan
    parent: eth0-profile
    macvlan:
      mode: bridge
      promiscuous: yes
      tap: no
    ip:
      address:
        - 192.168.1.1/24
```

#### Configuring a wireless connection:

```yaml
network_connections:
  - name: wlan0
    type: wireless
    interface_name: wlan0
    wireless:
      ssid: "My WPA2-PSK Network"
      key_mgmt: "wpa-psk"
      # recommend vault encrypting the wireless password
      # see https://docs.ansible.com/ansible/latest/user_guide/vault.html
      password: "p@55w0rD"
```

#### Setting the IP configuration:

```yaml
network_connections:
  - name: eth0
    type: ethernet
    ip:
      route_metric4: 100
      dhcp4: no
      #dhcp4_send_hostname: no
      gateway4: 192.0.2.1

      dns:
        - 192.0.2.2
        - 198.51.100.5
      dns_search:
        - example.com
        - subdomain.example.com

      route_metric6: -1
      auto6: no
      gateway6: 2001:db8::1

      address:
        - 192.0.2.3/24
        - 198.51.100.3/26
        - 2001:db8::80/7

      route:
        - network: 198.51.100.128
          prefix: 26
          gateway: 198.51.100.1
          metric: 2
        - network: 198.51.100.64
          prefix: 26
          gateway: 198.51.100.6
          metric: 4
      route_append_only: no
      rule_append_only: yes
```

#### Configuring 802.1x:
```yaml
network_connections:
  - name: eth0
    type: ethernet
    ieee802_1x:
      identity: myhost
      eap: tls
      private_key: /etc/pki/tls/client.key
      # recommend vault encrypting the private key password
      # see https://docs.ansible.com/ansible/latest/user_guide/vault.html
      private_key_password: "p@55w0rD"
      client_cert: /etc/pki/tls/client.pem
      ca_cert: /etc/pki/tls/cacert.pem
      domain_suffix_match: example.com
```


## Reference

1. The external landing page for the system roles project, https://linux-system-roles.github.io/
2. The external network role docs, https://github.com/linux-system-roles/network/
