#!/bin/bash

set -uex

echo "Checking for installed cuda-drivers..."
if dpkg -l | grep -q cuda-drivers; then
    echo "Found cuda-drivers:"
    dpkg -l | grep cuda-drivers
else
    echo "No cuda-drivers currently installed"
fi

CUDA_DRIVER_VERSION=565

killall Xorg || true
nvidia-smi -pm 0

apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /"
apt-get purge -qqy "cuda-drivers*" "*nvidia*-${CUDA_DRIVER_VERSION}"
apt-get install -qqy "cuda-drivers"

sudo modprobe -r nvidia_drm nvidia_uvm nvidia_modeset nvidia
nvidia-smi -pm 1
nvidia-smi

# Install nvidia-container-toolkit

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update --allow-insecure-repositories
apt-get install -y nvidia-container-toolkit

nvidia-ctk runtime configure --runtime=docker
systemctl restart docker
