#!/bin/bash -exu

# this comes from https://github.com/18F/cg-riemannc-boshrelease which must be co-located with this job
RIEMANNC=/var/vcap/jobs/riemannc/bin/riemannc

# this comes from https://github.com/18F/cg-awslogs-boshrelease which must be co-located with this job
AWSCLI=/var/vcap/packages/awslogs/bin/aws

# emit all ec2 instances to riemann
export LD_LIBRARY_PATH=/var/vcap/packages/awslogs/lib

# find the VPC we want to emit for
VPCID=$(${AWSCLI} ec2 describe-vpcs --filter Name=tag:Name,Values=${VPC_NAME} --output text --query 'Vpcs[].VpcId')

# don't emit any info for whitelist nodes, this allows specific hosts not created by the VPC's director
# to exist as long as they are whitelisted
WHITELIST_QUERY=""

for ip in ${INSTANCE_WHITELIST}; do
	if [ -z "$WHITELIST_QUERY" ]; then
		WHITELIST_QUERY="?PrivateIpAddress != "
	else
		WHITELIST_QUERY="${WHITELIST_QUERY} && PrivateIpAddress != "
	fi
	WHITELIST_QUERY="${WHITELIST_QUERY}\`$ip\`"
done

WHITELIST_QUERY="Reservations[].Instances[${WHITELIST_QUERY}] | "

for id in $(${AWSCLI} ec2 describe-instances --max-items 500 --output text  --filter Name=vpc-id,Values=${VPCID} --query "${WHITELIST_QUERY} [].{\"aws_id\": InstanceId, \"bosh_id\": Tags[?Key==\`id\`].Value | [0]} | [].[bosh_id || aws_id]"); do
	${RIEMANNC} --service "aws.ec2.describe-instances" --host ${id} --metric_sint64 1
done
