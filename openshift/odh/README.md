# Quickstart

## Install operator

```
oc apply -f odh-v*-sub.yml
```
During the installation, you may have to manually approve the installation for the opendatahub operator. Review and approve the install. Do not upgrade.

## Setup ODH resources
```
NAMESPACE=fingerprint-id

oc apply -n ${NAMESPACE} -f notebooks
```
