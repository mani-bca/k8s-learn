https://v1-27.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

apt update
apt-cache madison kubeadm

# replace x in 1.28.x-* with the latest patch version
sudo apt-mark unhold kubeadm && \
sudo apt-get update && apt-get install -y kubeadm='1.28.x-*' && \
sudo apt-mark hold kubeadm

kubeadm version

kubeadm upgrade plan

sudo kubeadm upgrade apply v1.28.5

# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets

# replace x in 1.28.x-* with the latest patch version
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet='1.28.x-*' kubectl='1.28.x-*' && \
apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon <node-to-uncordon>


