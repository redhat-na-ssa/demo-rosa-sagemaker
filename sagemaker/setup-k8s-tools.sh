#!/bin/bash

BIN_PATH=/home/ec2-user/.dl_binaries/bin
COMPLETION_PATH=/etc/bash_completion.d

export PATH=${BIN_PATH}:${PATH}

debug(){
echo "${PATH}"
conda info --envs
}

setup_bin(){
  mkdir -p ${BIN_PATH}/bin
  echo "${PATH}" | grep -q "${BIN_PATH}/bin" || \
    PATH=$(pwd)/${BIN_PATH}/bin:${PATH}
    export PATH
}

check_bin(){
  name=$1
  
  which "${name}" || download_"${name}"
 
  case ${name} in
    helm|kustomize|oc|odo|openshift-install|s2i)
      echo "auto-complete: . <(${name} completion bash)"
      
      # shellcheck source=/dev/null
      . <(${name} completion bash)
      ${name} completion bash > "${COMPLETION_PATH}/${name}.bash"
      
      ${name} version
      ;;
    restic)
      restic generate --bash-completion ${COMPLETION_PATH}/restic.bash
      ;;
    *)
      echo
      ${name} --version
      ;;
  esac
  sleep 2
}

download_helm(){
BIN_VERSION=latest
DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/helm/${BIN_VERSION}/helm-linux-amd64.tar.gz
curl "${DOWNLOAD_URL}" -sL | tar zx -C ${BIN_PATH}/ helm-linux-amd64
mv  ${BIN_PATH}/helm-linux-amd64  ${BIN_PATH}/helm
}

download_kustomize(){
  cd "${BIN_PATH}" || return
  curl -sL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  cd ../..
}

download_oc(){
BIN_VERSION=4.10
DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${BIN_VERSION}/openshift-client-linux.tar.gz
curl "${DOWNLOAD_URL}" -sL | tar zx -C ${BIN_PATH}/ oc kubectl
}

download_odo(){
BIN_VERSION=latest
DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/odo/${BIN_VERSION}/odo-linux-amd64.tar.gz
curl "${DOWNLOAD_URL}" -sL | tar zx -C ${BIN_PATH}/
}

download_s2i(){
# BIN_VERSION=
DOWNLOAD_URL=https://github.com/openshift/source-to-image/releases/download/v1.3.2/source-to-image-v1.3.2-78363eee-linux-amd64.tar.gz
curl "${DOWNLOAD_URL}" -sL | tar zx -C ${BIN_PATH}/
}

download_restic(){
BIN_VERSION=0.14.0
DOWNLOAD_URL=https://github.com/restic/restic/releases/download/v${BIN_VERSION}/restic_${BIN_VERSION}_linux_amd64.bz2
curl "${DOWNLOAD_URL}" -sL | bzcat > ${BIN_PATH}/restic
chmod 755 ${BIN_PATH}/restic
}

kludge_sm_perms(){
chown ec2-user:ec2-user -R ${BIN_PATH}
}

debug
setup_bin

check_bin oc
check_bin odo
check_bin s2i

check_bin helm
check_bin kustomize
check_bin restic

kludge_sm_perms
