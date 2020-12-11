#! /usr/bin/env sh
set -e

if [ ! "$SETUP_DOCKER" = "true" ];then
    exit 0
fi
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce=5:19.03.14~3-0~ubuntu-bionic
usermod -G docker $DOCKER_USER
