# Fingerprint Prediction on Red Hat OpenShift Container Platform

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thank you for checking out this fingerprint prediction demonstration. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! 
-->

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#about-the-model">About The Model</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

There are a few Machine Learning (ML) demos available on [Red Hat OpenShift (RHOCP)](https://developers.redhat.com/products/red-hat-openshift-data-science/getting-started?extIdCarryOver=true&sc_cid=7013a0000038Aa7AAE); 
however, we didn't find one that really opened the toolbox for data science. 
We want to create a realistic end-to-end demonstration that Data Scientists could experience and explore possibilities of the tools available.

Here's why:
* If you are already using RHOCP for Apps, you should explore how easy it is to extend it for data science 
* You shouldn't have to become a senior administrator to run a demo, we should provide the automation to get you up and demo'ing with much effort

### About The Model
The scenario we use was to train a model that could predict suspect attributes from an unknown fingerprint. 
The model could help downselect possible suspects. Since we only had public data, the predictions are basic,
but the possibilities are what we intend to inspire.

This demo covers several topics across the lifecycle for extending Red Hat OpenShift to perform common 
data science tasks from data ingestion to inference monitoring.

See the <a href="#getting-started">Getting Started</a> to get started.

### Built With
- [Red Hat OpenShift Self-Managed on AWS](https://www.redhat.com/en/resources/self-managed-openshift-sizing-subscription-guide)
- [AWS SageMaker Notebooks](https://aws.amazon.com/pm/sagemaker/)
- [NVIDIA Triton Inference Server](https://docs.nvidia.com/launchpad/ai/classification-openshift/latest/openshift-classification-triton-overview.html)
- [Gradio User Interface](https://gradio.app/)
- Operators published by AWS and NVIDIA for Red Hat OpenShift improve autonomy.
  - [AWS Controller for Kubernetes Operators](https://operatorhub.io/?provider=%5B%22Amazon%22%5D): IAM, EC2, S3, SageMaker
  - [Hardware Acceleration](https://catalog.redhat.com/software/containers/nvidia/gpu-operator/5f9b0279ac3db90370a2128d)

<!-- GETTING STARTED -->
## Getting Started

If you have the demo installed, start at the `./notebooks/fingerprint/model_train_s3_leftright.ipynb`.
If not, see the <a href="#prerequisites">Prerequisites</a>.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Prerequisites

- [x] Red Hat OpenShift Cluster 4.9+
- [x] Cluster admin permissions
- [x] root `SSH` access to a bastion 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

SSH to your bastion node with cluster-admin

```commandline
# clone this repo for the bootstrap scripts
git clone https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git
cd demo-rosa-sagemaker/

# source the bootstrap scripts
source ./scripts/bootstrap.sh

# run the installation scripts
setup_demo
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

Intended to be run on Red Hat OpenShift Container Platform on AWS (self-managed).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap
- [ ] Add model training use cases to the notebook
  - [ ] Gender: Male, Female
  - [ ] Finger: Index, Middle, Ring, Little, Thumb
- [ ] Add other serving options
  - [ ] FastAPI
  - [ ] ModelMesh with Intel OpenVINO

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgements

- [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
- [Kaggle - Sokoto Coventry Fingerprint Dataset](https://www.kaggle.com/datasets/ruizgara/socofing)
- [TensorFlow Image Classification](https://www.tensorflow.org/tutorials/images/classification#use_tensorflow_lite)
- [TensorFlow Lite Image Classification](https://www.tensorflow.org/lite/models/modify/model_maker/image_classification#simple_end-to-end_example)