#! /bin/bash
PROJECT_DIR="./.."

source ${PROJECT_DIR}/init/config.sh
source ${PROJECT_DIR}/common/functions.sh

SCRIPT_NAME="init.sh"

function help() {
  info "Usage for ${SCRIPT_NAME}: "
  info ""
  info "Options: "
  info "  --help                    Display this help message"
  info "  --v <LOG_VERBOSITY>       Controls the verbosity of logs written to stdout."
  info "                            Default is DEBUG. Set to one of DEBUG, INFO, WARN, ERROR"
  info "Commands: "
  info "  zeebe         initialize ES objects for Zeebe"
  info "  operate       initialize ES objects for Operate"
  info "  tasklist      initialize ES objects for Tasklist"
  info "  all           initialize ES objects for all Camunda Components"
}

function initZeebe() {
  source ${PROJECT_DIR}/init/zeebe/zeebe.sh
  source ${PROJECT_DIR}/init/zeebe/zeebe.config
  createZeebeComponentTemplate
  createZeebeIndexTemplates
}

function initOperate() {
  source ${PROJECT_DIR}/init/operate/operate.sh
  source ${PROJECT_DIR}/init/operate/operate.config
  createOperateComponentTemplate
  createOperateIndexTemplates
  createOperateIndices
}

function initTasklist() {
  source ${PROJECT_DIR}/init/tasklist/tasklist.sh
  source ${PROJECT_DIR}/init/tasklist/tasklist.config
  createTasklistComponentTemplate
  createTasklistIndexTemplates
  createTasklistIndices
}

function initAll() {
  initZeebe
  initOperate
  initTasklist
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

info "Starting Camunda ${SCRIPT_NAME} ..."
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
    initZeebe
    exit 1
    ;;
  operate)
    debug "command 'operate' was triggered"
    initOperate
    exit 1
    ;;
  tasklist)
    debug "command 'tasklist' was triggered"
    initTasklist
    exit 1
    ;;
  all)
    debug "command 'all' was triggered"
    initAll
    exit 1
    ;;
  *)
    debug "no command was triggered"
    help
    exit 1
    ;;
esac
