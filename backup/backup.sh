#! /bin/bash
PROJECT_DIR="./.."

source ${PROJECT_DIR}/backup/config.sh
source ${PROJECT_DIR}/common/functions.sh

SCRIPT_NAME="delete.sh"

function help() {
  info "Usage for ${SCRIPT_NAME}: "
  info ""
  info "Options: "
  info "  --help                    Display this help message"
  info "  --v <LOG_VERBOSITY>       Controls the verbosity of logs written to stdout."
  info "                            Default is DEBUG. Set to one of DEBUG, INFO, WARN, ERROR"
}

OPTIND=1
COMMAND_RUN=false

# Parse options
while getopts hv: opt; do
  case "${opt}" in
  h)
    debug "option -h was triggered"
    help
    exit 1
    ;;
  v)
    LOG_VERBOSITY=${OPTARG}
    debug "option -v was triggered"
    ;;
  *)
    ;;
  esac
done

info "Starting Camunda ${SCRIPT_NAME} ..."
info "LOG_VERBOSITY is set to: ${LOG_VERBOSITY}"

function lookup_trigger_snapshot_operate() {

  idx_passed=$1
  shift
  local arr=("$@")  

  local idx=0
  for i in "${!arr[@]}"
  do
    idx_name=${arr[$i]}
    if [[ $idx_name = "${idx_passed}"* ]]; then
      debug "\n Found! - $idx_name "
      trigger_es_snapshot_operate $idx_name
      idx=$i
      break
    fi
    
  done

#  printf "\n\n"

  return "$idx"

}


## create operate shapshot 1 - comma separated list of indices
function trigger_es_snapshot_operate() {
  
#   printf "\n\n"
  
  BACKUP_COUNTER=BACKUP_COUNTER+1
  local operate_snapshot_start_endpoint="${OPERATE_BACKUP_SNAPSHOT_REPO_ENDPOINT}/camunda_operate_snapshot_${BACKUP_ID}_${BACKUP_COUNTER}?wait_for_completion=true"

  CURL_REQUEST="PUT"
  CURL_URL="${operate_snapshot_start_endpoint}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat <<EOF
  {
    "indices": "${1}",
  }
EOF
)

  doCurl
}

function lookup_trigger_snapshot_optimize() {

  idx_passed=$1
  shift
  local arr=("$@")  

  local idx=0
  for i in "${!arr[@]}"
  do
    idx_name=${arr[$i]}
    if [[ $idx_name = "${idx_passed}"* ]]; then
      printf "\n Found! - $idx_name \n"    
      trigger_es_snapshot_optimize $idx_name
      idx=$i
      break
    fi
    
  done

  return "$idx"

}

## create tasklist shapshot 1 - comma separated list of indices
function trigger_es_snapshot_optimize() {

  BACKUP_COUNTER=BACKUP_COUNTER+1
  local optimize_snapshot_start_endpoint="${OPTIMIZE_BACKUP_SNAPSHOT_REPO_ENDPOINT}/camunda_optimize_snapshot_${BACKUP_ID}_${BACKUP_COUNTER}?wait_for_completion=true"

  CURL_REQUEST="PUT"
  CURL_URL="${optimize_snapshot_start_endpoint}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat <<EOF
  {
    "indices": "${1}",
  }
EOF
)

  debug ${CURL_DATA}

  doCurl
}

function lookup_trigger_snapshot_tasklist() {

  idx_passed=$1
  shift
  local arr=("$@")  

  debug "Passed index - $idx_passed"

  local idx=0
  for i in "${!arr[@]}"
  do
    idx_name=${arr[$i]}
    if [[ $idx_name = "${idx_passed}"* ]]; then
      debug "\n Found! - $idx_name  \n"
      trigger_es_snapshot_tasklist $idx_name
      idx=$i
      # break
    fi
    
  done

  return "$idx"

}

## create tasklist shapshot 1 - comma separated list of indices
function trigger_es_snapshot_tasklist() {

  debug "${1}"
  BACKUP_COUNTER=BACKUP_COUNTER+1
  local tasklist_snapshot_start_endpoint="${TASKLIST_BACKUP_SNAPSHOT_REPO_ENDPOINT}/camunda_tasklist_snapshot_${BACKUP_ID}_${BACKUP_COUNTER}?wait_for_completion=true"

  CURL_REQUEST="PUT"
  CURL_URL="${tasklist_snapshot_start_endpoint}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat <<EOF
  {
    "indices": "${1}",
    "features_states": ["none"]
  }
EOF
)

  doCurl
}

## create zeebe shapshot 1 - comma separated list of indices
function trigger_es_snapshot_zeebe() {

  debug "${1}"
  BACKUP_COUNTER=BACKUP_COUNTER+1
  local zeebe_snapshot_start_endpoint="${ZEEBE_BACKUP_SNAPSHOT_REPO_ENDPOINT}/camunda_zeebe_snapshot_${BACKUP_ID}_${BACKUP_COUNTER}?wait_for_completion=true"

  CURL_REQUEST="PUT"
  CURL_URL="${zeebe_snapshot_start_endpoint}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat <<EOF
  {
    "indices": "${1}",
    "features_states": ["none"]
  }
EOF
)

  doCurl
}

function getESIndices() {

  info "Getting all indices from ES ..."

  CURL_REQUEST="GET"
  CURL_URL="${ES_URL}/_cat/indices"
  CURL_HEADER="Accept: application/json"
  CURL_OUTPUT="es-indices.json"

  doCurl
}

function createSnapshotRepo() {

  info "Creating snapshot repo ${SNAPSHOT_REPO_ENDPOINT} ..."

  CURL_REQUEST="PUT"
  CURL_URL="${SNAPSHOT_REPO_ENDPOINT}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat <<EOF
  {
    "type": "s3",
    "settings": {
      "bucket": "${S3_BUCKET_NAME}"
    }
  }
EOF
)

  doCurl
}

# OPTIMIZE

function createOptimizeSnapshotRepo() {
  ## Step 0 - create optimize snapshot repo
  SNAPSHOT_REPO_ENDPOINT=${OPTIMIZE_BACKUP_SNAPSHOT_REPO_ENDPOINT}
  createSnapshotRepo
}

#######################################################################################################################
# Optimize backup steps
#    Part 1:
# [index-prefix]-import-index
# [index-prefix]-timestamp-based-import-index
# [index-prefix]-position-based-import-index
#
#######################################################################################################################
function createOptimizeSnapshot() {

  ## Pass 1 - read through the list of indices, check if the name is one in Part 1 list and then trigger backup

  info "Gathering indices for Optimize ..."
  jq -r '.[] | select(.index|test("^optimize.")) | .index' "${PROJECT_DIR}/backup/es-indices.json"  > optimize.txt

  arr=()
  while read line; do
      arr+=("$line")
  done < optimize.txt

  #### Import Index
  lookup_trigger_snapshot_optimize optimize-import-index "${arr[@]}"
  deleted_id=$?
  #debug "Deleted id - $deleted_id"
  unset "arr[${deleted_id}]"

  #### Timestamp Based Import Index
  lookup_trigger_snapshot_optimize optimize-timestamp-based-import-index "${arr[@]}"
  deleted_id=$?
  #debug "Deleted id - $deleted_id"
  unset arr[$deleted_id]

  #### Position Based Import Index
  lookup_trigger_snapshot_optimize optimize-position-based-import-index "${arr[@]}"
  deleted_id=$?
  #debug "Deleted id - $deleted_id"
  unset arr[$deleted_id]

  ## Pass 2 - all Other optimize indices
  other_optimize_indices=$(IFS=,; printf '%s\n' "${arr[*]}")
  debug "$other_optimize_indices"

  info 'Attempting to create snapshot of optimize indices ...'
  trigger_es_snapshot_optimize $other_optimize_indices

}

# OPERATE

function createOptimizeSnapshotRepo() {
  SNAPSHOT_REPO_ENDPOINT=${OPERATE_BACKUP_SNAPSHOT_REPO_ENDPOINT}
  createSnapshotRepo
}

function createOperateSnapshot() {

  info "Gathering indices for Operate ..."
  jq -r '.[] | select(.index|test("^operate.")) | .index' "${PROJECT_DIR}/backup/es-indices.json"  > operate.txt

  info 'Attempting to create snapshot of operate indices ...'

  arr_operate=()
  while read line; do
      arr_operate+=("$line")
  done < operate.txt

  ### import position

  trigger_es_snapshot_operate operate-import-position-8.3.0_

  trigger_es_snapshot_operate operate-list-view-8.3.0_

  trigger_es_snapshot_operate operate-list-view-8.3.0_*,-operate-list-view-8.3.0_

  trigger_es_snapshot_operate operate-batch-operation-1.0.0_,operate-decision-instance-8.3.0_,operate-event-8.3.0_,operate-flownode-instance-8.3.1_,operate-incident-8.3.1_,operate-message-8.5.0_,operate-operation-8.4.1_,operate-post-importer-queue-8.3.0_,operate-sequence-flow-8.3.0_,operate-user-task-8.5.0_,operate-variable-8.3.0_

  trigger_es_snapshot_operate operate-batch-operation-1.0.0_*,-operate-batch-operation-1.0.0_,operate-decision-instance-8.3.0_*,-operate-decision-instance-8.3.0_,operate-event-8.3.0_*,-operate-event-8.3.0_,operate-flownode-instance-8.3.1_*,-operate-flownode-instance-8.3.1_,operate-incident-8.3.1_*,-operate-incident-8.3.1_,operate-message-8.5.0_*,-operate-message-8.5.0_,operate-operation-8.4.1_*,-operate-operation-8.4.1_,operate-post-importer-queue-8.3.0_*,-operate-post-importer-queue-8.3.0_,operate-sequence-flow-8.3.0_*,-operate-sequence-flow-8.3.0_,operate-user-task-8.5.0_*,-operate-user-task-8.5.0_,operate-variable-8.3.0_*,-operate-variable-8.3.0_

  trigger_es_snapshot_operate operate-decision-8.3.0_,operate-decision-requirements-8.3.0_,operate-metric-8.3.0_,operate-migration-steps-repository-1.1.0_,operate-web-session-1.1.0_,operate-process-8.3.0_,operate-user-1.2.0_

}

# TASKLIST
function createOptimizeSnapshotRepo() {
  SNAPSHOT_REPO_ENDPOINT=${TASKLIST_BACKUP_SNAPSHOT_REPO_ENDPOINT}
  createSnapshotRepo
}

function createOptimizeSnapshot() {
  info "Gathering indices for Tasklist ..."
  jq -r '.[] | select(.index|test("^tasklist.")) | .index' "${PROJECT_DIR}/backup/es-indices.json"  > tasklist.txt

  arr_tasklist=()
  while read line; do
      arr_tasklist+=("$line")
  done < tasklist.txt

  ## Step 0 - create tasklist snapshot repo

  #### import-position
  lookup_trigger_snapshot_tasklist tasklist-import-position "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### process-instance
  lookup_trigger_snapshot_tasklist tasklist-process-instance "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-task
  lookup_trigger_snapshot_tasklist tasklist-task "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  ### task: archived - TODO

  #### tasklist-draft-task-variable
  lookup_trigger_snapshot_tasklist tasklist-draft-task-variable "${arr_tasklist[@]}"
  deleted_id=$?
  # printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-flownode-instance
  lookup_trigger_snapshot_tasklist tasklist-flownode-instance "${arr_tasklist[@]}"
  deleted_id=$?
  # printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-task-variable
  lookup_trigger_snapshot_tasklist tasklist-task-variable "${arr_tasklist[@]}"
  deleted_id=$?
  # printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-draft-task-variable
  lookup_trigger_snapshot_tasklist tasklist-draft-task-variable "${arr_tasklist[@]}"
  deleted_id=$?
  # printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-form
  lookup_trigger_snapshot_tasklist tasklist-form "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-metric
  lookup_trigger_snapshot_tasklist tasklist-metric "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset arr_tasklist[$deleted_id]

  #### tasklist-migration-steps-repository
  lookup_trigger_snapshot_tasklist tasklist-migration-steps-repository "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset arr_tasklist[$deleted_id]

  #### tasklist-migration-steps-repository
  lookup_trigger_snapshot_tasklist tasklist-migration-steps-repository "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-process
  lookup_trigger_snapshot_tasklist tasklist-process "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-web-session
  lookup_trigger_snapshot_tasklist tasklist-web-session "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

  #### tasklist-user
  lookup_trigger_snapshot_tasklist tasklist-user "${arr_tasklist[@]}"
  deleted_id=$?
  #printf "\n\n Deleted id - $deleted_id \n"
  unset "arr_tasklist[$deleted_id]"

}

# ZEEBE

function createZeebeSnapshotRepo() {
  ## Step Z.1 - create zeebe snapshot repo
  SNAPSHOT_REPO_ENDPOINT=${ZEEBE_BACKUP_SNAPSHOT_REPO_ENDPOINT}
  createSnapshotRepo
}

function pauseZeebeExporter() {
  info "Pause Zeebe exporter ..."
  CURL_REQUEST="POST"
  CURL_URL="${ZEEBE_PAUSE_EXPORT_ENDPOINT}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA="{}"

  doCurl
}

function resumeZeebeExporter() {
  info "Resume Zeebe exporter ..."
  CURL_REQUEST="POST"
  CURL_URL="${ZEEBE_RESUME_EXPORT_ENDPOINT}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA="{}"

  doCurl
}

function exportZeebeData() {

  info "Export Zeebe data ..."
  CURL_REQUEST="POST"
  CURL_URL="${ZEEBE_BACKUP_ENDPOINT}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat <<EOF
  {
    "backupId": "${BACKUP_ID}"
  }
EOF
)

  doCurl

}

function createZeebeSnapshot() {

  ### Z.1 Pause Zeebe exporter
  pauseZeebeExporter

  ### Z.2 Trigger Zeebe ES Snapshot
  trigger_es_snapshot_zeebe zeebe-record*

  ### Z.3 Zeebe RocksDB backup
  exportZeebeData

  ### Z.4 Resume Zeebe exporter
  resumeZeebeExporter

}

getESIndices

createOptimizeSnapshotRepo
createOptimizeSnapshot

createOperateSnapshotRepo
createOperateSnapshot

createOptimizeSnapshotRepo
createOptimizeSnapshot

createZeebeSnapshotRepo
createZeebeSnapshot