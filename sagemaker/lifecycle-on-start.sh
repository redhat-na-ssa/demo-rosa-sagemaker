#!/bin/bash
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples

# setup ocp / k8s / misc tools
curl -sL https://raw.githubusercontent.com/redhat-na-ssa/demo-rosa-sagemaker/main/sagemaker/setup-k8s-tools.sh | bash

setup_packages(){

set -e

# OVERVIEW
# This script installs a single pip package in a single SageMaker conda environments.

sudo -u ec2-user -i <<'EOF'

# PARAMETERS
PACKAGE=tensorflow==2.11
ENVIRONMENT=tensorflow2_p38

source /home/ec2-user/anaconda3/bin/activate "$ENVIRONMENT"

conda info --envs

pip install -U pip
pip install --upgrade "$PACKAGE"

source /home/ec2-user/anaconda3/bin/deactivate

EOF

}

setup_idle(){

# OVERVIEW
# This script stops a SageMaker notebook once it's idle for more than 60 minutes (default time)
# You can change the idle time for stop using the environment variable below.
# If you want the notebook the stop only if no browsers are open, remove the --ignore-connections flag
#
# Note that this script will fail if either condition is not met
#   1. Ensure the Notebook Instance has internet connectivity to fetch the example config
#   2. Ensure the Notebook Instance execution role permissions to SageMaker:StopNotebookInstance to stop the notebook 
#       and SageMaker:DescribeNotebookInstance to describe the notebook.
#

# PARAMETERS
IDLE_TIME=3600

echo "Fetching the autostop script"
SCRIPT=https://raw.githubusercontent.com/redhat-na-ssa/demo-rosa-sagemaker/main/sagemaker/autostop.py
wget "${SCRIPT}"


echo "Detecting Python install with boto3 install"

# Find which install has boto3 and use that to run the cron command. So will use default when available
# Redirect stderr as it is unneeded
if /usr/bin/python3 -c "import boto3" 2>/dev/null; then
    PYTHON_DIR='/usr/bin/python3'
elif /usr/bin/python -c "import boto3" 2>/dev/null; then
    PYTHON_DIR='/usr/bin/python'
else
    # If no boto3 just quit because the script won't work
    echo "No boto3 found in Python or Python3. Exiting..."
    exit 1
fi

echo "Found boto3 at $PYTHON_DIR"


echo "Starting the SageMaker autostop script in cron"

(crontab -l 2>/dev/null; echo "*/5 * * * * $PYTHON_DIR $PWD/autostop.py --time $IDLE_TIME --ignore-connections >> /var/log/jupyter.log") | crontab -
}

setup_packages
setup_idle
