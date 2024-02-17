#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add the Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add the Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the system again
sudo apt update

# Install containerd
sudo apt install -y containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load the required kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Set the required sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply the sysctl parameters
sudo sysctl --system

# Add the Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add the Kubernetes repository
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update the system again
sudo apt update

# Install kubeadm, kubelet and kubectl
sudo apt install -y kubelet kubeadm kubectl

# Hold the packages to prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl

# Set the cgroup driver for kubeadm to systemd
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
EOF

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Initialize the kubernetes cluster using kubeadm (change the pod network cidr according to your choice)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.128.0.17

# Copy the kubeconfig file to your home directory
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install the flannel pod network add-on (change the url according to your choice)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

