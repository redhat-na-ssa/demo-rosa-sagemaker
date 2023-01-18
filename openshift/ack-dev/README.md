# ACK development container

## Usage

Build a developer env for ack-controllers

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
cd github.com/aws-controllers-k8s/code-generator/

export SERVICE=s3
ACK_GENERATE_OLM=true make build-controller SERVICE=$SERVICE
```