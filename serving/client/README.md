# S2I build types

## build type: Docker

```
podman build ./docker -t gradio
```

## build type: source (python)

```
s2i build ./source \
  registry.access.redhat.com/ubi7/python-38 \
  s2i-gradio
```

## Deploy Client on OpenShift
```
NAMESPACE=model-serving
APP_NAME=model-client
INFERENCE_ENDPOINT=http://model-server-embedded:8000

oc new-app \
  -n ${NAMESPACE} \
  --name=${APP_NAME} \
  --env=INFERENCE_ENDPOINT=${INFERENCE_ENDPOINT} \
  --context-dir=/serving/client \
  --strategy=docker \
  https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git
```
