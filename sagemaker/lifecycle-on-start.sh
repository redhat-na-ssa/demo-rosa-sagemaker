#!/bin/bash
# https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples

setup_cmds(){
# setup ocp / k8s / misc tools
curl -sL https://raw.githubusercontent.com/redhat-na-ssa/demo-rosa-sagemaker/main/sagemaker/setup-k8s-tools.sh | bash
}

add_branding(){

# we want a real bash shell
echo "export SHELL=/bin/bash" >> /etc/profile.d/jupyter-env.sh

# bash it more - just to make sure
NB_CFG=/home/ec2-user/.jupyter/jupyter_notebook_config.py
sed -i '/^c.NotebookApp.terminado_settings.*/d'
echo "
c.NotebookApp.terminado_settings = {'shell_command': ['/bin/bash']}
" >> ${NB_CFG}

# engage lab dark mode
LAB_CFG=/home/ec2-user/.jupyter/lab/user-settings/@jupyterlab/apputils-extension
[ ! -d "$LAB_CFG" ] && mkdir -p "$LAB_CFG"
echo '{"theme": "JupyterLab Dark"}' > ${LAB_CFG}/themes.jupyterlab-settings

# restart command is dependent on current running Amazon Linux and JupyterLab
CURR_VERSION_AL=$(cat /etc/system-release)
CURR_VERSION_JS=$(jupyter --version)

if [[ $CURR_VERSION_JS == *$"jupyter_core     : 4.9.1"* ]] && [[ $CURR_VERSION_AL == *$" release 2018"* ]]; then
	sudo initctl restart jupyter-server --no-wait
else
	sudo systemctl --no-block restart jupyter-server.service
fi
}

setup_packages(){

set -e

# OVERVIEW
# This script installs a single pip package in a single SageMaker conda environments.

sudo -u ec2-user -i <<'EOF'

# PARAMETERS
PACKAGE=tensorflow==2.11

source /home/ec2-user/anaconda3/bin/activate

conda info --envs

ENVIRONMENT=$(conda info --envs \
  | grep tensorflow2 \
  | awk '{print $1}')

echo "Conda ENV: $ENVIRONMENT"

source /home/ec2-user/anaconda3/bin/activate "$ENVIRONMENT"

pip install -U pip
pip install --upgrade "$PACKAGE"

conda deactivate

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

setup_cmds
setup_packages
setup_idle

add_branding