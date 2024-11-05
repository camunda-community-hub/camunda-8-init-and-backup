#! /bin/bash

function createTasklistComponentTemplate() {

  COMPONENT_TEMPLATE_FILE_NAME=${PROJECT_DIR}/init/tasklist/resources/component/component-template.json
  COMPONENT_TEMPLATE_NAME="${TASKLIST_INDEX_PREFIX}${TASKLIST_INDEX_DELIMITER}template"
  COMPONENT_TEMPLATE_ES_URL="${TASKLIST_ES_URL}"

  createComponentTemplate

}

function deleteTasklistComponentTemplate() {

  COMPONENT_TEMPLATE_NAME="${TASKLIST_INDEX_PREFIX}${TASKLIST_INDEX_DELIMITER}template"
  COMPONENT_TEMPLATE_ES_URL="${TASKLIST_ES_URL}"

  deleteComponentTemplate

}

function createTasklistIndexTemplates() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$TASKLIST_INDEX_TEMPLATES"

  # Output the array elements
  for element in "${array[@]}"; do

    key="${element//-/_}"
    version="${!key}"
    index_template_fqn="${TASKLIST_INDEX_PREFIX}-${element}-${version}${TASKLIST_INDEX_DELIMITER}"
    index_template_alias="${index_template_fqn}alias";
    INDEX_TEMPLATE_PATTERNS=("${index_template_fqn}*")
    index_template_file_name="${PROJECT_DIR}/init/tasklist/resources/template/${TASKLIST_INDEX_PREFIX}-${element}.json"
    COMPONENT_TEMPLATES=("${TASKLIST_INDEX_PREFIX}_template")
    INDEX_TEMPLATE_NAME="${index_template_fqn}template"

    debug "key: '${key}'"
    debug "version: '${version}'"
    debug "Index template FQN : ${index_template_fqn}"
    debug "Index template Patterns : ${INDEX_TEMPLATE_PATTERNS}"
    debug "Index template file name : ${index_template_file_name}"
    debug "Component templates: ${COMPONENT_TEMPLATES}"
    debug "Index template name : ${INDEX_TEMPLATE_NAME}"
    debug "Index template alias : ${index_template_alias}"

    if [ ! -f "$index_template_file_name" ]; then
      warn "Index Template file $index_template_file_name does not exist."
    else
      debug "Index Template file $index_template_file_name exists."

      INDEX_TEMPLATE_ES_URL=${TASKLIST_ES_URL}
      INDEX_TEMPLATE_FILE=${index_template_file_name}

      info "Attempting to create index template ${INDEX_TEMPLATE_NAME}"
      createIndexTemplateWithPatterns

      #Originally thought we might need this, but
      #create_index "${index_template_fqn}" "${index_template_alias}"
    fi
  done

}

function deleteTasklistIndexTemplates() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$TASKLIST_INDEX_TEMPLATES"

  # Output the array elements
  for element in "${array[@]}"; do

    key="${element//-/_}"
    version="${!key}"

    index_template_fqn="${TASKLIST_INDEX_PREFIX}-${element}-${version}${TASKLIST_INDEX_DELIMITER}"
    INDEX_TEMPLATE_NAME="${index_template_fqn}template"
    INDEX_TEMPLATE_ES_URL=${TASKLIST_ES_URL}

    debug "key: '${key}'"
    debug "version: '${version}'"
    debug "Index template FQN : ${index_template_fqn}"
    debug "Index template name : ${INDEX_TEMPLATE_NAME}"

    deleteIndexTemplate

  done
}

function createTasklistIndices() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$TASKLIST_INDICES"

  # Output the array elements
  for element in "${array[@]}"; do

    debug "Index  : ${element}"

    key="${element//-/_}"
    version="${!key}"

    index_fqn="${TASKLIST_INDEX_PREFIX}-${element}-${version}${TASKLIST_INDEX_DELIMITER}"

    debug "Index FQN : $index_fqn"

    index_file_name="${PROJECT_DIR}/init/tasklist/resources/index/${TASKLIST_INDEX_PREFIX}-${element}.json"

    debug "Index file name : ${index_file_name}"

    index_alias="${index_fqn}alias"

    debug "Index alias : ${index_alias}"

    if [ ! -f "$index_file_name" ]; then

      warn "Index file $index_file_name does not exist."

    else

      debug "Index file $index_file_name exists."
      INDEX_NUMBER_OF_SHARDS=${TASKLIST_NUMBER_OF_SHARDS}
      INDEX_NUMBER_OF_REPLICAS=${TASKLIST_NUMBER_OF_REPLICAS}
      INDEX_NAME=${index_fqn}
      INDEX_ALIAS_NAME=${index_alias}
      MAPPING_FILE=${index_file_name}
      INDEX_ES_URL=${TASKLIST_ES_URL}

      createIndex

    fi

  done
}

function deleteTasklistIndices() {

  IFS=$'\n' read -r -d '' -a array <<< "$TASKLIST_INDICES"

  # Output the array elements
  for element in "${array[@]}"; do

      debug "Index  : ${element}"

      key="${element//-/_}"
      version="${!key}"

      index_fqn="${TASKLIST_INDEX_PREFIX}-${element}-${version}${TASKLIST_INDEX_DELIMITER}"

      debug "Index FQN : $index_fqn"
      info "Attempting to delete index '$index_fqn'"

      CURL_REQUEST="-X DELETE"
      CURL_URL="${TASKLIST_ES_URL}/${index_fqn}"
      CURL_HEADER="Content-Type: application/json"
      CURL_OUTPUT="/dev/null"
      CURL_DATA=""

      doCurl

  done
}
