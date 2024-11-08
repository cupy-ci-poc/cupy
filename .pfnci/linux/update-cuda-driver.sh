#!/bin/bash

set -ue

echo "Checking for installed cuda-drivers..."
if dpkg -l | grep -q cuda-drivers; then
    echo "Found cuda-drivers:"
    dpkg -l | grep cuda-drivers
else
    echo "No cuda-drivers currently installed"
fi

killall Xorg || true
# nvidia-smi -pm 0

apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /"
apt-get purge -qqy "cuda-drivers*" "*nvidia*-${CUDA_DRIVER_VERSION}"
apt-get install -qqy "cuda-drivers"

modprobe -r nvidia_drm nvidia_uvm nvidia_modeset nvidia
# nvidia-smi -pm 1
nvidia-smi
