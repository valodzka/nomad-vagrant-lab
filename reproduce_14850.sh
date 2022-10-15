#!/bin/bash -x

# I don't know if it matters, but cluster with the issue runs with a spread scheduler.
curl -XPUT localhost:4646/v1/operator/scheduler/configuration --data '{"SchedulerAlgorithm":"spread"}'

for i in {1..500}
do
    nomad job run -var redeploy=$i test.nomad
    ruby detect.rb || exit 1
    sleep 5
done
