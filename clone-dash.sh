#!/bin/bash
URL='https://metrics.cloud.gov/api/search?query=&starred=false'
for dashboard in `curl -u "${CREDENTIALS}" ${URL} | jq -r '.[].uri'`; do
	filename=`echo $dashboard | sed 's/^db\///g'`
	curl -u "${CREDENTIALS}" -o ${filename}.json https://metrics.fr.cloud.gov/api/dashboards/${dashboard}
done
# curl -vu "grafana:icmrhNHcoVEKBOrd+paptzhv4h4D6n9o8p/xRW6NgBHvC23DO7zFCC2S1hs2wnpq" "https://metrics.fr.cloud.gov/api/search?query=&starred=false"
