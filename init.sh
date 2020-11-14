#!/bin/bash

GCP_ZONES=us-west1-c
PROJECT=`gcloud config get-value project`
CLUSTER_NAME=simple.k8s.local

cd terraform && \
    KOPS_STATE_STORE="gs://"`terraform output -json | jq .kops_bucket.value | tail -c +2 | head -c -2`"/" \
    && cd - 2>&1 > /dev/null

# to unlock the GCE features 
export KOPS_FEATURE_FLAGS=AlphaAllowGCE 
kops create cluster ${CLUSTER_NAME} --zones ${GCP_ZONES} --state ${KOPS_STATE_STORE} --project=${PROJECT}

clear && echo "cluster info: " && sleep 2
# Ensure was created
kops get cluster --state ${KOPS_STATE_STORE} && sleep 2

clear && echo "cluster details: " && sleep 2
kops get cluster --state ${KOPS_STATE_STORE}/ ${CLUSTER_NAME} -oyaml && sleep 2

clear && echo "instancegroup info:" && sleep 2
kops get instancegroup --state ${KOPS_STATE_STORE}/ --name ${CLUSTER_NAME} && sleep 2

