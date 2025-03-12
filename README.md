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

As of early March 2025, there's a new Standalone Backup class. This will be part of the 8.6.12 release. For now, you can find zip files in the [releases page of this repo here](https://github.com/camunda-community-hub/camunda-8-init-and-backup/releases). 

Download and extract a copy of the latest zip file. 

Or, as a convenience, the latest zip file has been extracted into the [camunda/8.6.11-update-1](camunda/8.6.11-update-1) directory of this project. 

## Update application.properties file

Edit the [8.6.11-update-1/config/application.properties](camunda/8.6.11-update-1/config/application.properties) file found inside this project. Update the Elasticearch related connection and credential details to match appropriately for your environment. 

## Run schema migration tool

Change directory into [8.6.11-update-1](camunda/8.6.11-update-1). Execute `./bin/schema.bat` script for Windows, or the `./bin/schema` script for Linux or MacOS.

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



# Standalone Backup application usage

## Prerequisites
* The standalone backup application requires cluster-level privileges to work properly 
  * This is only to make sure snapshots are created for the corresponding web app indices
* Download and unpack the distribution we have provided in [camunda/8.6.11-update-1](camunda/8.6.11-update-1) - under `bin/` folder you will find a script called: `backup-webapps` (for Windows `backup-webapps.bat`).
* When running the script, make sure you have Java v21+ installed on your machine
## Limitations
* This application was only tested with Elasticsearch 
* This application doesn’t take backups itself; it orchestrates the snapshotting of indices in Elasticsearch 
* This application only takes care of Operate and Tasklist indices; Optimize is not part of this procedure

## Backup procedure 
### Prepare Elasticsearch
Before we can run the backup procedure, we need to setup/configure Elasticsearch.

1. Set up a user with cluster-level privileges, which includes the creation of snapshots. [`snapshot_user`](https://www.elastic.co/guide/en/elasticsearch/reference/current/built-in-roles.html#:~:text=related%20to%20rollups.-,snapshot_user,-Grants%20the%20necessary) predefined role should be enough to run the standalone backup.
2. Create a [snapshot repository](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html) in Elasticsearch

### Create configuration
Similar to the [standalone schema manager](https://docs.camunda.io/docs/self-managed/concepts/elasticsearch-without-cluster-privileges/#11-configure-schema-manager) application, we need a configuration file to set the connection, credentials and snpashot repository are in the application.

1. Configure the Elasticsearch user having the cluster privilges, for both Operate and Tasklist properties.
2. Configure the repository name, for both Operate and Tasklist properties.

Store the following file and adjust it to your needs.

`backup-manager.yml`:

```yaml
camunda:
  operate:
    backup:
      repositoryName: "els-test"
    elasticsearch:
      # Example assuming an existing user called 'camunda-admin'
      username: camunda-admin
      password: camunda123
      # Example assuming Elasticsearch is accessible at http://localhost:9200
      url: http://localhost:9200
      healthCheckEnabled: false
  tasklist:
    backup:
      repositoryName: "els-test"
    elasticsearch:
      # Example assuming an existing user called 'camunda-admin'
      username: camunda-admin
      password: camunda123
      # Example assuming Elasticsearch is accessible at http://localhost:9200
      url: http://localhost:9200

      url: http://localhost:9200
      healthCheckEnabled: false
```


### Trigger backup

Similar to what we have documented [here](https://docs.camunda.io/docs/self-managed/operational-guides/backup-restore/backup-and-restore/#backup-process), we can do a backup while 1.-6. steps are replaced with the new standalone backup application.

For that, run:

```shell
cd ./camunda/8.6.11-update-1
SPRING_CONFIG_ADDITIONALLOCATION=backup-manager.yml ./bin/backup-webapps <backupID>
```

where <backupID> is the unique identifier of the backup, used as part of the snapshot names, etc. You can find more details about this in our [documentation](https://docs.camunda.io/docs/self-managed/operational-guides/backup-restore/backup-and-restore/#backup-process).

The standalone application will wait until the snapshots/backup is complete, then exits with code 0 when it is succesful. It will log the state the backups every 5 seconds.
Afterward, the user can continue with point 7 of our [backup procedure](https://docs.camunda.io/docs/self-managed/operational-guides/backup-restore/backup-and-restore/#backup-process). For completeness, they are documented next as well.


7. Soft pause exporting in Zeebe. See Zeebe management API.
8. Take a backup x of the exported Zeebe records in Elasticsearch using the Elasticsearch Snapshots API.
```
PUT /_snapshot/my_repository/camunda_zeebe_records_backup_x
{
  "indices": "zeebe-record*",
  "feature_states": ["none"]
}
```
9. Wait until the backup x of the exported Zeebe records is complete before proceeding. Take a backup x of Zeebe. See how to take a Zeebe backup.
10. Wait until the backup x of Zeebe is completed before proceeding. See how to monitor a Zeebe backup. Resume exporting in Zeebe. See Zeebe management API.

<strong>Important:</strong>
If any of the steps above fail, you may need to restart with a new backup id. Ensure exporting is resumed if the backup process force quits in the middle of the process.

### Restore:
To restore a backup, please follow the steps documented in our [documentation](https://docs.camunda.io/docs/self-managed/operational-guides/backup-restore/backup-and-restore/#restore).



