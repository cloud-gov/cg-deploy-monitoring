#!/bin/bash

set -e
set -u
# REQUIRES:
# env: UAA_URL
#      UAA_CLIENT_ID
#      UAA_CLIENT_SECRET

JQ_PATH=/var/vcap/packages/jq-1.5/bin/jq
RIEMANNC_PATH=/var/vcap/jobs/riemannc/bin/riemannc
TTL=${TTL:-600}

get_client_token() {
  TOKEN=$(curl -X POST -u "$UAA_CLIENT_ID:$UAA_CLIENT_SECRET" -H "Accept: application/json" -d "client_id=$UAA_CLIENT_ID&grant_type=client_credentials&response_type=token&token_format=opaque" "$UAA_URL/oauth/token" 2>/dev/null | sed -n 's/.*access_token":"\([^"]*\).*/\1/p')
}

process_user_tokens() {
  local start="$1"

  USERS_RESP=$(curl -X GET -H "Authorization: Bearer ${TOKEN}" -H "Accept: application/json" "${UAA_URL}/Users?sortBy=userName&sortOrder=ascending&startIndex=${start}" 2>/dev/null)
  TOTAL_RESULTS=$(echo "${USERS_RESP}" | ${JQ_PATH} --raw-output ".totalResults | tonumber")
  ITEMS_PER_PAGE=$(echo "${USERS_RESP}" | ${JQ_PATH} --raw-output ".itemsPerPage | tonumber")

  USERS=$(echo "$USERS_RESP" | ${JQ_PATH} --unbuffered --raw-output --compact-output ".resources[] | {id, userName}")
  for user in $USERS; do
    user_id=$(echo "$user" | ${JQ_PATH} --raw-output ".id | tostring")
    user_name=$(echo "$user" | ${JQ_PATH} --raw-output ".userName | tostring")
    user_tokens=$(curl -X GET -H "Authorization: Bearer ${TOKEN}" -H "Accept: application/json" "${UAA_URL}/oauth/token/list/user/${user_id}" 2>/dev/null)
    clients=$(echo "$user_tokens" | ${JQ_PATH} --compact-output "group_by(.clientId) | .[] | { id: (.[0].clientId), count: length, is_admin: (.[0].scope | contains(\"admin\")) }")
    for client in $clients; do
      count=$(echo $client | ${JQ_PATH} --raw-output ".count | tonumber")
      is_admin=$(echo $client | ${JQ_PATH} ".is_admin")
      client_id=$(echo $client | ${JQ_PATH} --raw-output ".id")
      ${RIEMANNC_PATH} --service uaa-token-audit --host ${UAA_URL} --ttl ${TTL} --metric_sint64 ${count} --attributes user-id=${user_id},client-id=${client_id},is-admin=${is_admin}
    done
  done

  HAS_NEXT_PAGE=false
  NEXT_PAGE_START=$(($start + $ITEMS_PER_PAGE))
  if [ "$TOTAL_RESULTS" -ge "$NEXT_PAGE_START" ]; then
    HAS_NEXT_PAGE=true
  fi
  if $HAS_NEXT_PAGE; then
    process_user_tokens $NEXT_PAGE_START
  fi
}

get_client_token
process_user_tokens 1
