#! /bin/bash

function createZeebeComponentTemplate() {

  COMPONENT_TEMPLATE_FILE_NAME=${PROJECT_DIR}/init/zeebe/resources/index/zeebe-record-template.json
  COMPONENT_TEMPLATE_NAME="${ZEEBE_INDEX_PREFIX}"
  COMPONENT_TEMPLATE_ES_URL="${ZEEBE_ES_URL}"

  createComponentTemplate

}

function deleteZeebeComponentTemplate() {
  info "Attempting to delete Zeebe Component Templates ..."

  COMPONENT_TEMPLATE_NAME="${ZEEBE_INDEX_PREFIX}"
  COMPONENT_TEMPLATE_ES_URL="${ZEEBE_ES_URL}"

  deleteComponentTemplate
}

function createZeebeIndexTemplates() {

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$ZEEBE_INDEX_TEMPLATES"

  # Output the array elements
  for element in "${array[@]}"; do
    # check if the value type is `true`
    vType="${!element}"
    debug "'${element}' is set to $vType "

    if [ "$vType" == "true" ]; then
      VALUE_TYPE="${element//-/_}"
      INDEX_TEMPLATE_NAME="${ZEEBE_INDEX_PREFIX}${ZEEBE_INDEX_DELIMITER}${VALUE_TYPE}${ZEEBE_INDEX_DELIMITER}${ZEEBE_VERSION}"
      INDEX_TEMPLATE_FILE_NAME="${PROJECT_DIR}/init/zeebe/resources/index/${ZEEBE_INDEX_PREFIX}-${VALUE_TYPE}-template.json"

      # Check if the JSON file exists
      if [ ! -f "${INDEX_TEMPLATE_FILE_NAME}" ]; then
        warn "JSON file ${INDEX_TEMPLATE_FILE_NAME} does not exist."
      else
        debug "JSON file ${INDEX_TEMPLATE_FILE_NAME} exits."

        INDEX_TEMPLATE_ES_URL="${ZEEBE_ES_URL}"
        INDEX_TEMPLATE_FILE="${INDEX_TEMPLATE_FILE_NAME}"

        createIndexTemplate

      fi
    else
      debug "'${element}' set to false in config file"
    fi
  done

}

function deleteZeebeIndexTemplates() {

  info "Attempting to delete Zeebe Index Templates ..."

  # Convert multi-line string to array
  # Using a here document to simulate multi-line input
  IFS=$'\n' read -r -d '' -a array <<< "$ZEEBE_INDEX_TEMPLATES"

  # Output the array elements
  for element in "${array[@]}"; do
    # check if the value type is `true`
    vType="${!element}"
    debug "'${element}' is set to $vType "

    if [ "$vType" == "true" ]; then
      VALUE_TYPE="${element//-/_}"
      INDEX_TEMPLATE_NAME="${ZEEBE_INDEX_PREFIX}${ZEEBE_INDEX_DELIMITER}${VALUE_TYPE}${ZEEBE_INDEX_DELIMITER}${ZEEBE_VERSION}"
      INDEX_TEMPLATE_ES_URL="${ZEEBE_ES_URL}"

      deleteIndexTemplate

    fi
  done

}