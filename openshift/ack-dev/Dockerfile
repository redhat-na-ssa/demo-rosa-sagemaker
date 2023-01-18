# build env for ack-controller dev
FROM docker.io/ubuntu:22.04

# A basic set of dependencies
# https://aws-controllers-k8s.github.io/community/docs/contributor-docs/testing
RUN apt update && \
    apt-get install -y curl wget git make jq && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    cd /usr/local/bin && \
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    apt clean && rm -rf /var/lib/apt/lists/*

# install go
ENV GO_VERSION=1.19.5

ENV GOPATH=/go
ENV GOCACHE=/go/src/.cache

ENV PATH=${GOPATH}/bin:/opt/go/bin:$PATH

RUN mkdir -p /go/{bin,src} && \ 
    curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /opt/ -xz && \
    go version

WORKDIR $GOPATH/src

COPY init_repos.sh /usr/local/bin

CMD bash
