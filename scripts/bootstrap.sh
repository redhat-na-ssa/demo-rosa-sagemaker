#!/bin/bash
# set -e

# 8 seconds is usually enough time for the average user to realize they foobar
export SLEEP_SECONDS=8

################# standard init #################

check_shell(){
  [ -n "$BASH_VERSION" ] && return
  echo "Please verify you are running in bash shell"
  sleep "${SLEEP_SECONDS:-8}"
}

check_git_root(){
  if [ -d .git ] && [ -d scripts ]; then
    GIT_ROOT=$(pwd)
    export GIT_ROOT
    echo "GIT_ROOT: ${GIT_ROOT}"
  else
    echo "Please run this script from the root of the git repo"
    exit
  fi
}

get_script_path(){
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  echo "SCRIPT_DIR: ${SCRIPT_DIR}"
}

check_shell
check_git_root
get_script_path

################# standard init #################

is_sourced() {
  if [ -n "$ZSH_VERSION" ]; then
      case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
  else  # Add additional POSIX-compatible shell names here, if needed.
      case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
  fi
  return 1  # NOT sourced.
}

py_check_venv(){
  # activate python venv
  [ -d venv ] || py_setup_venv 
  . venv/bin/activate
  [ -e requirements.txt ] && pip install -q -r requirements.txt

  pip install -q -U awscli

}

py_setup_venv(){
  python3 -m venv venv
  . venv/bin/activate
  pip install -q -U pip

  py_check_venv || usage
}

ocp_check_login(){
  oc whoami || return 1
  oc cluster-info | head -n1
  echo
}

ocp_check_info(){
  ocp_check_login || return 1

  echo "NAMESPACE: $(oc project -q)"
  sleep "${SLEEP_SECONDS:-8}"
}

ocp_aws_cluster(){
  oc -n kube-system get secret/aws-creds -o name > /dev/null 2>&1 || return 1
}

setup_namespace(){
  NAMESPACE=${1}

  oc new-project ${NAMESPACE} 2>/dev/null || \
    oc project ${NAMESPACE}
}

ocp_aws_get_key(){
  # get aws creds
  ocp_aws_cluster || return 1
  
  AWS_ACCESS_KEY_ID=$(oc -n kube-system extract secret/aws-creds --keys=aws_access_key_id --to=-)
  AWS_SECRET_ACCESS_KEY=$(oc -n kube-system extract secret/aws-creds --keys=aws_secret_access_key --to=-)
  AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-2}

  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION

  echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"
}

k8s_wait_for_crd(){
  CRD=${1}
  until kubectl get crd "${CRD}" >/dev/null 2>&1
    do sleep 1
  done
}

setup_ack_system(){
  NAMESPACE=ack-system

  setup_namespace ${NAMESPACE}

  oc apply -k openshift/operators/${NAMESPACE}/aggregate/popular

  for type in ec2 ecr iam s3 sagemaker
  do
    oc apply -k components/operators/ack-${type}-controller/overlays/alpha

    < components/operators/ack-${type}-controller/overlays/alpha/user-secrets-secret.yaml \
      sed "s@UPDATE_AWS_ACCESS_KEY_ID@${AWS_ACCESS_KEY_ID}@; s@UPDATE_AWS_SECRET_ACCESS_KEY@${AWS_SECRET_ACCESS_KEY}@" | \
      oc -n ${NAMESPACE} apply -f -
  done
}

################# demo specific #################

setup_sagemaker(){
NAMESPACE=fingerprint-id

  setup_namespace ${NAMESPACE}

  # create a SageMaker execution role  
  aws iam create-role \
     --role-name AmazonSageMaker-ExecutionRole \
     --assume-role-policy-document file://sagemaker/awsexecutionrole-sagemaker.json

  sleep 4

  # attaches the AmazonSageMakerFullAccess policy to the role  
  aws iam attach-role-policy \
     --role-name AmazonSageMaker-ExecutionRole \
     --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
 
  k8s_wait_for_crd buckets.s3.services.k8s.aws
  k8s_wait_for_crd notebookinstances.sagemaker.services.k8s.aws

  oc -n "${NAMESPACE}" \
    apply -f components/demos/sagemaker/ack-examples
  
  # TODO set the arn on the components/demos/sagemaker/ack-examples/sagemaker-notebook-instance-cr.yaml
  # aws command line aws iam get-role --role-name AmazonSagemaker-ExecutionRole --query 'Role.Arn' --output text
  # export ARN=$(aws iam get-role --role-name AmazonSagemaker-ExecutionRole --query 'Role.Arn' --output text | grep -Eo '[0-9]+(\.?)')
  # oc edit NotebookInstance | sed -i 's/000000000000/$ARN'
  
  export ARN=$(aws sts get-caller-identity --query "Account" --output text)
  
  < components/demos/sagemaker/ack-examples/sagemaker-nb-instance-cr.yml \
    sed "s@000000000000@${ARN}@g" | \
    oc -n ${NAMESPACE} apply -f -

}

setup_dataset(){
  SCRATCH=scratch
  DATA_SRC=https://github.com/redhat-na-ssa/datasci-fingerprint-data.git
  
  echo "Pulling dataset from ${DATA_SRC}..."

  git clone "${DATA_SRC}" "${SCRATCH}"/.raw >/dev/null 2>&1 || echo "exists"

  mkdir -p "${SCRATCH}"/{train,models}

  tar -Jxf "${SCRATCH}"/.raw/left.tar.xz -C "${SCRATCH}"/train/ && \
  tar -Jxf "${SCRATCH}"/.raw/right.tar.xz -C "${SCRATCH}"/train/ && \
  tar -Jxf "${SCRATCH}"/.raw/real.tar.xz -C "${SCRATCH}" && \
  tar -Jxf "${SCRATCH}"/.raw/model-v1-full.tar.xz -C "${SCRATCH}"/models && \
  tar -Jxf "${SCRATCH}"/.raw/model-v2-full.tar.xz -C "${SCRATCH}"/models
}

setup_s3(){
  NAMESPACE=fingerprint-id

  export UUID=$(oc whoami --show-server | sed 's@https://@@; s@:.*@@; s@api.*-@@; s@[.].*$@@')
  export S3_BASE=sagemaker-fingerprint
  export S3_POSTFIX=data

  export S3_BUCKET_DATA="${S3_BASE}-${S3_POSTFIX}-${UUID}"

  aws s3 ls | grep ${S3_BUCKET_DATA} || aws s3 mb s3://${S3_BUCKET_DATA}
}

setup_s3_transfer(){
  which aws || return
  echo "Copying dataset into s3://${S3_BUCKET_DATA}..."

  aws s3 sync "${SCRATCH}"/train/left "s3://${S3_BUCKET_DATA}"/train/left --quiet && \
  aws s3 sync "${SCRATCH}"/train/right "s3://${S3_BUCKET_DATA}"/train/right --quiet && \
  aws s3 sync "${SCRATCH}"/real "s3://${S3_BUCKET_DATA}"/real --quiet && \
  aws s3 sync "${SCRATCH}"/models "s3://${S3_BUCKET_DATA}"/models --quiet
}

setup_triton(){
  NAMESPACE=models
  APP_NAME=model-server-s3

  setup_namespace ${NAMESPACE}

  oc -n ${NAMESPACE} new-build \
    https://github.com/redhat-na-ssa/demo-rosa-sagemaker \
    --name s2i-triton \
    --context-dir /serving/s2i-triton \
    --strategy docker
  
  echo "Be patient, this may take a while (10 min)..."
  until oc -n ${NAMESPACE} \
    get istag \
    s2i-triton:latest >/dev/null 2>&1
  do sleep 1
  done
  
  oc -n ${NAMESPACE} new-app \
    s2i-triton:latest \
    --name ${APP_NAME}
  
  oc -n ${NAMESPACE} create route \
    edge ${APP_NAME} \
    --service=${APP_NAME} \
    --port=8000 -n ${NAMESPACE}

  oc -n ${NAMESPACE} set env \
    deploy/${APP_NAME} \
    AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    MODEL_REPOSITORY=s3://"${S3_BUCKET_DATA}"/models
}

setup_triton_metrics(){
  NAMESPACE=models
  APP_NAME=model-server-s3

  setup_namespace ${NAMESPACE}

  oc -n ${NAMESPACE} \
    apply -f components/demos/model-serving/resources
}

setup_gradio(){
  NAMESPACE=models
  APP_NAME=gradio-client

  setup_namespace ${NAMESPACE}
  
  oc -n ${NAMESPACE} new-app \
    https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git \
    --name ${APP_NAME} \
    --strategy docker \
    --context-dir /components/demos/model-serving/s2i-gradio

  oc -n ${NAMESPACE} expose service \
    ${APP_NAME}

  oc -n ${NAMESPACE} patch route \
    ${APP_NAME} \
    --patch='{"spec":{"tls":{"termination":"edge"}}}'

  oc -n ${NAMESPACE} set env \
    deploy/${APP_NAME} \
    INFERENCE_ENDPOINT=http://model-server-s3:8000/v2/models/fingerprint \
    LOGLEVEL=DEBUG
}

setup_grafana(){
  oc apply -k openshift/operators/grafana-operator/overlays/models
  k8s_wait_for_crd grafanas.integreatly.org
}

setup_prometheus(){
  oc apply -k openshift/operators/prometheus-operator/aggregate/overlays/models
  k8s_wait_for_crd prometheuses.monitoring.coreos.com
}

delete_demo(){

  echo "Please be patient, this may take a while (10 mins+)..."

  NAMESPACE=fingerprint-id
  oc -n ${NAMESPACE} \
    delete all,bucket,notebookinstance,notebookinstancelifecycleconfig,kfdef --all --wait

  NAMESPACE=models
  oc -n ${NAMESPACE} \
    delete grafana,prometheus --all --wait

  for ns in ack-system fingerprint-id grafana models prometheus
  do
    oc delete project "${ns}"
  done
}

usage(){

echo "
You can run individual functions!

example:
  setup_demo
  delete_demo
"
}

################# demo specific #################

setup_demo(){
  py_check_venv
  ocp_check_info
  ocp_aws_get_key
  
  setup_dataset

  setup_s3
  echo "Running s3 transfer in background..."
  setup_s3_transfer &
  
  setup_ack_system
  setup_sagemaker

  setup_grafana
  setup_prometheus
  setup_gradio
  setup_triton_metrics
  setup_triton
}

is_sourced && usage || setup_demo
