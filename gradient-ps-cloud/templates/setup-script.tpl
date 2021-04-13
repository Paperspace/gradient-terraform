#!/usr/bin/env bash

sudo su -

until docker ps -a || (( count++ >= 30 )); do echo "Check if docker is up..."; sleep 2; done

usermod -G docker paperspace

mkdir -p /sys/fs/cgroup/pids/podruntime.slice
mkdir -p /sys/fs/cgroup/hugetlb/podruntime.slice
mkdir -p /sys/fs/cgroup/cpuset/podruntime.slice
mkdir -p /sys/fs/cgroup/cpu/podruntime.slice
mkdir -p /sys/fs/cgroup/memory/podruntime.slice
mkdir -p /sys/fs/cgroup/systemd/podruntime.slice

cat <<EOL > /etc/docker/daemon.json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
%{ if gpu_enabled ~}
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
%{ endif ~}
    "registry-mirrors": ["${registry_mirror}", "https://mirror.gcr.io"]
}
EOL

service docker reload

echo "${ssh_public_key}" >> /home/paperspace/.ssh/authorized_keys

export MACHINE_ID=`curl -s https://metadata.paperspace.com/meta-data/machine | grep id | sed 's/^.*: "\(.*\)".*/\1/'`
export MACHINE_PRIVATE_IP=`curl -s https://metadata.paperspace.com/meta-data/machine | grep privateIpAddress | sed 's/^.*: "\(.*\)".*/\1/'`
export MACHINE_PUBLIC_IP=`curl -s https://metadata.paperspace.com/meta-data/machine | grep publicIpAddress | sed 's/^.*: "\(.*\)".*/\1/'`

%{ if kind == "main" ~}
${rancher_command} \
    --etcd --controlplane \
    --address $MACHINE_PUBLIC_IP \
    --internal-address $MACHINE_PRIVATE_IP
%{ endif ~}

%{ if kind == "main_single" ~}
${rancher_command} \
    --etcd --controlplane --worker \
    --label paperspace.com/pool-name=services-small \
    --label paperspace.com/pool-type=cpu \
    --address $MACHINE_PUBLIC_IP
%{ endif ~}

%{ if kind == "autoscale_worker" ~}
${rancher_command} \
    --worker \
    --label paperspace.com/pool-name=${pool_name} \
    --label paperspace.com/pool-type=${pool_type} \
    --label provider.autoscaler/prefix=paperspace \
    --label provider.autoscaler/nodeName=$MACHINE_ID \
    --node-name $MACHINE_ID \
    --address $MACHINE_PRIVATE_IP
%{ endif ~}

%{ if kind == "worker" ~}
${rancher_command} \
    --worker \
    --label paperspace.com/pool-name=${pool_name} \
    --label paperspace.com/pool-type=${pool_type} \
    --node-name $MACHINE_ID \
    --address $MACHINE_PRIVATE_IP
%{ endif ~}

%{ if kind == "worker_public" ~}
${rancher_command} \
    --worker \
    --label paperspace.com/pool-name=${pool_name} \
    --label paperspace.com/pool-type=${pool_type} \
    --node-name $MACHINE_ID \
    --address $MACHINE_PUBLIC_IP \
    --internal-address $MACHINE_PRIVATE_IP
%{ endif ~}
