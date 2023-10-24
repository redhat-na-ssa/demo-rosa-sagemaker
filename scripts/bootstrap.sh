#!/bin/bash
#set -e

usage(){
  # echo "
  # setup virtualenv:
  # python3 -m venv venv
  # "

echo "
You can run individual functions!

example:
  setup_demo
  delete_demo
"
}

is_sourced() {
  if [ -n "$ZSH_VERSION" ]; then 
      case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
  else  # Add additional POSIX-compatible shell names here, if needed.
      case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
  fi
  return 1  # NOT sourced.
}

setup_venv(){
  python3 -m venv venv
  source venv/bin/activate
  pip install -q -U pip
  pip install -q awscli

  check_venv || usage
}

check_venv(){
  # activate python venv
  [ -d venv ] && . venv/bin/activate || setup_venv
}

check_oc(){
  echo "Are you on the right OCP cluster?"

  oc whoami || exit 0
  export UUID=$(oc whoami --show-server | sed 's@https://@@; s@:.*@@; s@api.*-@@; s@[.].*$@@')
  oc status

  echo "UUID: ${UUID}"
  sleep 4
}

get_aws_key(){
  # get aws creds
  export AWS_ACCESS_KEY_ID=$(oc -n kube-system extract secret/aws-creds --keys=aws_access_key_id --to=-)
  export AWS_SECRET_ACCESS_KEY=$(oc -n kube-system extract secret/aws-creds --keys=aws_secret_access_key --to=-)
  export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-2}

  echo "NOTICE!!! - AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"
  sleep 4
}

setup_namespace(){
  NAMESPACE=${1}

  oc new-project ${NAMESPACE} 2>/dev/null || \
    oc project ${NAMESPACE}
}

wait_for_crd(){
  CRD=${1}
  until oc get crd "${CRD}" >/dev/null 2>&1
    do sleep 1
  done
}

setup_ack_system(){
  NAMESPACE=ack-system

  setup_namespace ${NAMESPACE}

  oc apply -k openshift/operators/${NAMESPACE}/aggregate/popular

  for type in ec2 ecr iam s3 sagemaker
  do
    oc apply -k openshift/operators/ack-${type}-controller/operator/overlays/alpha

    < openshift/operators/ack-${type}-controller/operator/overlays/alpha/user-secrets-secret.yaml \
      sed "s@UPDATE_AWS_ACCESS_KEY_ID@${AWS_ACCESS_KEY_ID}@; s@UPDATE_AWS_SECRET_ACCESS_KEY@${AWS_SECRET_ACCESS_KEY}@" | \
      oc -n ${NAMESPACE} apply -f -
  done
}

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
 
  wait_for_crd buckets.s3.services.k8s.aws
  wait_for_crd notebookinstances.sagemaker.services.k8s.aws

  oc -n "${NAMESPACE}" \
    apply -f openshift/ack-examples
  
  # TODO set the arn on the openshift/ack-examples/sagemaker-notebook-instance-cr.yaml
  # aws command line aws iam get-role --role-name AmazonSagemaker-ExecutionRole --query 'Role.Arn' --output text
  # export ARN=$(aws iam get-role --role-name AmazonSagemaker-ExecutionRole --query 'Role.Arn' --output text | grep -Eo '[0-9]+(\.?)')
  # oc edit NotebookInstance | sed -i 's/000000000000/$ARN'
  
  export ARN=$(aws sts get-caller-identity --query "Account" --output text)
  
  < openshift/ack-examples/sagemaker-nb-instance-cr.yml \
    sed "s@000000000000@${ARN}@g" | \
    oc -n ${NAMESPACE} apply -f -

}

setup_odh_v1.3.0(){
  NAMESPACE=fingerprint-id
  ODH_VERSION=1.3.0

  # install odh sub
  oc -n openshift-operators \
    apply -f openshift/odh/odh-v1.3.0-sub.yml
  
  # kludge: just sleep
  sleep 10
  
  # approve operator install
  ODH_INSTALL=$(
    oc -n openshift-operators \
    get installplan \
    -l operators.coreos.com/opendatahub-operator.openshift-operators | \
      grep ${ODH_VERSION} | \
      awk '{print $1}'
  )

  oc -n openshift-operators \
    patch installplan/${ODH_INSTALL} \
    --type=merge \
    --patch '{"spec":{"approved": true }}'

  wait_for_crd kfdefs.kfdef.apps.kubeflow.org

  # install odh resources
  oc -n "${NAMESPACE}" \
    apply -f openshift/odh

  # install custom sagemeker notebook
  oc -n "${NAMESPACE}" \
    apply -f openshift/sagemaker-notebook
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
    apply -f serving/resources
}

setup_gradio(){
  NAMESPACE=models
  APP_NAME=gradio-client

  setup_namespace ${NAMESPACE}
  
  oc -n ${NAMESPACE} new-app \
    https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git \
    --name ${APP_NAME} \
    --strategy docker \
    --context-dir /serving/client

  oc -n ${NAMESPACE} expose service \
    ${APP_NAME} \
    --overrides='{"spec":{"tls":{"termination":"edge"}}}'

  oc -n ${NAMESPACE} set env \
    deploy/${APP_NAME} \
    INFERENCE_ENDPOINT=http://model-server-s3:8000/v2/models/fingerprint \
    LOGLEVEL=DEBUG
}

setup_grafana(){
  oc apply -k openshift/operators/grafana-operator/overlays/models
  wait_for_crd grafanas.integreatly.org
}

setup_prometheus(){
  oc apply -k openshift/operators/prometheus-operator/aggregate/overlays/models
  wait_for_crd prometheuses.monitoring.coreos.com
}

delete_demo(){
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

setup_demo(){
  check_venv
  check_oc
  get_aws_key
  
  setup_dataset

  setup_s3
  echo "Running s3 transfer in background..."
  setup_s3_transfer &
  
  setup_ack_system
  setup_sagemaker
  # setup_odh_v1.3.0

  setup_grafana
  setup_prometheus
  setup_gradio
  setup_triton_metrics
  setup_triton
}

is_sourced && usage || setup_demo
