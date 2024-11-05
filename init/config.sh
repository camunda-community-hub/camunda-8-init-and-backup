#!/bin/bash
ES_URL="http://localhost:9200"
ES_USERNAME="elastic"
ES_PASSWORD="camunda"

DEFAULT_INDEX_DELIMITER="_"
VERSION=0.0.1
LOG_VERBOSITY='INFO'

#CURL_SECURITY_OPTIONS="--user ${ES_USERNAME}:${ES_PASSWORD}"
CURL_SECURITY_OPTIONS=""

# Zeebe
ZEEBE_VERSION=8.6.4
ZEEBE_INDEX_PREFIX="zeebe-record"
ZEEBE_INDEX_DELIMITER=${DEFAULT_INDEX_DELIMITER}
ZEEBE_ES_URL="${ES_URL}"
ZEEBE_ES_USER="${ES_USER}"
ZEEBE_ES_PASSWORD="${ES_PASSWORD}"

# Operate
OPERATE_INDEX_PREFIX=operate
OPERATE_INDEX_DELIMITER=${DEFAULT_INDEX_DELIMITER}
OPERATE_ES_URL="${ES_URL}"
OPERATE_ES_USER="${ES_USER}"
OPERATE_ES_PASSWORD="${ES_PASSWORD}"
OPERATE_NUMBER_OF_SHARDS=1
OPERATE_NUMBER_OF_REPLICAS=0

# Tasklist
TASKLIST_INDEX_PREFIX=tasklist
TASKLIST_INDEX_DELIMITER=${DEFAULT_INDEX_DELIMITER}
TASKLIST_ES_URL="${ES_URL}"
TASKLIST_ES_USER="${ES_USER}"
TASKLIST_ES_PASSWORD="${ES_PASSWORD}"
TASKLIST_NUMBER_OF_SHARDS=1
TASKLIST_NUMBER_OF_REPLICAS=0