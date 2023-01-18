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

setup_sagemaker(){
  oc -n "${NAMESPACE}" \
    apply -f openshift/ack-examples
  
  # aws iam create-role \
  #   --policy-name AmazonSageMaker-ExecutionRole \
  #   --policy-document file://sagemaker/awsexecutionrole-sagemaker.json
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

setup_s2i_triton(){
  NAMESPACE=example-triton

  oc new-project ${NAMESPACE}

  oc -n ${NAMESPACE} new-build \
    https://github.com/codekow/s2i-patch.git \
    --name s2i-triton \
    --context-dir /s2i-triton \
    --strategy docker
  
  export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-2}
  
  APP_NAME=model-server-s3

  oc -n ${NAMESPACE} new-app \
    s2i-triton:latest \
    --name ${APP_NAME}

  oc -n ${NAMESPACE} set env \
    deploy/${APP_NAME} \
    AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    MODEL_REPOSITORY=s3://sagemaker-fingerprint-models/models    
}

setup_s3_data(){
  SCRATCH=scratch
  S3_URL=s3://sagemaker-fingerprint-data
  DATA_SRC=https://github.com/redhat-na-ssa/demo-rosa-sagemaker-data.git

  which aws || return

  echo "Pulling dataset from ${DATA_SRC} (gross)..."

  git clone "${DATA_SRC}" "${SCRATCH}"/.raw >/dev/null 2>&1 || echo "exists"

  tar -Jxf "${SCRATCH}"/.raw/left.tar.xz -C "${SCRATCH}"/train/ && \
  tar -Jxf "${SCRATCH}"/.raw/right.tar.xz -C "${SCRATCH}"/train/ && \
  tar -Jxf "${SCRATCH}"/.raw/real.tar.xz -C "${SCRATCH}"

  echo "Copying dataset into ${S3_URL}..."

  aws s3 sync "${SCRATCH}"/train/left "${S3_URL}"/train/left --quiet && \
  aws s3 sync "${SCRATCH}"/train/right "${S3_URL}"/train/right --quiet && \
  aws s3 sync "${SCRATCH}"/real "${S3_URL}"/real --quiet
}

setup_demo(){
  get_aws_key

  setup_namespace
  setup_sagemaker
  setup_s3_data
  setup_odh
  setup_s2i_triton
}

echo "
usage: 
  . $0
  setup_demo
"