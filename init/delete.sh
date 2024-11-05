#! /bin/bash
PROJECT_DIR="./.."

source ${PROJECT_DIR}/init/config.sh
source ${PROJECT_DIR}/common/functions.sh

SCRIPT_NAME="delete.sh"

function help() {
  info "Usage for ${SCRIPT_NAME}: "
  info ""
  info "Options: "
  info "  --help                    Display this help message"
  info "  --v <LOG_VERBOSITY>       Controls the verbosity of logs written to stdout."
  info "                            Default is DEBUG. Set to one of DEBUG, INFO, WARN, ERROR"
  info "Commands: "
  info "  zeebe         delete ES objects for Zeebe"
  info "  operate       delete ES objects for Operate"
  info "  tasklist      delete ES objects for Tasklist"
  info "  all           delete ES objects for all Camunda Components"
}

function deleteZeebe() {
  confirmPrompt "Delete all Zeebe data? (yes/no) "
  info "Attempting to delete Zeebe ES Objects"
  source ${PROJECT_DIR}/init/zeebe/zeebe.sh
  source ${PROJECT_DIR}/init/zeebe/zeebe.config
  deleteZeebeIndexTemplates
  deleteZeebeComponentTemplate

}

function deleteOperate() {
  confirmPrompt "Delete all Operate data? (yes/no) "
  info "Attempting to delete Operate ES Objects"
  source ${PROJECT_DIR}/init/operate/operate.sh
  source ${PROJECT_DIR}/init/operate/operate.config
  deleteOperateIndices
  deleteOperateIndexTemplates
  deleteOperateComponentTemplate
}

function deleteTasklist() {
  confirmPrompt "Delete all Task List data? (yes/no) "
  source ${PROJECT_DIR}/init/tasklist/tasklist.sh
  source ${PROJECT_DIR}/init/tasklist/tasklist.config
  deleteTasklistIndices
  deleteTasklistIndexTemplates
  deleteTasklistComponentTemplate
}

function deleteAll() {
  deleteZeebe
  deleteOperate
  deleteTasklist
}

OPTIND=1

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

info "Starting Camunda ${SCRIPT_NAME} script ..."
info "LOG_VERBOSITY is set to: ${LOG_VERBOSITY}"

shift $((OPTIND - 1))

# Parse commands
case "$1" in
  help)
    debug "command 'help' was triggered"
    help
    exit 1
    ;;
  zeebe)
    debug "command 'zeebe' was triggered"
    deleteZeebe
    exit 1
    ;;
  operate)
    debug "command 'operate' was triggered"
    deleteOperate
    exit 1
    ;;
  tasklist)
    debug "command 'tasklist' was triggered"
    deleteTasklist
    exit 1
    ;;
  all)
    debug "command 'all' was triggered"
    deleteAll
    exit 1
    ;;
  *)
    debug "no command was triggered"
    help
    exit 1
    ;;
esac
