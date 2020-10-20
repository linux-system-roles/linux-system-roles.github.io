---
layout: page
title: Current logging subsystem structure
---

It is designed to satisfy following requirements.

- Adding more logging systems such as fluentd, grafana loki, etc.
- Supporting flexible combinations of tasks in inputs and outputs such as input from files and/or journald and output to files and/or elasticsearch.
- More inputs and outputs will be added.
- The existing scenario, especially an input ovirt + output elasticsearch should not be affected by the updates.

```
logging/
├── ansible_pytest_extra_requirements.txt
├── COPYING
├── custom_requirements.txt
├── defaults
│   └── main.yml
├── LICENSE
├── meta
│   └── main.yml
├── molecule
│   └── default
│       ├── Dockerfile.j2
│       ├── INSTALL.rst
│       ├── molecule.yml
│       ├── playbook.yml
│       └── yaml-lint.yml
├── molecule_extra_requirements.txt
├── pylint_extra_requirements.txt
├── pylintrc
├── pytest_extra_requirements.txt
├── README.md
├── roles
│   └── rsyslog
│       ├── defaults
│       │   └── main.yml
│       ├── handlers
│       │   └── main.yml
│       ├── README.md
│       ├── tasks
│       │   ├── deploy.yml
│       │   ├── inputs
│       │   │   ├── basics
│       │   │   │   └── main.yml
│       │   │   ├── files
│       │   │   │   └── main.yml
│       │   │   ├── ovirt
│       │   │   │   └── main.yml
│       │   │   ├── relp
│       │   │   │   └── main.yml
│       │   │   └── remote
│       │   │       └── main.yml
│       │   ├── main.yml
│       │   ├── outputs
│       │   │   ├── elasticsearch
│       │   │   │   └── main.yml
│       │   │   ├── files
│       │   │   │   └── main.yml
│       │   │   ├── forwards
│       │   │   │   └── main.yml
│       │   │   ├── relp
│       │   │   │   └── main.yml
│       │   │   └── remote_files
│       │   │       └── main.yml
│       │   └── set_certs.yml
│       ├── templates
│       │   ├── global.j2
│       │   ├── input_basics.j2
│       │   ├── input_basics_rhel7.j2
│       │   ├── input_ovirt.j2
│       │   ├── input_relp.j2
│       │   ├── input_remote.j2
│       │   ├── input_remote_module.j2
│       │   ├── input_template.j2
│       │   ├── output_elasticsearch.j2
│       │   ├── output_files.j2
│       │   ├── output_forwards.j2
│       │   ├── output_relp.j2
│       │   ├── output_remote_files.j2
│       │   ├── rsyslog.conf.j2
│       │   └── rules.conf.j2
│       └── vars
│           ├── CentOS_7.yml -> RedHat_7.yml
│           ├── default.yml
│           ├── inputs
│           │   ├── basics
│           │   │   └── main.yml
│           │   ├── files
│           │   │   └── main.yml
│           │   ├── ovirt
│           │   │   └── main.yml
│           │   ├── relp
│           │   │   └── main.yml
│           │   └── remote
│           │       └── main.yml
│           ├── main.yml
│           ├── outputs
│           │   ├── elasticsearch
│           │   │   └── main.yml
│           │   ├── files
│           │   │   └── main.yml
│           │   ├── forwards
│           │   │   └── main.yml
│           │   ├── relp
│           │   │   └── main.yml
│           │   └── remote_files
│           │       └── main.yml
│           └── RedHat_7.yml
├── tasks
│   └── main.yml
├── tests
│   ├── README.md
│   ├── roles
│   │   ├── caller
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── vars
│   │   │       └── main.yml
│   │   └── linux-system-roles.logging -> ../..
│   ├── run8.sh
│   ├── set_rsyslog_variables.yml
│   ├── setup_module_utils.sh
│   ├── tasks
│   │   └── create_tests_certs.yml
│   ├── tests_basics_files2_missing_flows.yml
│   ├── tests_basics_files2.yml
│   ├── tests_basics_files_forwards.yml
│   ├── tests_basics_files_log_dir.yml
│   ├── tests_basics_files.yml
│   ├── tests_basics_forwards_cacert.yml
│   ├── tests_basics_forwards_cert_missing.yml
│   ├── tests_basics_forwards_cert.yml
│   ├── tests_basics_forwards_implicit_files.yml
│   ├── tests_basics_forwards.yml
│   ├── tests_combination2.yml
│   ├── tests_combination_absent.yml
│   ├── tests_combination.yml
│   ├── tests_default.yml
│   ├── tests_enabled.yml
│   ├── tests_files_elasticsearch_certs_incomplete.yml
│   ├── tests_files_elasticsearch_use_cert_false_with_keys.yml
│   ├── tests_files_elasticsearch_use_local_cert_all.yml
│   ├── tests_files_elasticsearch_use_local_cert_nokeys.yml
│   ├── tests_files_elasticsearch_use_local_cert.yml
│   ├── tests_files_files.yml
│   ├── tests_imuxsock_files.yml
│   ├── tests_include_vars_from_parent.yml
│   ├── tests_ovirt_elasticsearch_params.yml
│   ├── tests_ovirt_elasticsearch.yml
│   ├── tests_relp_client.yml
│   ├── tests_relp_server.yml
│   ├── tests_remote_default_remote.yml
│   ├── tests_remote_remote.yml
│   ├── tests_server_conflict.yml
│   ├── tests_server.yml
│   └── tests_version.yml
└── tox.ini
```

# How Logging role starts

When ansible-playbook is executed with a playbook pointing to the logging role,
it starts with tasks in logging/tasks/main.yml.
In the tasks, it evaluates the `logging_outputs`, `logging_inputs`, and `logging_flow` parameters in the loop
to pass the dictionaries to each subtasks and subvars.
The following is a format of the outputs/inputs/flows parameters for the `files` and `forwards` output.

## inputs/outputs/flows
```
logging_outputs: [1]
  - name: unique_output_name
    type: output_type [2]
	<<other_parameters>
  - name: unique_output_name
        .................
logging_inputs: [3]
  - name: unique_input_name
    type: input_type [4]
	<<other_parameters>
  - name: unique_input_name
        .................
logging_flows: [5]
  - name: unique_flow_name
    inputs: [ unique_input_name, ... ] [6]
    outputs: [ unique_output_name, ... ] [7]
  - name: unique_flow_name
        .................
```
`[1]`: `logging_outputs` are implemented in logging/roles/rsyslog/tasks/outputs/ and logging/roles/rsyslog/vars/outputs/.<br>
`[2]`: `output_type` is one of [elasticsearch, files, forwards, relp, remote_files]; the type matches the directory name in the `outputs` directory.<br>
`[3]`: `logging_inputs` are implemented in ./logging/roles/rsyslog/tasks/inputs/ and ./logging/roles/rsyslog/vars/inputs/.<br>
`[4]`: `input_type is one of [basics, files, ovirt, relp, remote]; the type matches the directory name in the `inputs` directory.<br>
`[5]`: logging_flows are used in the inputs (inputs/{basics,files,etc.}) to set the `call output_ruleset`.
`[6]`: inputs contains the list of unique_input_name(s).
`[7]`: outputs contains the list of unique_output_name(s).
