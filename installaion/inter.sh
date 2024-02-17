#!/bin/sh

sudo apt update -y

#sudo apt -y full-upgrade
#[ -f /var/run/reboot-required ] && sudo reboot -f

   #2) Install kubelet, kubeadm and kubectl

sudo apt install curl apt-transport-https ca-certificates -y

curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install wget curl vim git kubelet kubeadm kubectl -y

sudo apt-mark hold kubelet kubeadm kubectl

sudo swapoff -a

sudo vim /etc/fstab # manual >>>> #/swap.img   none    swap    sw      0       0

sudo mount -a

free -h

    # Enable kernel modules and configure sysctl
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

    #1) Docker runtime

    # Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

    # Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

    # Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

    # Start and enable Services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

    # Configure persistent loading of modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

    # Ensure you load modules

sudo modprobe overlay
sudo modprobe br_netfilter

    # Set up required sysctl params

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF


    # Install Mirantis cri-dockerd as Docker Engine shim
    # Debian based systems ###

sudo apt update
sudo apt install git wget curl

VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
echo $VER

wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
tar xvf cri-dockerd-${VER}.amd64.tgz

sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

cri-dockerd --version

    # Configure systemd units for cri-dockerd:

wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service

wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket

sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/

sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

sudo systemctl daemon-reload

sudo systemctl enable cri-docker.service

sudo systemctl enable --now cri-docker.socket

#systemctl status cri-docker.socket

#systemctl status docker

    #5) Initialize control plane (run on first master node)

lsmod | grep br_netfilter

sudo systemctl enable kubelet

    # Docker kubeadm config images pull
sudo kubeadm config images pull --cri-socket /run/cri-dockerd.sock 

                    ###                {sudo vim /etc/hosts
                    ##              192.168.1.5 k8s.server.com }

sudo kubeadm init \
  --pod-network-cidr=10.20.0.0/16 \
  --cri-socket /run/cri-dockerd.sock  \
  --upload-certs \
#  --control-plane-endpoint=k8s.server.com


mkdir -p $HOME/.kube

sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl cluster-info

## modify kube-funnel file in network cider range line number 84

## modify metrics-server-components file and add ( - --kubelet-insecure-tls=true ) in line 139
kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl taint nodes --all  node-role.kubernetes.io/control-plane-


# Containerd
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8))

https://download.docker.com/linux/ubuntu/dists/jammy/InRelease: Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for details.

 https://download.docker.com/linux/ubuntu/dists/jammy/InRelease: Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for detail

 W0907 20:45:15.336295    6763 initconfiguration.go:120] Usage of CRI endpoints without URL scheme is deprecated and can cause kubelet errors in the future. Automatically prepending scheme "unix" to the "criSocket" with value "/run/cri-dockerd.sock". Please update your configuration!