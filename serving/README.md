# Model Serving and Inference

### Deploy the Triton model server

The Triton container is large and will take several minutes to build.

The following environment variables must be set to serve models
from a public s3 bucket.

- `MODEL_SERVER_NAMESPACE=models`
- `TRITON_APP_NAME=triton`
- `MODEL_REPOSITORY` (i.e. s3://mybucket/models/triton)
- `AWS_DEFAULT_REGION` (the region containing the s3 bucket)

If necessary create the Openshift project.
```
oc new-project ${MODEL_SERVER_NAMESPACE}
```

Deploy Triton.
```
oc new-app -n ${MODEL_SERVER_NAMESPACE} --name=${TRITON_APP_NAME} --context-dir=/s2i-triton --strategy docker --env=AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} --env=MODEL_REPOSITORY=${MODEL_REPOSITORY} https://github.com/codekow/s2i-patch.git
```

Create an https route for the model server.
```
oc create route edge ${TRITON_APP_NAME} --service=${TRITON_APP_NAME} --port=8000
```

#### Testing

Basic model server test
```
export INFERENCE_HOST=$(oc get route -n ${MODEL_SERVER_NAMESPACE} ${TRITON_APP_NAME} --template={{.spec.host}})
curl https://${INFERENCE_HOST}/v2 | python -m json.tool
```

Sample output
```
{
    "name": "triton",
    "version": "2.28.0",
    "extensions": [
        "classification",
        "sequence",
        "model_repository",
        "model_repository(unload_dependents)",
        "schedule_policy",
        "model_configuration",
        "system_shared_memory",
        "cuda_shared_memory",
        "binary_tensor_data",
        "statistics",
        "trace",
        "logging"
    ]
}
```

Model metadata test
```
curl https://${INFERENCE_HOST}/v2/models/fingerprint | python -m json.tool
```

Sample output.
```
{
    "name": "fingerprint",
    "versions": [
        "1"
    ],
    "platform": "tensorflow_savedmodel",
    "inputs": [
        {
            "name": "conv2d_12_input",
            "datatype": "FP32",
            "shape": [
                -1,
                96,
                96,
                1
            ]
        }
    ],
    "outputs": [
        {
            "name": "dense_7",
            "datatype": "FP32",
            "shape": [
                -1,
                1
            ]
        }
    ]
}
```

#### Deploy the inference application to Openshift.

```
cd application
```

```
APP_NAMESPACE=clients
INFERENCE_APP_NAME=fingerprint
INFERENCE_HOST=$(oc get route triton -n ${MODEL_SERVER_NAMESPACE} --template={{.spec.host}})

oc new-app -n ${APP_NAMESPACE} --name=${INFERENCE_APP_NAME} --env=INFERENCE_HOST=${INFERENCE_HOST} --context-dir=/serving/application --strategy=docker https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git#bkoz-dev-v0.1
```

Create a route.
```
oc create route edge ${INFERENCE_APP_NAME} --service=${INFERENCE_APP_NAME} --port=8080 -n ${APP_NAMESPACE}
```