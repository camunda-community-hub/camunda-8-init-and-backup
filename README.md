[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![Lifecycle; Incubating](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#proof-of-concept-)[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Compatible with: Camunda Platform 8](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%208-0072Ce)

> [!WARNING]  
> Camunda extensions found in the Camunda Community Hub are maintained by the community and are not part of the commercial Camunda product. Camunda does not support community extensions as part of its commercial services to enterprise customers.


Questions: 

- Optimize?
- Delete Schema?


# Camunda 8 Init and Backup Scripts

By default, the Camunda 8 applications will attempt to create Elasticsearch objects (such as [index templates](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html)) during first start. 

These operations require [Elasticsearch cluster level access](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-privileges/).

However, in some cases, because of security policies, it is not possible to grant the Camunda applications the necessary [elastic search cluster level](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-privileges/) access to initialize Elasticsearch Objects.

As a possible workaround to this problem, this project contains scripts that can be run independently of a Camunda 8 installation to initialize Elasticsearch Objects.

TODO: is this still the case?
Scripts for Optimize are currently not available.

> [!WARNING]  
> This is experimental code part of a proof of concept that Camunda presales is working on to explore options for creating elasticsearch schemas

# Prerequisites

TODO: 
- Java (what version?) (hopefully jdk 21)
- Elasticsearch with Security Enabled. [See here]() for a guide on how to setup Elasticsearch in Kubernetes
- Able to connect to elasticsearch from wherever this client is run

# Usage

## Obtain a camunda release zip file

TODO: explain how to do this
https://github.com/camunda/camunda/releases
https://github.com/camunda/camunda/issues/25922#issuecomment-2536985190

## Update application.yaml config

TODO: explain this

## Run schema migration tool

TODO: Finish this

Change directories into the [camunda](camuda) directory and run `./bin/schema`

## Delete Elasticsearch Objects ??

TODO: can we use this?

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
# Create Camunda Roles and Users

## Create Elasticsearch role and user for Zeebe

Create Role

```shell
curl --location 'http://localhost:9200/_security/role/zeebe-role' \
--header 'Content-Type: application/json' \
--user elastic:camunda \
--data '{
    "description": "Grants access to zeebe indices",
    "cluster": [],
    "indices": [
        {
            "names": [ "zeebe*" ],
            "privileges": [
                "create_index",
                "delete_index",
                "read",
                "write",
                "manage",
                "manage_ilm"
            ]
        }
    ]
}'
```

Create User

```shell
curl --location 'http://localhost:9200/_security/user/zeebe' \
--header 'Content-Type: application/json' \
--user elastic:camunda \
--data '{
    "password": "camunda",
    "roles": "zeebe-role"
}'
```

## Create Elasticsearch role and user for Operate

Create Role

```shell
curl --location 'http://localhost:9200/_security/role/operate-role' \
--header 'Content-Type: application/json' \
--user elastic:camunda \
--data '{
    "description": "Grants access to operate indices",
    "cluster": [],
    "indices": [
        {
            "names": [ "operate*" ],
            "privileges": [
                "create_index",
                "delete_index",
                "read",
                "write",
                "manage",
                "manage_ilm"
            ]
        }
    ]
}'
```

Create User

```shell
curl --location 'http://localhost:9200/_security/user/operate' \
--header 'Content-Type: application/json' \
--user elastic:camunda \
--data '{
    "password": "camunda",
    "roles": "operate-role,zeebe-role"
}'
```

## Create Elasticsearch role and user for Tasklist

Create role

```shell
curl --location 'http://localhost:9200/_security/role/tasklist-role' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic ZWxhc3RpYzpjYW11bmRh' \
--data '{
    "description": "Grants access to tasklist indices",
    "cluster": [],
    "indices": [
        {
            "names": [ "tasklist*" ],
            "privileges": [
                "create_index",
                "delete_index",
                "read",
                "write",
                "manage",
                "manage_ilm"
            ]
        }
    ]
}'
```

Create user

```shell
curl --location 'http://localhost:9200/_security/user/tasklist' \
--header 'Content-Type: application/json' \
--user elastic:camunda \
--data '{
    "password": "camunda",
    "roles": "tasklist-role,zeebe-role"
}'
```

# Elasticsearch in Kubernetes

TODO: share Camunda K8s values.yaml file

## Possible Issues

### Incompatible Kibana Version

If you use Camunda Helm chart `11.2.0`, it will install Elasticsearch `8.15.4`. It seems that elasticsearch helm chart will install Kibana `8.17.0` by default and when this happens you might see this inside Kibana logs: 

```shell
kibana [2025-02-10T15:21:28.109+00:00][ERROR][elasticsearch-service] This version of Kibana (v8.17.0) is incompatible with the following Elasticsearch nodes in your cluster: v8.15.4
```

The fix is to explicitly set the kibana version inside your values.yaml file. The sample used in this guide solves this issue. 

### http_ca.crt - No such file or directory

TODO: verify this. 

The files shared [here](https://github.com/camundakev/camunda-schema-generation-8.6) might have a http_ca.crt hard coded somewhere? If so, you might see this exception when running `./schema`

```shell
Caused by: java.io.FileNotFoundException: C:/Users/ruecker/Downloads/elasticsearch-8.14.0-windows-x86_64/elasticsearch-8.14.0/config/certs/http_ca.crt (No such file or directory)
```

### Failed to execute goal com.diffplug.spotless-maven-plugin

When attempting to build camunda from source, maven throws this exception: 

```shell
[ERROR] Failed to execute goal com.diffplug.spotless:spotless-maven-plugin:2.44.2:apply (spotless-format) on project zeebe-cluster-config: Unable to format file /Users/dave/code/camunda/zeebe/dynamic-config/src/main/java/io/camunda/zeebe/dynamic/config/serializer/ProtoBufSerializer.java: com.google.googlejavaformat.java.FormatterException: 433:15: error: illegal start of expression -> [Help 1]
```

### compilation error - illegal start of expression

This seems to be something related to the version of java? I got this with jdk 21. Trying again with java version 23 ...

```shell
Compilation failure: Compilation failure: [ERROR] /Users/dave/code/camunda/zeebe/dynamic-config/src/main/java/io/camunda/zeebe/dynamic/config/serializer/ProtoBufSerializer.java:[507,39] illegal start of expression
```

