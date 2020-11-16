#!/usr/bin/env bash

# Copyright 2018 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Simple script to start a Prow job.

REPO_ROOT_DIR="$(git rev-parse --show-toplevel)"

# First parameter is expected to be the prow job name
JOB_NAME="$1"

[[ -z "${JOB_NAME}" ]] && abort "pass the name of the job to start as argument"

set -e

CONFIG_YAML=${REPO_ROOT_DIR}/prow/config.yaml
JOB_YAML=$(mktemp)
JOB_CONFIG_YAML=${REPO_ROOT_DIR}/prow/cluster/jobs

docker run -i --rm \
    -v "${PWD}:${PWD}" -v "${CONFIG_YAML}:${CONFIG_YAML}" -v "${JOB_CONFIG_YAML}:${JOB_CONFIG_YAML}" \
    -w "${PWD}" \
    gcr.io/k8s-prow/mkpj:v20200603-4badfd9f37 \
    "--job=${JOB_NAME}" "--config-path=${CONFIG_YAML}" "--job-config-path=${JOB_CONFIG_YAML}" \
    > ${JOB_YAML} || failed=1

if (( failed )); then
    echo "ERROR: failed generating job config using mkpj"
    exit 1
fi

echo "Job YAML file saved to ${JOB_YAML}"

kubectl apply -f ${JOB_YAML}
