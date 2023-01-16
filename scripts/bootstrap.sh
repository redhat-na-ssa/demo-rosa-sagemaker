#!/bin/bash
#set -e

NAMESPACE=fingerprint-id

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

setup_namespace
setup_aws_crs
setup_odh
