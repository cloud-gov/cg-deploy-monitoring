#!/bin/bash

set -e -u -x

JQ_PATH=/var/vcap/packages/jq-1.5/bin/jq
RIEMANNC_PATH=/var/vcap/jobs/riemannc/bin/riemannc
AWSCLI_PATH=/var/vcap/packages/aws-cli/bin/aws

GLOBAL_LAST_UPDATE=0

for GROUP in  `$AWSCLI_PATH logs describe-log-groups | $JQ_PATH -r .logGroups[].logGroupName`; do
    LAST_UPDATE=$($AWSCLI_PATH logs describe-log-streams --log-group-name=$GROUP --order-by LastEventTime --descending --max-items 1 | $JQ_PATH .logStreams[].lastEventTimestamp)
    if [ -z "$LAST_UPDATE" ]; then
        LAST_UPDATE=0
    fi

    NICE_GROUP=$(echo $GROUP | tr /. - | sed s/^-//)

    ${RIEMANNC_PATH} --service "awslogs.$NICE_GROUP.lastEventTimestamp" --host $(hostname) --ttl ${TTL} --metric_sint64 ${LAST_UPDATE}


    if [ "$LAST_UPDATE" -gt "$GLOBAL_LAST_UPDATE" ]; then
        GLOBAL_LAST_UPDATE=$LAST_UPDATE
    fi
done

# Emit a metric for each entry in our heatbeat group, where host = logStreamName, and metric = seconds since last update
IFS=$'\n'
for streaminfo in $(${AWSCLI_PATH} logs describe-log-streams --output text --max-items 1000 --order-by LastEventTime --descending --log-group-name=$HEARTBEAT_GROUP --query "logStreams[?lastEventTimestamp > \`$(($(($(date +%s) - 14400)) * 1000))\`][logStreamName, lastEventTimestamp]" | grep -v None); do
    aws_id=$(echo ${streaminfo} | cut -f1)
    last=$(( $(echo ${streaminfo} | cut -f2) / 1000 ))

    ${RIEMANNC_PATH} --service "aws.logs.describe-log-streams.$HEARTBEAT_GROUP" --host ${aws_id} --ttl ${TTL} --metric_sint64 $(( $(date +%s) - ${last} ))
done


${RIEMANNC_PATH} --service "awslogs._GLOBAL.lastEventTimestamp" --host $(hostname) --ttl ${TTL} --metric_sint64 ${GLOBAL_LAST_UPDATE}
