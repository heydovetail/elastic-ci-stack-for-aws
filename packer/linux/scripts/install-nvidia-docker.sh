#!/bin/bash
set -eu -o pipefail

echo "Updating core packages"
sudo yum update -y

echo "Installing nvidia docker runtime..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
sudo yum clean expire-cache
sudo yum-config-manager --disable amzn2-graphics
sudo yum install -y nvidia-container-toolkit nvidia-container-runtime nvidia-docker2
sudo yum-config-manager --enable amzn2-graphics

jq ' . + { "runtimes": { "nvidia": { "path": "nvidia-container-runtime", "runtimeArgs": [] } }, "default-runtime": "nvidia"}' /etc/docker/daemon.json > /etc/docker/daemon.json.tmp && \
mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

sudo systemctl daemon-reload
sudo systemctl enable docker.service