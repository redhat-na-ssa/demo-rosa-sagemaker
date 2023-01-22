## Why use SageMaker?

SageMaker is a fully managed machine learning service for AWS. With SageMaker, 
data scientists and developers can quickly develop / manage machine learning models. 
AWS Controllers for Kubernetes easily extend Red Hat OpenShift to manage AWS resources.

## Setup AWS Controllers for Kubernetes / ACK Operators

Create AWS users (service principles)

NOTICE: Keep output from `aws iam create-access-key ...`

```
# create s3 user
aws iam create-user --user-name ack-user-s3
aws iam create-access-key --user-name ack-user-s3

# create sagemaker user
aws iam create-user --user-name ack-user-sagemaker
aws iam create-access-key --user-name ack-user-sagemaker
```

Assign Amazon Resource Name (ARN) policy to users.

```
# https://github.com/aws-controllers-k8s/s3-controller/blob/main/config/iam/recommended-policy-arn

# attach user policy - s3
aws iam attach-user-policy \
    --user-name ack-user-s3 \
    --policy-arn 'arn:aws:iam::aws:policy/AmazonS3FullAccess'

# attach user policy - sagemaker
aws iam attach-user-policy \
    --user-name ack-user-sagemaker \
    --policy-arn 'arn:aws:iam::aws:policy/AmazonS3FullAccess'

aws iam attach-user-policy \
    --user-name ack-user-sagemaker \
    --policy-arn  'arn:aws:iam::aws:policy/AmazonEC2FullAccess'

aws iam attach-user-policy \
    --user-name ack-user-sagemaker \
    --policy-arn  'arn:aws:iam::aws:policy/AmazonSageMakerFullAccess'

```

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

## Sagemaker Notebook Lifecycle Configuration

See https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples
