# Run on Openshift

Assumes an NVIDIA Triton model server with a service name of `triton` is running in the ${MODEL_SERVER_NAMESPACE}
```
APP_NAME=fingerprint
MODEL_SERVER_NAMESPACE=models
INFERENCE_HOST=$(oc get route triton -n ${MODEL_SERVER_NAMESPACE} --template={{.spec.host}})

oc new-app --name=${APP_NAME} --env=INFERENCE_HOST=${INFERENCE_HOST} --context-dir=/triton/application --strategy=docker https://github.com/bkoz/fingerprint
```

Create a route.
```
oc create route edge ${APP_NAME} --service=${APP_NAME} --port=8080
```

