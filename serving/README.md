# Model Serving and Inference

### Deploy the Triton model server

The Triton container is large and will take several minutes to build.

The following environment variables must be set to serve models
from a public s3 bucket.

- `MODEL_SERVER_NAMESPACE=models`
- `TRITON_APP_NAME=triton`
- `MODEL_REPOSITORY=s3://mybucket/models/triton`
- `AWS_DEFAULT_REGION=us-east-1`

If necessary create the Openshift project.
```
oc new-project ${MODEL_SERVER_NAMESPACE}
```

Deploy Triton.
```
oc new-app \
  https://github.com/codekow/s2i-patch.git
  -n ${MODEL_SERVER_NAMESPACE} \
  --name=${TRITON_APP_NAME} \
  --context-dir=/s2i-triton \
  --strategy docker \
  --env=AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  --env=MODEL_REPOSITORY=${MODEL_REPOSITORY} \
  
```

Create an https route for the model server.
```
oc create route edge ${TRITON_APP_NAME} --service=${TRITON_APP_NAME} --port=8000
```

#### Testing

Basic model server test
```
export INFERENCE_HOST=$(oc get route -n ${MODEL_SERVER_NAMESPACE} ${TRITON_APP_NAME} --template={{.spec.host}})
```
```
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
INFERENCE_HOST=$(oc get route ${TRITON_APP_NAME} -n ${MODEL_SERVER_NAMESPACE} --template={{.spec.host}})
```

Create a project.
```
oc new-project ${APP_NAMESPACE}
```

```
oc new-app -n ${APP_NAMESPACE} --name=${INFERENCE_APP_NAME} --env=INFERENCE_HOST=${INFERENCE_HOST} --context-dir=/serving/application --strategy=docker https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git#bkoz-dev-v0.1
```

Create a route and visit the URL.
```
oc create route edge ${INFERENCE_APP_NAME} --service=${INFERENCE_APP_NAME} --port=8080 -n ${APP_NAMESPACE}
```

### Model Server Monitoring (Need to provide details)

- Install the Prometheus and Grafana operators in the MODEL_SERVER_NAMESPACE.
- Create a Prometheus Service Monitor for Triton
- Create a Grafana data source that points to the Prometheus service host at port 9091
- Import the sample Grafana Dashboard for Triton
