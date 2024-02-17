#!/bin/bash

sudo apt update -y


#sudo apt -y full-upgrade
#[ -f /var/run/reboot-required ] && sudo reboot -f

#2) Install kubelet, kubeadm and kubectl

sudo apt install curl apt-transport-https -y

curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install wget curl vim git kubelet kubeadm kubectl -y

sudo apt-mark hold kubelet kubeadm kubectl

kubectl version --client

# Disable Swap Space

sudo swapoff -a 

sudo sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

sudo mount -a

free -h

# Enable kernel modules

sudo modprobe overlay

sudo modprobe br_netfilter

# Add some settings to sysctl

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl

sudo sysctl --system

# Install Container runtime (Master and Worker nodes)

# Installing Containerd

# Configure persistent loading of modules

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime

sudo modprobe overlay

sudo modprobe br_netfilter

# Ensure sysctl params are set

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs

sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward


# Install required packages

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd

sudo apt update

sudo apt install -y containerd.io

# Configure containerd and start service  8079879fkhkfhsdkfskfgsfik 

sudo mkdir -p /etc/containerd

sudo containerd config default|sudo tee /etc/containerd/config.toml

# restart containerd

sudo systemctl restart containerd

sudo systemctl enable containerd

systemctl status containerd

#  Initialize control plane

lsmod | grep br_netfilter

sudo systemctl enable kubelet

sudo kubeadm config images pull --cri-socket /run/containerd/containerd.sock
sudo kubeadm config images pull --cri-socket=unix:///run/containerd/containerd.sock
# Containerd
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.128.0.18

mkdir -p $HOME/.kube

sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl cluster-info



sudo kubeadm init --v=5 \
--upload-certs \
--control-plane-endpoint master.kubernetes.lab:6443 \
--pod-network-cidr=10.244.0.0/16 \
--ignore-preflight-errors=NumCPU

sudo ufw allow 6443/tcp
ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 10259/tcp
sudo ufw reload




sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw reload