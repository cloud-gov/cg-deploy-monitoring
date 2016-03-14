#!/bin/bash
URL='https://grafana.cloud.gov/api/search?query=&starred=false'
for dashboard in `curl -u "${CREDENTIALS}" ${URL} | jq -r '.[].uri'`; do
	filename=`echo $dashboard | sed 's/^db\///g'`
	curl -u "${CREDENTIALS}" -o ${filename}.json https://grafana.cloud.gov/api/dashboards/${dashboard}
done
