[![Community Extension](https://img.shields.io/badge/Community%20Extension-An%20open%20source%20community%20maintained%20project-FF4700)](https://github.com/camunda-community-hub/community)
[![Lifecycle; Incubating](https://img.shields.io/badge/Lifecycle-Proof%20of%20Concept-blueviolet)](https://github.com/Camunda-Community-Hub/community/blob/main/extension-lifecycle.md#proof-of-concept-)[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Compatible with: Camunda Platform 8](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%208-0072Ce)

> [!WARNING]  
> Camunda extensions found in the Camunda Community Hub are maintained by the community and are not part of the commercial Camunda product. Camunda does not support community extensions as part of its commercial services to enterprise customers.


# Camunda 8 Init and Backup Scripts

By default, the Camunda 8 applications will attempt to create Elasticsearch objects (such as [index templates](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html)) during first start. 

These operations require [Elasticsearch cluster level access](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-privileges/).

However, in some cases, because of security policies, it is not possible to grant the Camunda applications the necessary [elastic search cluster level](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-privileges/) access to initialize Elasticsearch Objects.

As a possible workaround to this problem, this project contains a standalone java program that can be run independently of a Camunda 8 installation to initialize Elasticsearch objects for Zeebe, Operate, and Task List.

> [!WARNING]  
> This is experimental code part of a proof of concept that Camunda presales is working on to explore options for creating elasticsearch schemas

# Usage

## Java JDK 21

Ensure you have a jdk 21 or higher installed. You can test by running the following command.  

```shell
java --version
```

For example, the output from the above command should look something like this:

```shell
java 21.0.4 2024-07-16 LTS
Java(TM) SE Runtime Environment (build 21.0.4+8-LTS-274)
Java HotSpot(TM) 64-Bit Server VM (build 21.0.4+8-LTS-274, mixed mode, sharing)
```

## Ensure you have connection to Elasticsearch

Verify connectivity to elasticsearch by running the following curl command. Remember to replace `$ELASTIC_UR`L, `$ELASTIC_USER`, and `$ELASTIC_PASSWORD` to match appropriately for your environment. 

```shell
curl --location '$ELASTIC_URL/_cluster/health' \
--user $ELASTIC_USER:$ELASTIC_PASSWORD
```

## Obtain latest version

As of early February 2025, there's a new Schema Generator class. This will be part of the 8.6.10 release. For now, you can find zip files in the releases page for this repo. 

As a convenience, the latest zip file has been extracted into the [camunda/8.6.8-update-3](camunda/8.6.8-update-3) directory of this project. 

## Update application.properties file

Edit the [camunda/8.6.8-update-3/config/application.properties](camunda/8.6.8-update-3/config/application.properties) file found inside this project. Update the Elasticearch related connection and credential details to match appropriately for your environment. 

## Run schema migration tool

Change directory into [camunda/8.6.8-update-3](camunda/8.6.8-update-3). Execute `./bin/schema.bat` script for Windows, or the `./bin/schema` script for Linux or MacOS.

This will produce a `./logs` directory. Check the logs to make sure there are no `ERROR`.

# Scripts for Camunda Roles and Users

The following are provided as guidance and convenience for how to create Elasticsearch users and roles. 

## Create Elasticsearch role to run the schema generator

This is an example of how to create a Elasticsearch role that grants cluster level access necessary to run the schema generator. 

```shell
curl --location 'http://localhost:9200/_security/role/zeebe-role' \
--header 'Content-Type: application/json' \
--user $ELASTIC_USER:$ELASTIC_PASSWORD \
--data '{
    "description": "Grants access to zeebe indices",
    "cluster": [],
    "indices": [
        {
            "names": [ "zeebe*" ],
            "privileges": [
                "monitor", 
                "manage_ilm", 
                "view_index_metadata", 
                "manage_index", 
                "manage_index_templates"
            ]
        }
    ]
}'
```

## Create Elasticsearch role for Zeebe

Create Role

```shell
curl --location 'http://localhost:9200/_security/role/zeebe-role' \
--header 'Content-Type: application/json' \
--user ES_ADMIN_USERNAME:ES_ADMIN_PASSWORD \
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
--user ES_ADMIN_USERNAME:ES_ADMIN_PASSWORD \
--data '{
    "password": "camunda",
    "roles": "zeebe-role, operate-role, tasklist-role"
}'
```

## Create Elasticsearch role and user for Operate

Create Role

```shell
curl --location 'http://localhost:9200/_security/role/operate-role' \
--header 'Content-Type: application/json' \
--user ES_ADMIN_USERNAME:ES_ADMIN_PASSWORD \
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
--user ES_ADMIN_USERNAME:ES_ADMIN_PASSWORD \
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
--user ES_ADMIN_USERNAME:ES_ADMIN_PASSWORD \
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
--user ES_ADMIN_USERNAME:ES_ADMIN_PASSWORD \
--data '{
    "password": "camunda",
    "roles": "tasklist-role,zeebe-role"
}'
```


