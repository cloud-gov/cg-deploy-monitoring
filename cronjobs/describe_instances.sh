#!/bin/bash -exu

# this comes from https://github.com/18F/cg-riemannc-boshrelease which must be co-located with this job
RIEMANNC=/var/vcap/jobs/riemannc/bin/riemannc

# this comes from https://github.com/18F/cg-awslogs-boshrelease which must be co-located with this job
AWSCLI=/var/vcap/packages/awslogs/bin/aws

# emit all ec2 instances to riemann
export LD_LIBRARY_PATH=/var/vcap/packages/awslogs/lib

for id in $(${AWSCLI} ec2 describe-instances --max-items 500 --output text --query 'Reservations[].Instances[].Tags[?Key==`id`].Value[]'); do
	${RIEMANNC} --service "aws.ec2.describe-instances" --host ${id} --metric_sint64 1
done
