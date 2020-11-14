#!/bin/bash
# set -x

# basic info
GCP_ZONES="us-west1-a,us-west1-b,us-west1-c"
PROJECT=`gcloud config get-value project`
CLUSTER_NAME=simple.k8s.local

# Optional Flags
NODE_COUNT_FLAG="--node-count 4"
MASTER_COUNT_FLAG="--master-count 3"
NODE_SIZE_FLAG="--node-size n2-standard-8"
MASTER_SIZE_FLAG="--master-size n2-standard-4"
GCP_MASTER_ZONES_FLAG="--master-zones us-west1-a,us-west1-b,us-west1-c"
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
    --project=${PROJECT} \
    ${NODE_COUNT_FLAG} \
    ${MASTER_COUNT_FLAG} \
    ${NODE_SIZE_FLAG} \
    ${MASTER_SIZE_FLAG} \
    ${GCP_MASTER_ZONES_FLAG} \
    ${DRY_RUN_FLAG}

if [[ -z ${DRY_RUN_FLAG} ]] ; then

    clear && echo "cluster info: " && sleep 2
    # Ensure was created
    kops get cluster --state ${KOPS_STATE_STORE} && sleep 2

    clear && echo "cluster details: " && sleep 2
    kops get cluster --state ${KOPS_STATE_STORE}/ ${CLUSTER_NAME} -oyaml && sleep 2

    clear && echo "instancegroup info:" && sleep 2
    kops get instancegroup --state ${KOPS_STATE_STORE}/ --name ${CLUSTER_NAME} && sleep 2
else
    echo "dry run"
fi
