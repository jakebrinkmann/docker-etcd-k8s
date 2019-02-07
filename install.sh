#!/usr/bin/env bash
# Installs kubernetes from the Google repo

# All must be run as root
[ $(/usr/bin/id -u) -ne 0 ] \
    && echo 'Must be run as root!' \
    && exit 1

# Add Google K8s repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Turn off SELinux Security and Swap
setenforce 0
swapoff -a

# Install K8s, as well as CLI utilities
#   - kubelet: run commands on all machines
#   - kubeadm: bootstrap a cluster
#   - kubectl: talks to cluster
yum install -y \
    kubelet \
    kubeadm \
    kubectl

# Enable Kubelet to start on boot (if in an init system)
[ ! -f /.dockerenv ] \
  && systemctl enable kubelet \
  && systemctl start kubelet

# Configure NetworkPlugin to connect containers in Linux Bridge
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Update kubelet
sysctl --system
sysctl net.bridge.bridge-nf-call-iptables=1

# Download Kompose utility (convert docker-compose YAML into K8s YAML)
curl -fsSL -o /usr/local/bin/kompose \
  https://github.com/kubernetes/kompose/releases/download/v1.13.0/kompose-linux-amd64 \
  && chmod +x /usr/local/bin/kompose

