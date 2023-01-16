#!/bin/bash
#set -e

NAMESPACE=fingerprint-id

get_aws_key(){
  # get aws creds
  export AWS_ACCESS_KEY_ID=$(oc -n kube-system extract secret/aws-creds --keys=aws_access_key_id --to=-)
  export AWS_SECRET_ACCESS_KEY=$(oc -n kube-system extract secret/aws-creds --keys=aws_secret_access_key --to=-)
}

setup_namespace(){
  oc create ns "${NAMESPACE}" || return 0
  sleep 3
}

setup_aws_crs(){
  oc -n "${NAMESPACE}" \
    apply -f openshift/ack-examples
}

setup_odh(){
  # install odh sub
  oc \
    apply -f openshift/odh/odh-v1.3-sub.yml
  
  echo "NOTICE: Approve operator install"

  # install odh resources
  oc -n "${NAMESPACE}" \
    apply -f openshift/odh

  # install custom sagemeker notebook
  oc -n "${NAMESPACE}" \
    apply -f openshift/sagemaker-notebook
}

get_aws_key

setup_namespace
setup_aws_crs
setup_odh
