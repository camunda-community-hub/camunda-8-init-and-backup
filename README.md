[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![Lifecycle; Incubating](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#proof-of-concept-)[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Compatible with: Camunda Platform 8](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%208-0072Ce)

> [!WARNING]  
> Camunda extensions found in the Camunda Community Hub are maintained by the community and are not part of the commercial Camunda product. Camunda does not support community extensions as part of its commercial services to enterprise customers.

# Camunda 8 Init and Backup Scripts

By default, the Camunda 8 applications will attempt to create Elasticsearch objects (such as [index templates](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html)) during first start. Camunda components also make use of Elasticsearch Snapshot Repositories and snapshot API's to run the official [Camunda Backup steps](https://docs.camunda.io/docs/self-managed/operational-guides/backup-restore/backup-and-restore/).

These operations require [Elasticsearch cluster level access](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-privileges/).

However, in some cases, because of security policies, it is not possible to grant the Camunda applications the necessary [elastic search cluster level](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-privileges/) access to initialize Elasticsearch Objects or perform backups.

As a possible workaround to this problem, this project contains scripts that can be run independently of a Camunda 8 installation to initialize Elasticsearch Objects and create backups for Camunda 8 Zeebe, Operate, and Tasklist.

Scripts for Optimize are currently not available.

> [!WARNING]  
> This is experimental code part of a proof of concept that Camunda presales is working on to understand whether it's possible to manually manage elasticsearch objects with bash scripts outside the Camunda java applications.

# Usage

The scripts in this project require [curl](https://curl.se/), [jq](https://jqlang.github.io/jq/) as well as several other command line tools such as `tail`, and `sed`.

## Initialize Elasticsearch Objects

Change directories into the [init](init) directory. Then edit the [init/config.sh](init/config.sh) and set appropriate values for your environment. Then run `./init.sh` for available options and commands:

```shell
$> ./init.sh
INFO: Starting Camunda init.sh ...
INFO: LOG_VERBOSITY is set to: INFO
INFO: Usage for init.sh:
INFO:
INFO: Options:
INFO:   --help                    Display this help message
INFO:   --v <LOG_VERBOSITY>       Controls the verbosity of logs written to stdout.
INFO:                             Default is DEBUG. Set to one of DEBUG, INFO, WARN, ERROR
INFO: Commands:
INFO:   zeebe         initialize ES objects for Zeebe
INFO:   operate       initialize ES objects for Operate
INFO:   tasklist      initialize ES objects for Tasklist
INFO:   all           initialize ES objects for all Camunda Components
```

## Delete Elasticsearch Objects

Change directories into the [init](init) directory. Then edit the [init/config.sh](init/config.sh) and set appropriate values for your environment. Then run `./delete.sh` for available options and commands:

```shell
$> ./delete.sh
INFO: Starting Camunda delete.sh script ...
INFO: LOG_VERBOSITY is set to: INFO
INFO: Usage for delete.sh:
INFO:
INFO: Options:
INFO:   --help                    Display this help message
INFO:   --v <LOG_VERBOSITY>       Controls the verbosity of logs written to stdout.
INFO:                             Default is DEBUG. Set to one of DEBUG, INFO, WARN, ERROR
INFO: Commands:
INFO:   zeebe         delete ES objects for Zeebe
INFO:   operate       delete ES objects for Operate
INFO:   tasklist      delete ES objects for Tasklist
INFO:   all           delete ES objects for all Camunda Components
```