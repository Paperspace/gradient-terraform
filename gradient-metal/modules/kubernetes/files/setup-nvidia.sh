#!/usr/bin/env sh
set -e

if [ ! "$POOL_TYPE" = "gpu" ];then
    exit 0
fi
if [ ! "$SETUP_NVIDIA" = "true" ];then
    exit 0
fi

arch=$(uname -m)
version_id=$(. /etc/os-release;echo $VERSION_ID)
version_digits=$(echo $version_id | tr -d ".")
os_id=$(. /etc/os-release;echo $ID)
distribution="$os_id$version_id"
cuda_distribution=$os_id$version_digits


update_default_runtime() {
    sudo tee /etc/docker/daemon.json <<EOT
    {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
            "max-size": "100m"
        },
        "storage-driver": "overlay2",
        "default-runtime": "nvidia",
        "runtimes": {
            "nvidia": {
                "path": "/usr/bin/nvidia-container-runtime",
                "runtimeArgs": []
            }
        }
    }
EOT
}

if [ "$os_id" = "ubuntu" ] || [ "$os_id" = "debian" ];then
    export DEBIAN_FRONTEND=noninteractive
    apt-get install curl -y

    # NVIDIA cuda drivers
    if [ -z "$(dpkg -l | grep cuda-drivers)" ];then
        curl -L https://developer.download.nvidia.com/compute/cuda/repos/$cuda_distribution/$arch/cuda-$cuda_distribution.pin -o /etc/apt/preferences.d/cuda-repository-pin-600
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$cuda_distribution/$arch/7fa2af80.pub
        add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/$cuda_distribution/$arch/ /"
        apt-get update
        apt-get -y install cuda-drivers
    fi

    # NVIDIA container toolkit
    if [ ! "$(docker info | grep "Default Runtime" | sed 's/.*Default Runtime: //')" = "nvidia" ];then
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
        apt-get update && sudo apt-get install -y nvidia-docker2
        service docker reload
        update_default_runtime
    fi

    if [ "$REBOOT" = "true" ]; then
        echo "Restarting GPU node..."
        shutdown --reboot +2 "System is rebooting for nvidia drivers to work" || true
    fi
fi
