#!/bin/bash
# set -x

# basic info
GCP_ZONES="us-west1-a,us-west1-b,us-west1-c"
PROJECT=`gcloud config get-value project`
CLUSTER_NAME=simple.k8s.local
NODE_SIZE="n1-standard-8"
NODE_COUNT=6
MASTER_SIZE="n1-standard-4"

# Optional Flags
if [[ ! -z $1 ]] ; then DRY_RUN_FLAG='--dry-run -o yaml' ; fi

cd terraform && \
    KOPS_STATE_STORE="gs://"`terraform output -json | jq .kops_bucket.value | tail -c +2 | head -c -2`"/" \
    && cd - 2>&1 > /dev/null

# to unlock the GCE features 
export KOPS_FEATURE_FLAGS=AlphaAllowGCE 
kops create cluster \
    --name=${CLUSTER_NAME} \
    --zones ${GCP_ZONES} \
    --state ${KOPS_STATE_STORE} \
    --node-count ${NODE_COUNT} \
    --project=${PROJECT} \
    ${DRY_RUN_FLAG}

if [[ -z ${DRY_RUN_FLAG} ]] ; then

    kops get cluster --name ${CLUSTER_NAME} --state ${KOPS_STATE_STORE} -oyaml && sleep 5

    kops update cluster --name ${CLUSTER_NAME} --state ${KOPS_STATE_STORE} --yes && sleep 5

    kops validate cluster --name ${CLUSTER_NAME} --state ${KOPS_STATE_STORE} --wait 10m

fi
