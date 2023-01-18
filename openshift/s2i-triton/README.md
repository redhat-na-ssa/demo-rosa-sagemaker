# s2i patch - triton model serving

This project consists of how to create a container with a model for serving on triton

## Folder Info

Triton model folder structure:

```
models (provide this dir as source / MODEL_REPOSITORY )
└─ [ model name ]
    └─ 1 (version)
        └── model.savedmodel
            ├── saved_model.pb
```

## Usage

NOTE: `oc new-app` commands will error before the image is built; be patient.

### Build S2I Image

Build s2i image in Openshift

```
oc new-build \
  https://github.com/codekow/s2i-patch.git \
  --name s2i-triton \
  --context-dir /s2i-triton \
  --strategy docker
```

### Use S2I Image to serve models

Deploy model via git repo

```
APP_NAME=example-triton-server

oc new-app \
  s2i-triton:latest~https://github.com/codekow/s2i-patch.git \
  --name ${APP_NAME} \
  --strategy source \
  --context-dir=/s2i-triton/models
```

Deploy model via s3

```
APP_NAME=model-server-s3

oc new-app \
  s2i-triton:latest \
  --name ${APP_NAME}

oc set env \
  deploy/${APP_NAME} \
  AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  MODEL_REPOSITORY=s3://bucket/triton/models
```


Deploy model via local folder

```
APP_NAME=model-server-local

# configure new build config
oc new-build \
  --image-stream s2i-triton:latest \
  --name ${APP_NAME} \
  --strategy source \
  --binary \
  --context-dir .
```

```
# start build from local folder
oc start-build \
  ${APP_NAME} \
  --follow \
  --from-dir models
```

```
# deploy APP_NAME from model image
oc new-app \
  ${APP_NAME} \
  --allow-missing-imagestream-tags
```

Expose API / model server - Route

```
oc expose service \
  ${APP_NAME} \
  --port 8000 \
  --overrides='{"spec":{"tls":{"termination":"edge"}}}'
```

Expose metrics  - Route (optional)

```
oc expose service \
  ${APP_NAME} \
  --name ${APP_NAME}-metrics \
  --port 8002 \
  --overrides='{"spec":{"tls":{"termination":"edge"}}}'

HOST=$(oc get route ${APP_NAME}-metric --template={{.spec.host}})
curl -s https://${HOST}/metrics | python -m json.tool
```

Test model server / metrics

```
APP_NAME=model-server

# test via route
HOST=$(oc get route ${APP_NAME} --template={{.spec.host}})

curl -s https://${HOST}/v2 | python -m json.tool
curl -s https://${HOST}/v2/models/< model name > | python -m json.tool


# test via localhost
oc get pods

oc exec deploy/${APP_NAME} -- curl -s localhost:8000/v2
oc exec deploy/${APP_NAME} -- curl -s localhost:8000/metrics
oc exec deploy/${APP_NAME} -- curl -s localhost:8000/v2/models/< model name >
```

## Links

- https://github.com/triton-inference-server/server
- https://github.com/openshift/source-to-image
- https://github.com/sclorg/container-common-scripts
