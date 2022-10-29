#!/bin/bash
# This script installs and configures Docker and Docker-compose.

set -e

# check for root
if [[ "$(id -u)" != "0" ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# remove old versions
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

# install prerequisties
yum update -y
yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2

# add repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install packets
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# enable & start docker
systemctl start docker
systemctl enable docker

# check version
docker --version
docker compose version

# add user in docker group
usermod -aG docker user
