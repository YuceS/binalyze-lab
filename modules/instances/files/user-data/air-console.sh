#!/bin/bash
export INIT_DIR='/tmp/binalyze'
export BOOTSTRAP_REPO='https://github.com/YuceS/binalyze-lab'
export BOOTSTRAP_DIR='bootstrap'
export BOOTSTRAP_SCRIPT='git-bootstrap.sh'
# Enable console logging
sudo systemctl enable serial-getty@ttyS0.service
sudo systemctl start serial-getty@ttyS0.service
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install the required for git bootstrapping
sudo apt-get update
sudo apt-get install git --yes
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    moreutils \
    --yes

mkdir -p ${INIT_DIR}
pushd ${INIT_DIR}
git init
git remote add -f origin https://github.com/YuceS/binalyze-lab.git
git config core.sparseCheckout true
echo ${BOOTSTRAP_DIR} >> .git/info/sparse-checkout
git clone ${BOOTSTRAP_REPO}
cd ${BOOTSTRAP_REPO##*/}/${BOOTSTRAP_DIR}
mkdir -p volumes/share
sudo chmod +x ${BOOTSTRAP_SCRIPT}  
sudo ./${BOOTSTRAP_SCRIPT}
