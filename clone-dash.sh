#!/bin/bash

URL='https://metrics.cloud.gov'
for dashboard in `curl -u "${CREDENTIALS}" "${URL}/api/search?query=&starred=false" | jq -r '.[].uri'`; do
  filename=`echo $dashboard | sed 's/^db\///g'`
  curl -u "${CREDENTIALS}" "${URL}/api/dashboards/${dashboard}" | jq -r . > ${filename}.json
done
