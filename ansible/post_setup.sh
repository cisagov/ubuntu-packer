#!/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# The amazon-ssm-agent package in the stable channel is typically out-dated.
# In order to pull the latest stable version, Amazon recommends switching to the candidate channel.
# Also, the snap version of amazon-ssm-agent does not actually sync correctly with the service.
# Amazon recommends copying the data from the snap dir to one under /etc in order to collect logs correctly:
# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu-64-snap.html
sudo snap switch --channel=candidate amazon-ssm-agent
sudo snap refresh amazon-ssm-agent
[[ -d /etc/amazon/ssm ]] || sudo mkdir --parents /etc/amazon/ssm
sudo cp --recursive --no-target-directory /snap/amazon-ssm-agent/current/ /etc/amazon/ssm/
sudo cp /snap/amazon-ssm-agent/current/seelog.xml.template /etc/amazon/ssm/seelog.xml
sudo snap restart amazon-ssm-agent
