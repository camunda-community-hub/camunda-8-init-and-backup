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

The java program will attempt to connect to Elasticsearch via rest api. You can optionally verify connectivity to elasticsearch by running the following curl command

```shell
curl --location 'http://localhost:9200/_cluster/health' \
--user YOUR_ES_USER:YOUR_ES_PASSWORD
```

## (Optionally) Obtain Latest Camunda Release

As of early February 2025, there's a new Schema Generator class available on the main branch. We are hoping to release as part of an official release asap. 

When the schema generator is available as part of official release, it will be published here. 

https://github.com/camunda/camunda/releases

In the meantime, a prebuilt version can be found inside the `camunda` directory of this project. 

It's also possible to build from source by cloning the following branch: 

https://github.com/camunda/camunda/tree/25922-standalone-schema-manager-8.6.8

Then build the project located inside the `dist` directory. A successful build should produce several archives under `dist/target/`. For example, after extracting `src/dist/target/camunda-zeebe-8.6.8.tar.gz` you will see `bin`, `config`, and `lib` directories. Copy those directories into the `camunda` directory inside this project to use your custom-built version. 

## Update application.yaml config

Edit the `camunda/config/application.yaml` file found inside this project and update the Elasticearch connection and credential details. 

## Run schema migration tool

Change directory into `camunda`. Execute the `./bin/schema` shell script for Linux or MacOS. Execute `./bin/schema.bat` script for Windows.

This will produce a `camunda/logs` directory. Check the logs to make sure there are no `ERROR`. 

Change directories into the [camunda](camuda) directory and run `./bin/schema`

## Delete Elasticsearch Objects

There is a script file named `./init/delete.sh` that uses `curl` to send rest api requests to delete Elasticsearch objects related to Camunda. 

# Scripts for Camunda Roles and Users

## Create Elasticsearch role and user for Zeebe

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

# Install Elasticsearch and Kibana in Kubernetes

See [camunda-values-es-kibana.yaml](docs/camunda-values-es-kibana.yaml) for an example Camunda Values file that demonstrates: 
- How to disable ES health checks for Tasklist and Operate
- How to disable Schema Creation for Tasklist and Operate
- How to deploy a small sized Elasticsearch and Kibana for testing

## Possible Issues

### Incompatible Kibana Version

If you use Camunda Helm chart `11.2.0`, it will install Elasticsearch `8.15.4`. It seems that elasticsearch helm chart will install Kibana `8.17.0` by default and when this happens you might see this inside Kibana logs: 

```shell
kibana [2025-02-10T15:21:28.109+00:00][ERROR][elasticsearch-service] This version of Kibana (v8.17.0) is incompatible with the following Elasticsearch nodes in your cluster: v8.15.4
```

The fix is to explicitly set the kibana version inside your values.yaml file. The sample used in this guide solves this issue. 


### Failed to execute goal com.diffplug.spotless-maven-plugin

When attempting to build camunda dist from source, maven throws this exception: 

```shell
[ERROR] Failed to execute goal com.diffplug.spotless:spotless-maven-plugin:2.44.2:apply (spotless-format) on project zeebe-cluster-config: Unable to format file /Users/dave/code/camunda/zeebe/dynamic-config/src/main/java/io/camunda/zeebe/dynamic/config/serializer/ProtoBufSerializer.java: com.google.googlejavaformat.java.FormatterException: 433:15: error: illegal start of expression -> [Help 1]
```

Java 23 is required to build the dist. 

### compilation error - illegal start of expression

When attempting to build camunda dist from source, maven throws this exception: 

```shell
Compilation failure: Compilation failure: [ERROR] /Users/dave/code/camunda/zeebe/dynamic-config/src/main/java/io/camunda/zeebe/dynamic/config/serializer/ProtoBufSerializer.java:[507,39] illegal start of expression
```

Java 23 is required to build the dist. 

