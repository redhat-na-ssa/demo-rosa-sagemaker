# ODH Quickstart

## Install ODH operator (v1.3)

```
oc apply -f odh-v1.3.0-sub.yml

```
During the installation, you may have to manually approve the installation for the opendatahub operator. Review and approve the install. Do not upgrade.

## Setup ODH resources

```
NAMESPACE=explore-fingerprint-id

oc apply -n ${NAMESPACE} -f .
oc apply -n ${NAMESPACE} -f sagemaker-notebook
```
