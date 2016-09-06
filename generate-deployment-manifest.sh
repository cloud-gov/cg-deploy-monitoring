#!/bin/bash

set -e

which spruce > /dev/null 2>&1 || {
  echo "Aborted. Please install spruce by following https://github.com/geofffranks/spruce#installation" 1>&2
  exit 1
}

path="$(dirname $0)"

# Extract heapster dashboards
mkdir $path/dashboards-tmp
cat $path/src/heapster/grafana/dashboards/cluster.json | jq .dashboard > $path/dashboards-tmp/cluster.json
cat $path/src/heapster/grafana/dashboards/pods.json | jq .dashboard > $path/dashboards-tmp/pods.json

SPRUCE_FILE_BASE_PATH=$path spruce merge "$path/monitoring.yml" "$@"
