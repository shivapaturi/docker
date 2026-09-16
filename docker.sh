#!/bin/bash


# Docker

sudo dnf -y install dnf-plugins-core

sudo dnf config-manager --add-repo \
  https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable --now docker

sudo usermod -aG docker ec2-user

# Storage

sudo growpart /dev/nvme0n1 4

sudo lvextend -L +20G /dev/RootVG/rootVol
sudo lvextend -L +10G /dev/RootVG/varVol

sudo xfs_growfs /
sudo xfs_growfs /var

# eksctl

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO \
  "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"

tar -xzf "eksctl_${PLATFORM}.tar.gz" -C /tmp

sudo install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

rm -f "eksctl_${PLATFORM}.tar.gz"
rm -f /tmp/eksctl


# kubectl

curl -LO \
  "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo install -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl

# Git

sudo dnf install -y git


# kubectx / kubens

sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx

sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens


# Verification

echo "=============================="
echo "Docker:"
docker --version

echo "Docker Compose:"
docker compose version

echo "eksctl:"
eksctl version

echo "kubectl:"
kubectl version --client

echo "Git:"
git --version

echo "kubectx:"
kubectx --help >/dev/null 2>&1 && echo "kubectx installed"

echo "kubens:"
kubens --help >/dev/null 2>&1 && echo "kubens installed"

echo "=============================="
echo "Installation completed!"