# LOGGING

function debug() {
  if [ -z "$LOG_VERBOSITY" ] || [ "$LOG_VERBOSITY" == 'DEBUG' ]
  then
    printf "\e[34mDEBUG:\e[0m %s\n" "$1"
  fi
}

function info() {
  if [ -z "$LOG_VERBOSITY" ] || [ "$LOG_VERBOSITY" == 'DEBUG' ] || [ "$LOG_VERBOSITY" == 'INFO' ]
  then
    printf "\e[34mINFO:\e[0m %s\n" "$1"
  fi
}

function warn() {
  if [ -z "$LOG_VERBOSITY" ] || [ "$LOG_VERBOSITY" == 'DEBUG' ] || [ "$LOG_VERBOSITY" == 'INFO' ] || [ "$LOG_VERBOSITY" == 'WARN' ]
  then
    printf "\e[33mWARNING:\e[0m %s\n" "$1"
  fi
}

function error() {
  if [ -z "$LOG_VERBOSITY" ] || [ "$LOG_VERBOSITY" == 'DEBUG' ] || [ "$LOG_VERBOSITY" == 'INFO' ] || [ "$LOG_VERBOSITY" == 'WARN' ] || [ "$LOG_VERBOSITY" == 'ERROR' ]
  then
    printf "\e[31mERROR:\e[0m %s\n" "$1"
  fi
}

function clusterHealth() {
    if [ "${LOG_VERBOSITY}" == 'DEBUG' ]
    then
      RESPONSE=$(curl -v -s -X PUT "$API_URL" -H "Content-Type: application/json" -u ${ES_USER}:${ES_PWD} -d "${JSON_REQUEST}")
    else
      RESPONSE=$(curl -s -X PUT "$API_URL" -H "Content-Type: application/json" -u ${ES_USER}:${ES_PWD} -d "${JSON_REQUEST}")
    fi

    if [ -z "${RESPONSE}" ]
    then
      error "Unable to get cluster health"
    else
      info "Cluster health Result: ${RESPONSE}"
    fi
}

# doCurl
# Inputs:
#   CURL_EXTRA_OPTIONS
#   CURL_REQUEST GET, PUT, POST, etc
#   CURL_URL
#   CURL_HEADER
#   CURL_OUTPUT
#   CURL_DATA

function doCurl() {

  CURL_EXTRA_OPTIONS="${CURL_SECURITY_OPTIONS}"
  if [ "${LOG_VERBOSITY}" == 'DEBUG' ]
    then CURL_EXTRA_OPTIONS="${CURL_EXTRA_OPTIONS} --verbose";CURL_OUTPUT="-"
#    then CURL_EXTRA_OPTIONS="${CURL_EXTRA_OPTIONS} --verbose"
  fi

  debug "CURL_REQUEST: '${CURL_REQUEST}'"
  debug "CURL_EXTRA_OPTIONS: '${CURL_EXTRA_OPTIONS}'"
  debug "CURL_URL: '${CURL_URL}'"
  debug "CURL_DATA: '${CURL_DATA}'"

  if [ -z "$CURL_DATA" ]
  then
    response=$(curl -s -w "\n%{http_code}" "${CURL_REQUEST}" "${CURL_URL}" -H "${CURL_HEADER}" -o "${CURL_OUTPUT}" ${CURL_EXTRA_OPTIONS})
  else
    response=$(curl -s -w "\n%{http_code}" "${CURL_REQUEST}" "${CURL_URL}" -H "${CURL_HEADER}" -o "${CURL_OUTPUT}" ${CURL_EXTRA_OPTIONS} -d "${CURL_DATA}" )
  fi


  BODY=$(echo "$response" | sed -e '$d')
  STATUS=$(echo "$response" | tail -n1)

  debug "Status: $STATUS"
  debug "Body: $BODY"
  debug "Response: $response"

  if [ "$STATUS" == '000' ]
  then error "Failed to connect - enable DEBUG for more details"
  elif [ "$STATUS" == '404' ]
  then warn "404 Not Found - enable DEBUG for more details"
  elif [ "$STATUS" == '500' ]
  then error "500 Server Error - enable DEBUG for more details"
  elif [ "${STATUS}" == '200' ]
  then debug "200 SUCCESS"
  elif [ "${STATUS}" == '400' ]
  then debug "400 Bad Request"
  elif [ "${STATUS}" == '401' ]
  then error "401 Unauthorized - make sure to update config.sh with the correct credentials and curl security options"
  error "400 Bad Request - enabled DEBUG for more details"
  else warn "Received ${STATUS} response - enable DEBUG for more details"
  fi
}

# Create Component Template
# Inputs:
#   COMPONENT_TEMPLATE_FILE_NAME
#   COMPONENT_TEMPLATE_NAME
#   COMPONENT_TEMPLATE_ES_URL
function createComponentTemplate() {
  info "Attempting to create component template ${COMPONENT_TEMPLATE_NAME}..."
  debug "Component template file: ${COMPONENT_TEMPLATE_FILE_NAME}"

  CURL_REQUEST="-X PUT"
  CURL_URL="${COMPONENT_TEMPLATE_ES_URL}/_component_template/${COMPONENT_TEMPLATE_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=$(cat "$COMPONENT_TEMPLATE_FILE_NAME")

  doCurl

}

# Delete Component Template
# Inputs:
#   COMPONENT_TEMPLATE_NAME
#   COMPONENT_TEMPLATE_ES_URL
function deleteComponentTemplate() {
  info "Attempting to delete component template ${COMPONENT_TEMPLATE_NAME}..."

  CURL_REQUEST="-X DELETE"
  CURL_URL="${COMPONENT_TEMPLATE_ES_URL}/_component_template/${COMPONENT_TEMPLATE_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=""

  doCurl
}

# Create index template
# Inputs:
#   INDEX_TEMPLATE_ES_URL
#   INDEX_TEMPLATE_NAME
#   INDEX_TEMPLATE_FILE
function createIndexTemplate() {

  info "Attempting to create index template ${INDEX_TEMPLATE_NAME}..."

  CURL_REQUEST="-X PUT"
  CURL_URL="${INDEX_TEMPLATE_ES_URL}/_index_template/${INDEX_TEMPLATE_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA="$(cat ${INDEX_TEMPLATE_FILE})"

  doCurl

}

# Create index template with patterns
# Inputs:
#   INDEX_TEMPLATE_ES_URL
#   INDEX_TEMPLATE_NAME
#   INDEX_TEMPLATE_PATTERNS
#   COMPONENT_TEMPLATES
#   INDEX_TEMPLATE_FILE
function createIndexTemplateWithPatterns() {

  # Create a JSON body for the index template
  local json_body=$(jq -n \
      --argjson patterns "$(printf '%s' "${INDEX_TEMPLATE_PATTERNS[@]}" | jq -R 'split(",")')" \
      --argjson components "$(printf '%s' "${COMPONENT_TEMPLATES[@]}" | jq -R 'split(",")')" \
      '{
          index_patterns: $patterns,
          composed_of: $components,
          template: input
      }' < "${INDEX_TEMPLATE_FILE}")

  CURL_REQUEST="-X PUT"
  CURL_URL="${INDEX_TEMPLATE_ES_URL}/_index_template/${INDEX_TEMPLATE_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA="${json_body}"

  doCurl
}

# Delete index template
# Inputs:
#   INDEX_TEMPLATE_ES_URL
#   INDEX_TEMPLATE_NAME
function deleteIndexTemplate() {
  info "Attempting to delete index template ${INDEX_TEMPLATE_NAME}..."

  CURL_REQUEST="-X DELETE"
  CURL_URL="${INDEX_TEMPLATE_ES_URL}/_index_template/${INDEX_TEMPLATE_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA=""

  doCurl
}

# Create index
# Inputs:
#   INDEX_NUMBER_OF_SHARDS
#   INDEX_NUMBER_OF_REPLICAS
#   INDEX_NAME
#   INDEX_ALIAS_NAME
#   MAPPING_FILE
#   INDEX_ES_URL
function createIndex() {

  info "Attempting to create Index '${INDEX_NAME}'"

  # Create the settings JSON dynamically
  local settings=$(jq -n \
    --argjson shards "$INDEX_NUMBER_OF_SHARDS" \
    --argjson replicas "$INDEX_NUMBER_OF_REPLICAS" \
    '{
       "settings": {
        "number_of_shards": $shards,
        "number_of_replicas": $replicas
       }
    }')

  debug "settings: ${settings}"

  # Read the mapping details from the JSON file
  local mappings=$(jq '.mappings' "${MAPPING_FILE}")

  # Combine alias, settings, and mapping into the final JSON request body
  local request_body=$(jq -n \
    --argjson settings "$settings" \
    --arg alias "$INDEX_ALIAS_NAME" \
    --argjson mappings "$mappings" \
    '{
      "aliases": {
        ($alias): {}
      },
      "settings": $settings.settings,
      "mappings": $mappings
    }')

  debug "request_body: ${request_body}"

  CURL_REQUEST="-X PUT"
  CURL_URL="${INDEX_ES_URL}/${INDEX_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA="${request_body}"

  doCurl
}

# Create index
# Inputs:
#   INDEX_NUMBER_OF_SHARDS
#   INDEX_NUMBER_OF_REPLICAS
#   INDEX_NAME
#   INDEX_ALIAS_NAME
#   INDEX_ES_URL
function createIndexNoMappings() {

  info "Attempting to create Index '${INDEX_NAME}'"

  # Create the settings JSON dynamically
  local settings=$(jq -n \
    --argjson shards "$INDEX_NUMBER_OF_SHARDS" \
    --argjson replicas "$INDEX_NUMBER_OF_REPLICAS" \
    '{
       "settings": {
        "number_of_shards": $shards,
        "number_of_replicas": $replicas
       }
    }')

  debug "settings: ${settings}"

  # Combine alias, settings, and mapping into the final JSON request body
  local request_body=$(jq -n \
    --argjson settings "$settings" \
    --arg alias "$INDEX_ALIAS_NAME" \
    '{
      "aliases": {
        ($alias): {}
      },
      "settings": $settings.settings
    }')

  debug "request_body: ${request_body}"

  CURL_REQUEST="-X PUT"
  CURL_URL="${INDEX_ES_URL}/${INDEX_NAME}"
  CURL_HEADER="Content-Type: application/json"
  CURL_OUTPUT="/dev/null"
  CURL_DATA="${request_body}"

  doCurl

}

function confirmPrompt() {
  read -p "$1" yn

  case $yn in
    yes) info "Ok, continuing";;
    no) warn "Exiting...";
        exit;;
    *) error "Invalid response, Exiting ...";
       exit 1;;
  esac
}
