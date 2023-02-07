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
##  The Project
![](docs/ml-lifecycle-sm-ocp.png)

Explore the data science toolbox that are in reach when you have Red Hat OpenShift on AWS. 

### The Scenario
The scenario we use was to train a model that could predict suspect attributes from an unknown fingerprint. 
For example, in the data center or in the field, this model could help down-select possible suspects given an unseen fingerprint. 
Since we only had public data, the predictions are basic, but the possibilities are what we intend to inspire.

### The demo
This demo covers several topics across the lifecycle for extending Red Hat OpenShift to perform common 
data science tasks from data ingestion to inference monitoring.

Training Notebook             |  Inference UI
:-------------------------:|:-------------------------:
![sagemaker notebook](docs/sagemaker-notebook.png) | ![gradion fingerprint user interface](docs/gradio-fingerprint-ui.png)

See the <a href="#getting-started">Getting Started</a> to get started.

### Built With
- [Red Hat OpenShift Self-Managed on AWS](https://www.redhat.com/en/resources/self-managed-openshift-sizing-subscription-guide)
- [AWS SageMaker Notebooks](https://aws.amazon.com/pm/sagemaker/)
- [NVIDIA Triton Inference Server](https://docs.nvidia.com/launchpad/ai/classification-openshift/latest/openshift-classification-triton-overview.html)
- [Gradio User Interface](https://gradio.app/)
- [AWS Controller for Kubernetes Operators](https://operatorhub.io/?provider=%5B%22Amazon%22%5D): IAM, EC2, S3, SageMaker
- [Hardware Acceleration](https://catalog.redhat.com/software/containers/nvidia/gpu-operator/5f9b0279ac3db90370a2128d)

<!-- GETTING STARTED -->
## Getting Started

If you have the demo installed, start at the `./notebooks/fingerprint/model_train_s3_leftright.ipynb`.
If not, see the <a href="#prerequisites">Prerequisites</a>.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Prerequisites

- [x] Red Hat OpenShift Cluster 4.10+
- [x] Cluster admin permissions
- [x] `oc` cli installed locally
- [x] `python36` cli installed

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

```commandline
# SSH to your cluster node with cluster-admin
oc login --token=sha256~<your_token>

# clone this repo for the bootstrap scripts
git clone https://github.com/redhat-na-ssa/demo-rosa-sagemaker.git
cd demo-rosa-sagemaker/

# run bootstrap to provision the demo on your cluster
./scripts/bootstrap.sh

# optionally, you can `source ./scripts/bootstrap.sh` and run commands individually, i.e.
setup_demo
delete_demo
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

### Intended Usage

Intended to be run on Red Hat OpenShift Container Platform on AWS (self-managed). Alternatively, Red Hat OpenShift on AWS (managed). 
Extend RHOCP with AWS capabilities.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap
- [ ] create branch `RHODS`
  - use RHODS notebook
  - use elyra
  - ModelMesh with Intel OpenVINO for serving
- [ ] create branch `ODH`
  - use ODH notebook
  - use airflow
  - use FastAPI for serving
- [ ] create branch `edge`
  - deploy the tflite model to edge device with Ansible
  - test fingerprint
- [ ] create branch `djl`
  - use djl.ai for model dev

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