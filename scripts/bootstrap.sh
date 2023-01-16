#!/bin/bash
set -e

NAMESPACE=fingerprint-id

setup_namespace(){
  oc create ns "${NAMESPACE}"
  sleep 3
}

setup_aws_crs(){
  oc -n "${NAMESPACE}" \
    apply -f openshift/ack-examples
}

setup_odh(){
  oc -n "${NAMESPACE}" \
    apply -f openshift/odh/odh-v1.3-sub.yml
  oc -n "${NAMESPACE}" \
    apply -f openshift/odh
}

setup_namespace
setup_aws_crs
setup_odh