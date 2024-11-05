#! /bin/bash

function createOperateComponentTemplate() {

  COMPONENT_TEMPLATE_FILE_NAME=${PROJECT_DIR}/init/operate/resources/component/operate-component-template.json
  COMPONENT_TEMPLATE_NAME="${OPERATE_INDEX_PREFIX}${OPERATE_INDEX_DELIMITER}template"
  COMPONENT_TEMPLATE_ES_URL="${OPERATE_ES_URL}"

  createComponentTemplate

}

function deleteOperateComponentTemplate() {

  COMPONENT_TEMPLATE_NAME="${OPERATE_INDEX_PREFIX}${OPERATE_INDEX_DELIMITER}template"
  COMPONENT_TEMPLATE_ES_URL="${OPERATE_ES_URL}"

  deleteComponentTemplate

}

function createOperateIndexTemplates() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$OPERATE_INDEX_TEMPLATES"

  # Output the array elements
  for element in "${array[@]}"; do

    key="${element//-/_}"
    version="${!key}"
    index_template_fqn="${OPERATE_INDEX_PREFIX}-${element}-${version}${OPERATE_INDEX_DELIMITER}"
    index_template_alias="${index_template_fqn}alias";
    INDEX_TEMPLATE_PATTERNS=("${index_template_fqn}*")
    index_template_file_name="${PROJECT_DIR}/init/operate/resources/template/${OPERATE_INDEX_PREFIX}-${element}.json"
    COMPONENT_TEMPLATES=("${OPERATE_INDEX_PREFIX}_template")
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

      INDEX_TEMPLATE_ES_URL=${OPERATE_ES_URL}
      INDEX_TEMPLATE_FILE=${index_template_file_name}

      info "Attempting to create index template ${INDEX_TEMPLATE_NAME}"
      createIndexTemplateWithPatterns

      # create index logic moved
      #create_index "${index_template_fqn}" "${index_template_alias}"
    fi
  done

}

function deleteOperateIndexTemplates() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$OPERATE_INDEX_TEMPLATES"

  # Output the array elements
  for element in "${array[@]}"; do

    key="${element//-/_}"
    version="${!key}"

    index_template_fqn="${OPERATE_INDEX_PREFIX}-${element}-${version}${OPERATE_INDEX_DELIMITER}"
    INDEX_TEMPLATE_NAME="${index_template_fqn}template"
    INDEX_TEMPLATE_ES_URL=${OPERATE_ES_URL}

    debug "key: '${key}'"
    debug "version: '${version}'"
    debug "Index template FQN : ${index_template_fqn}"
    debug "Index template name : ${INDEX_TEMPLATE_NAME}"

    deleteIndexTemplate

  done
}

function createOperateIndices() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$OPERATE_INDICES"

  # Output the array elements
  for element in "${array[@]}"; do

    debug "Index  : ${element}"

    key="${element//-/_}"
    version="${!key}"

    index_fqn="${OPERATE_INDEX_PREFIX}-${element}-${version}${OPERATE_INDEX_DELIMITER}"

    debug "Index FQN : $index_fqn"

    index_file_name="${PROJECT_DIR}/init/operate/resources/index/${OPERATE_INDEX_PREFIX}-${element}.json"

    debug "Index file name : ${index_file_name}"

    index_alias="${index_fqn}alias"

    debug "Index alias : ${index_alias}"

    if [ ! -f "$index_file_name" ]; then

      warn "Index file $index_file_name does not exist."

    else

      debug "Index file $index_file_name exists."
      INDEX_NUMBER_OF_SHARDS=${OPERATE_NUMBER_OF_SHARDS}
      INDEX_NUMBER_OF_REPLICAS=${OPERATE_NUMBER_OF_REPLICAS}
      INDEX_NAME=${index_fqn}
      INDEX_ALIAS_NAME=${index_alias}
      MAPPING_FILE=${index_file_name}
      INDEX_ES_URL=${OPERATE_ES_URL}

      createIndex

    fi

  done
}

function deleteOperateIndices() {

  IFS=$'\n' read -r -d '' -a array <<< "$OPERATE_INDICES"

  # Output the array elements
  for element in "${array[@]}"; do

      debug "Index  : ${element}"

      key="${element//-/_}"
      version="${!key}"

      index_fqn="${OPERATE_INDEX_PREFIX}-${element}-${version}${OPERATE_INDEX_DELIMITER}"

      debug "Index FQN : $index_fqn"
      info "Attempting to delete index '$index_fqn'"

      CURL_REQUEST="-X DELETE"
      CURL_URL="${OPERATE_ES_URL}/${index_fqn}"
      CURL_HEADER="Content-Type: application/json"
      CURL_OUTPUT="/dev/null"
      CURL_DATA=""

      doCurl

  done
}
