# Adopting AWS resources into k8s / OpenShift

In some cases you want to manage a pre-existing resource that already exists in AWS. You can "adopt" that resource. This allows the ACK operator to create a CR for the object.

Example:

A preexisting S3 bucket called `sagemaker-fingerprint-data` exists in AWS.

When trying to create a `Bucket` CR in k8s / OpenShift the following error appears:

```
Status: 
ACK.Terminal

This resource already exists but is not managed by ACK. To bring the resource under ACK management, you should explicitly adopt the resource by creating a services.k8s.aws/AdoptedResource
```

Steps to resolve:

1. Delete the `Bucket` CR in the `ACK.Terminal` state
1. Create an `AdoptedResource` - See: [Example](adopt-sagemaker-fingerprint-data-cr.yml)
1. S3 ACK Operator creates `Bucket` CR from existing resource in AWS


## Links
- https://aws-controllers-k8s.github.io/community/docs/user-docs/adopted-resource