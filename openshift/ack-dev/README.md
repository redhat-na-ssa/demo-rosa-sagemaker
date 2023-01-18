# ACK development container

## Usage

Build: a developer environment for ack-controllers

Purpose: limit the artifacts you have to install locally

```
podman build -t ack-dev .
```

Start a developer env for ack-controllers

```
podman run -it \
  -v $(pwd):/go/src \
  -v $HOME/.ssh:/root/.ssh:ro \
  localhost/ack-dev
```

Build a controller (s3)

```
# one time script to pull repos
init_repos.sh

# `go` to it
cd github.com/aws-controllers-k8s/code-generator/

export SERVICE=s3
ACK_GENERATE_OLM=true make build-controller SERVICE=$SERVICE
```

## Links

- https://aws-controllers-k8s.github.io/community/docs/contributor-docs/testing
- https://aws-controllers-k8s.github.io/community/docs/contributor-docs/setup
