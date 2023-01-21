#!/bin/bash
#set -e

NAMESPACE=fingerprint-id

is_sourced() {
  if [ -n "$ZSH_VERSION" ]; then 
      case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
  else  # Add additional POSIX-compatible shell names here, if needed.
      case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
  fi
  return 1  # NOT sourced.
}

usage(){
echo "
usage: 
  source $0
  setup_demo
"
}

check_oc(){
  echo "Are you on the right OCP cluster?"

  oc whoami || exit 0 
  oc status

  sleep 4
}

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
  ODH_VERSION=1.3.0
  # install odh sub
  oc \
    apply -f openshift/odh/odh-v1.3-sub.yml
  
  # approve operator install
  ODH_INSTALL=$(
    oc -n openshift-operators \
    get installplan \
    -l operators.coreos.com/opendatahub-operator.openshift-operators | \
      grep $ODH_VERSION | \
      awk '{print $1}'
  )

  oc -n openshift-operators \
    patch installplan/$ODH_INSTALL \
    --type=merge \
    --patch '{"spec":{"approved": true }}'

  # install odh resources
  oc -n "${NAMESPACE}" \
    apply -f openshift/odh

  # install custom sagemeker notebook
  oc -n "${NAMESPACE}" \
    apply -f openshift/sagemaker-notebook
}

setup_s2i_triton(){
  oc create ns ${NAMESPACE} || return 0

  oc -n ${NAMESPACE} new-build \
    https://github.com/redhat-na-ssa/demo-rosa-sagemaker \
    --name s2i-triton \
    --context-dir /openshift/s2i-triton \
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
  S3_BUCKET=sagemaker-fingerprint-data
  S3_URL=s3://${S3_BUCKET}
  DATA_SRC=https://github.com/redhat-na-ssa/demo-rosa-sagemaker-data.git

  which aws || return

  echo "Pulling dataset from ${DATA_SRC} (gross)..."

  git clone "${DATA_SRC}" "${SCRATCH}"/.raw >/dev/null 2>&1 || echo "exists"

  mkdir -p "${SCRATCH}"/train

  tar -Jxf "${SCRATCH}"/.raw/left.tar.xz -C "${SCRATCH}"/train/ && \
  tar -Jxf "${SCRATCH}"/.raw/right.tar.xz -C "${SCRATCH}"/train/ && \
  tar -Jxf "${SCRATCH}"/.raw/real.tar.xz -C "${SCRATCH}"

  echo "Copying dataset into ${S3_URL}..."

  aws s3 ls | grep ${S3_BUCKET} || aws s3 mb ${S3_BUCKET}

  aws s3 sync "${SCRATCH}"/train/left "${S3_URL}"/train/left --quiet && \
  aws s3 sync "${SCRATCH}"/train/right "${S3_URL}"/train/right --quiet && \
  aws s3 sync "${SCRATCH}"/real "${S3_URL}"/real --quiet
}

setup_gradio(){
  APP_NAME=gradio-client

  oc create ns ${NAMESPACE} || return 0

  oc new-app \
  https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git \
  --name ${APP_NAME} \
  --strategy docker \
  --context-dir /serving/client

  oc expose service \
    ${APP_NAME} \
    --overrides='{"spec":{"tls":{"termination":"edge"}}}'

  oc set env \
    deploy/${APP_NAME} \
    INFERENCE_ENDPOINT=http://model-server-s3:8000/v2/models/fingerprint/infer \
    LOGLEVEL=DEBUG

}

setup_demo(){
  check_oc
  get_aws_key

  setup_namespace
  setup_sagemaker
  setup_s3_data
  setup_odh

  NAMESPACE=models
  
  setup_s2i_triton
  setup_gradio
}

is_sourced || usage && echo "run: setup_demo"