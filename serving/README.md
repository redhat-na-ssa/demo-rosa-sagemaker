# Model Serving and Inference

### Deploy the Triton model server

The Triton container is large and will take several minutes to build.

The following environment variables must be set to serve models
from a public s3 bucket.

- `MODEL_SERVER_NAMESPACE=models`
- `APP_NAME=triton`
- `MODEL_REPOSITORY` (i.e. s3://mybucket/models/triton)
- `AWS_DEFAULT_REGION` (the region containing the s3 bucket)

If necessary create the Openshift project.
```
oc new-project ${MODEL_SERVER_NAMESPACE}
```

Deploy Triton.
```
oc new-app -n ${MODEL_SERVER_NAMESPACE} --name=${APP_NAME} --context-dir=/s2i-triton --strategy docker --env=AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} --env=MODEL_REPOSITORY=${MODEL_REPOSITORY} https://github.com/codekow/s2i-patch.git
```

Create an https route for the model server.
```
oc create route edge ${APP_NAME} --service=${APP_NAME} --port=8000
```

#### Testing

Basic model server test
```
export HOST=$(oc get route -n ${MODEL_SERVER_NAMESPACE} ${APP_NAME} --template={{.spec.host}})
curl https://${HOST}/v2 | python -m json.tool
```

Model metadata test
```
curl https://${HOST}/v2/models/fingerprint | python -m json.tool
```

#### Deploy the inference application to Openshift.

```
cd application
```

Assumes an NVIDIA Triton model server with a service name of `triton` is running in the ${MODEL_SERVER_NAMESPACE}
```
APP_NAMESPACE=clients
APP_NAME=fingerprint
MODEL_SERVER_NAMESPACE=models
INFERENCE_HOST=$(oc get route triton -n ${MODEL_SERVER_NAMESPACE} --template={{.spec.host}})

oc new-app -n ${APP_NAMESPACE} --name=${APP_NAME} --env=INFERENCE_HOST=${INFERENCE_HOST} --context-dir=/serving/application --strategy=docker https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git#bkoz-dev-v0.1
```

Create a route.
```
oc create route edge ${APP_NAME} --service=${APP_NAME} --port=8080 -n ${APP_NAMESPACE}
```