# OpenDataHub (ODH) Quick Start

## Install ODH operator (v1.3.0)

```
oc apply -f odh-v1.3.0-sub.yml
```
During the installation, you may have to manually approve the installation for the opendatahub operator. Review and approve the install. 

Do not upgrade if you want to remain on v1.3.0

## Setup ODH resources

```
NAMESPACE=fingerprint-id
oc new-project ${NAMESPACE}

# setup odh resources
oc apply -n ${NAMESPACE} -f .

# custom notebook instances
oc apply -n ${NAMESPACE} -f custom-notebook
```
