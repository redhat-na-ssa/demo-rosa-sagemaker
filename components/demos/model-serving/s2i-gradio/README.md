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
APP_LABEL="app.kubernetes.io/part-of=${APP_NAME}"
INFERENCE_ENDPOINT=http://model-server-embedded:8000/v2/models/fingerprint

oc new-app \
  -n ${NAMESPACE} \
  --name=${APP_NAME} \
  -l "${APP_LABEL}" \
  --env=INFERENCE_ENDPOINT=${INFERENCE_ENDPOINT} \
  --context-dir=/serving/client \
  --strategy=docker \
  https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git

oc expose service \
  ${APP_NAME} \
  -l "${APP_LABEL}" \
  -n "${NAMESPACE}" \
  --port 8080 \
  --overrides='{"spec":{"tls":{"termination":"edge"}}}'
```
