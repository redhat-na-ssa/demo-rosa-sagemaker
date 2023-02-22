## Why use SageMaker?

SageMaker is a fully managed machine learning service for AWS. With SageMaker, 
data scientists and developers can quickly develop / manage machine learning models. 
AWS Controllers for Kubernetes easily extend Red Hat OpenShift to manage AWS resources.

Use `oc apply -k` to install operators

```
# install ack-s3-controller
oc apply -k openshift/ack-s3-controller/operator/overlays/alpha

# install ack-sagemaker-controller
oc apply -k openshift/ack-sagemaker-controller/operator/overlays/alpha
```

Use output from `aws iam create-access-key` to update values `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the `ack-system` namespace:

- ack-s3-user-secrets
- ack-sagemaker-user-secrets

## Links

[Examples: ACK Demo](ack-examples)
[Examples: ACK Sagemaker](https://github.com/aws-controllers-k8s/sagemaker-controller/tree/main/samples)
[Examples: Sagemaker Notebook Lifecycle](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples)
