#!/bin/bash -exu

# where is influx?
BACKUP="/var/vcap/packages/influxdb/influxd backup"

# and the rieman client
# this comes from https://github.com/18F/cg-riemannc-boshrelease which must be co-located with this job
RIEMANNC=/var/vcap/jobs/riemannc/bin/riemannc

# and AWS
# this comes from https://github.com/18F/cg-awslogs-boshrelease which must be co-located with this job
AWSCLI=/var/vcap/packages/awslogs/bin/aws 

# where do we store the backups?
TMPD=$(mktemp -d)

# backup the metastore
${BACKUP} ${TMPD}

# back up the database
${BACKUP} -database ${INFLUX_DB_NAME} -since $(date +%Y-%m-%dT%H:%M:%SZ -d "yesterday") ${TMPD}

# sync to s3
export LD_LIBRARY_PATH=/var/vcap/packages/awslogs/lib
${AWSCLI} s3 sync --sse AES256 ${TMPD} s3://${S3_BUCKET_NAME}/$(date +%Y-%m-%d)

# clean up
rm -fr ${TMPD}

# tell riemann we did a thing
TTL=90000 # 25 hours
${RIEMANNC} --service "influxdb.backup" --host $(hostname) --ttl ${TTL} --metric_sint64 $(date +%s)
