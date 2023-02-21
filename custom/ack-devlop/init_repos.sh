#!/bin/bash

# https://aws-controllers-k8s.github.io/community/docs/contributor-docs/setup 

init_ack_repos(){
CODE_DIR=$GOPATH/src/github.com/aws-controllers-k8s


[ ! -e "${CODE_DIR}" ] && mkdir -p "${CODE_DIR}"
cd "${CODE_DIR}"

read -p "Enter your name [codekow]: " GITHUB_ID
GITHUB_ID=${GITHUB_ID:-codekow}
echo "GITHUB_ID: ${GITHUB_ID}"

# Set this to "" if you did NOT take my advice above in the tip about prefixing
# your personal forked ACK repository names with "ack-"
ACK_REPO_PREFIX="ack-"

# Clone all the common ACK repositories...
COMMON="runtime code-generator test-infra"
for REPO in $COMMON; do
    cd $GOPATH/src/github.com/aws-controllers-k8s
    git clone https://github.com/aws-controllers-k8s/$REPO
    cd $REPO
    git remote rename origin upstream
    git remote add origin git@github.com:$GITHUB_ID/$ACK_REPO_PREFIX$REPO
    git fetch upstream
done

# Now clone all the service controller repositories...
# Change this to the list of services you forked service controllers for...
read -p "Enter ack services [s3 iam ecr sagemaker]: " SERVICES
SERVICES=${SERVICES:-s3 iam ecr sagemaker}
echo "SERVICES: ${SERVICES}"

for SERVICE in $SERVICES; do
    cd $GOPATH/src/github.com/aws-controllers-k8s
    git clone https://github.com/aws-controllers-k8s/$SERVICE-controller
    cd $SERVICE-controller
    git remote rename origin upstream
    git remote add origin git@github.com:$GITHUB_ID/$ACK_REPO_PREFIX$SERVICE-controller
    git fetch upstream
done

}

init_ack_repos
