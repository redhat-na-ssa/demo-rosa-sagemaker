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


## Why use SageMaker SDK on OpenShift (ROSA)?

SageMaker is a fully managed machine learning service for AWS. With SageMaker, data scientists and developers can quickly develop / manage machine learning models.

Red Hat OpenShift is a best-in-class enterprise Kubernetes container platform. OpenShift provides a hybrid cloud solution from private data centers to multiple cloud vendors. Red Hat OpenShift makes it easier to build, operate, and scale globally, and on demand, through a familiar management interface. 

[Red Hat OpenShift on AWS (ROSA)](https://aws.amazon.com/rosa/) leverages integrated AWS cloud services such as compute, storage, and networking to create a cloud agnostic platform to run containerized workloads.

With ROSA many of the security responsibilities that customers take on, can be managed by Red Hat:
  - Encryption
  - Firewall and network configurations
  - Identity and Access Management
  - Patching and updating software
  - Securing the Linux Operating System

Operators published by AWS and NVIDIA for Red Hat OpenShift improvev autonomy.
- AWS Controller for Kubernetes Operators
    - IAM
    - EC2
    - S3
    - SageMaker
- NVIDIA
    - GPU Operator

# Links

- [Kaggle - Sokoto Coventry Fingerprint Dataset](https://www.kaggle.com/datasets/ruizgara/socofing)
- [TensorFlow Image Classification](https://www.tensorflow.org/tutorials/images/classification#use_tensorflow_lite)
- [TensorFlow Lite Image Classification](https://www.tensorflow.org/lite/models/modify/model_maker/image_classification#simple_end-to-end_example)
- [AWS Operators for Kubernetes](https://operatorhub.io/?provider=%5B%22Amazon%22%5D)
- [NVIDIA Operator](https://catalog.redhat.com/software/containers/nvidia/gpu-operator/5f9b0279ac3db90370a2128d)
