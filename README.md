# Fingerprint attribute prediction model lifecycle 

## About the Demo
This demo covers several topics important for extending Red Hat OpenShift to perform common data science tasks from: 
- data ingestion from storage
- data labeling infer class names
- dataset splitting and performance tuning
- model build from scratch
- distributed model training strategies
- hyperparameter tuning
- model saving and compression
- inference prototyping
- model serving
- inference monitoring

## Technology 
- Red Hat OpenShift Container Platform
- AWS Controllers for Kubernetes Operators - IAM, S3, EC2, and SageMaker
- Red Hat OpenShift Data Science / Open Data Hub Operator
- AWS SageMaker resources - Processingjob, Notbook Instance, Notebook Instance Configuration
- EC2 Accelerated Instance types
- NVIDIA Triton Inference Server
- Gradio Web Interface
- Prometheus Metrics and Grafana Dashboard

## About the data
Sokoto Coventry Fingerprint Dataset (SOCOFing) is a biometric fingerprint database 
designed for academic research purposes. Please see the accompanying GitHub https://github.com/redhat-na-ssa/demo-rosa-sagemaker-data 
that pulls the data from [Kaggle](https://www.kaggle.com/datasets/ruizgara/socofing).
For a complete formal description and usage policy please refer to the following 
paper: https://arxiv.org/abs/1807.10609.

## Model training

The model is trained to predict from a given fingerprint if it comes from the:
- left or right hand
- male or female
- index, middle, ring, little, or thumb

The training data and model could also be refactored to predict finger the print is from and gender. Currently, only hand is predicted.

![image](docs/fingerprint-model-arch.png)


## Setup Custom Notebooks

```
oc apply -f openshift/sagemaker-notebook
```

## Examples

[ACK Demo - Examples](openshift/ack-examples)

[ACK Sagemaker - Examples](https://github.com/aws-controllers-k8s/sagemaker-controller/tree/main/samples)

## Overview of this solution stack

This basic demonstration requires configuring the environment manually, ingesting data from S3, training a basic TensorFlow Estimator model in a Jupyter notebook using SageMaker SDK. It versions and stores the trained model in S3. This is possible because the SageMaker SDK leverages an IAM Execution Roles to securely control access to AWS SageMaker resources and S3 storage for the data and model.

## Why use SageMaker SDK on OpenShift (ROSA)?

Simply, use the tools you want for the job.

SageMaker is a fully managed machine learning service for AWS. With SageMaker, data scientists and developers can quickly develop / manage machine learning models.

OpenShift is a best-in-class enterprise Kubernetes container platform. OpenShift provides a hybrid cloud solution from private data centers to multiple cloud vendors.

[SageMaker Python SDK](https://sagemaker.readthedocs.io/en/stable/index.html) provides machine learning (ML) services integrated with industry leading storage technologies (s3).

Machine learning tools include:
  - [Frameworks](https://sagemaker.readthedocs.io/en/stable/frameworks/index.html) Apache MXNet, Chainer, Hugging Face, PyTorch, Reinforcement Learning, Scikit-Learn, SparkML Serving, Tensorflow, XGBoost
  - [Built-in Algorithms](https://sagemaker.readthedocs.io/en/stable/algorithms/index.html) Estimators, Tabular, Text, Time-series, Unsupervised, Vision
  - [Workflows]() Airflow workflows, AWS Step Functions, SageMaker Pipelines, SageMaker Lineage
  - [Debugger](https://sagemaker.readthedocs.io/en/stable/amazon_sagemaker_debugger.html)
  - [Feature Store](https://sagemaker.readthedocs.io/en/stable/amazon_sagemaker_featurestore.html)
  - [Data pre and post processing](https://sagemaker.readthedocs.io/en/stable/amazon_sagemaker_processing.html)
  - [Model Build CI/CD](https://sagemaker.readthedocs.io/en/stable/amazon_sagemaker_model_building_pipeline.html)

[Red Hat OpenShift on AWS (ROSA)](https://aws.amazon.com/rosa/) leverages integrated AWS cloud services such as compute, storage, and networking to create a cloud agnostic platform to run containerized workloads.

OpenShift makes it easier to build, operate, and scale globally, and on demand, through a familiar management interface. 

With ROSA many of the security responsibilities that customers take on, can be managed by Red Hat:
  - Encryption
  - Firewall and network configurations
  - Identity and Access Management
  - Patching and updating software
  - Securing the Linux Operating System

## Explanation of components

- [Amazon SageMaker Python SDK](https://sagemaker.readthedocs.io/en/stable/) is an open source library for training and deploying machine-learned models on Amazon SageMaker.
- [AWS S3 Storage](https://aws.amazon.com/pm/serv-s3/) Object storage built to persist and retrieve any amount of data from anywhere.
- [Red Hat OpenShift Service on AWS (ROSA)](https://aws.amazon.com/rosa/) is a managed Red Hat OpenShift service deployed and operated on AWS that allows customers to quickly and easily build, deploy, and manage Kubernetes applications in AWS Cloud. As an integrated AWS service, ROSA can be accessed on-demand from the AWS console with hourly billing, a single invoice for AWS deployments, integration with other AWS cloud-native services, and joint support from Red Hat and AWS.
- [Open Data Hub](https://github.com/opendatahub-io) an open source project based on Kubeflow that provides open source AI tools for running large and distributed AI workloads on OpenShift Container Platform.

# Links

- [Kaggle - Sokoto Coventry Fingerprint Dataset](https://www.kaggle.com/datasets/ruizgara/socofing)
- [TensorFlow Image Classification](https://www.tensorflow.org/tutorials/images/classification#use_tensorflow_lite)
- [TensorFlow Lite Image Classification](https://www.tensorflow.org/lite/models/modify/model_maker/image_classification#simple_end-to-end_example)
