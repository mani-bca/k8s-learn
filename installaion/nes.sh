#!/bin/bash
#
# Kubernetes Installation Script for Ubuntu t2.medium
# Sets up a Kubernetes cluster using kubeadm with containerd runtime
#

# Exit immediately if a command exits with a non-zero status
set -e

echo "[STEP 1] System Update & Setup"
sudo apt update -y
sudo apt upgrade -y

# Disable swap
echo "[STEP 2] Disabling swap"
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

# Load kernel modules
echo "[STEP 3] Loading required kernel modules"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure system settings for Kubernetes
echo "[STEP 4] Configuring sysctl parameters for Kubernetes"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters without reboot
sudo sysctl --system

# Verify modules are loaded
echo "[STEP 5] Verifying modules are loaded"
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify system configurations
echo "[STEP 6] Verifying system configurations"
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Install containerd dependencies
echo "[STEP 7] Installing containerd dependencies"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Set up containerd repository
echo "[STEP 8] Setting up containerd repository"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd
echo "[STEP 9] Installing containerd"
sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd to use systemd as cgroup driver
echo "[STEP 10] Configuring containerd to use systemd as cgroup driver"
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart containerd
echo "[STEP 11] Restarting containerd"
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd --no-pager

echo "[STEP 12] Installing Kubernetes components"
# Set up Kubernetes repository
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download and add the Kubernetes apt key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "[STEP 13] Pulling Kubernetes images"
sudo kubeadm config images pull

echo "[STEP 14] Initializing Kubernetes control plane"
# Initialize Kubernetes control plane
# Change this hostname and IP address according to your environment
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)

echo "${CONTROL_PLANE_IP} ${HOSTNAME}" | sudo tee -a /etc/hosts

sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --upload-certs \
  --control-plane-endpoint="${HOSTNAME}:6443"

echo "[STEP 15] Setting up kubectl configuration"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[STEP 16] Installing Calico CNI"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

echo "[STEP 17] Verifying installation"
kubectl get nodes
kubectl get pods -A

echo "====================================================="
echo "Kubernetes cluster setup complete!"
echo "To join worker nodes to this cluster, use the kubeadm join command from the output above"
echo "====================================================="

# To allow scheduling pods on control plane (if this is a single-node cluster)
# Uncomment the line below if you want to use the control plane node as a worker
# kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# To check the join command later, you can run:
# kubeadm token create