#!/bin/bash

# debug
id
whoami

# run from repo
curl -sL https://raw.githubusercontent.com/redhat-na-ssa/demo-rosa-sagemaker/main/sagemaker/lifecycle-on-start.sh | bash
