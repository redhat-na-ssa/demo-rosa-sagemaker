#!/bin/bash

BIN_PATH=/home/ec2-user/.dl_binaries/bin
COMPLETION_PATH=/etc/bash_completion.d

echo ${PATH}

setup_oc(){
OCP_VERSION=4.10
DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OCP_VERSION}/openshift-client-linux.tar.gz

curl "${DOWNLOAD_URL}" -L | tar vzx -C ${BIN_PATH}/ oc kubectl

oc completion bash > ${COMPLETION_PATH}/oc.bash
# . <(oc completion bash)
# . <(kubectl completion bash)

}

setup_helm(){
DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64.tar.gz

curl "${DOWNLOAD_URL}" -L | tar vzx -C ${BIN_PATH}/ helm-linux-amd64
mv  ${BIN_PATH}/helm-linux-amd64  ${BIN_PATH}/helm

helm completion bash > ${COMPLETION_PATH}/helm.bash

}

setup_s2i(){
DOWNLOAD_URL=https://github.com/openshift/source-to-image/releases/download/v1.3.2/source-to-image-v1.3.2-78363eee-linux-amd64.tar.gz

curl "${DOWNLOAD_URL}" -L | tar vzx -C ${BIN_PATH}/

s2i completion bash > ${COMPLETION_PATH}/s2i.bash
# . <(s2i completion bash)

}

setup_restic(){
DOWNLOAD_URL=https://github.com/restic/restic/releases/download/v0.14.0/restic_0.14.0_linux_amd64.bz2

curl "${DOWNLOAD_URL}" -L | bzcat > ${BIN_PATH}/restic
chmod 755 ${BIN_PATH}/restic

restic generate --bash-completion ${COMPLETION_PATH}/restic.bash

}

setup_oc
setup_helm
setup_s2i
setup_restic
