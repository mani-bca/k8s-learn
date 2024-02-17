#!/bin/sh

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install containerd.io

ps -p 1

sudo mkdir -p /etc/containerd

sudo containerd config default|sudo tee /etc/containerd/config.toml

# echo "waiting for uodate contained ************************************************************"

# sleep 60

sudo tee /etc/containerd/config.toml<<EOF
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
EOF

sudo systemctl restart containerd

sudo systemctl enable containerd

sudo systemctl status containerd

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl


sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --upload-certs \
  --control-plane-endpoint=k8s.server.com

# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.128.0.2

sudo mkdir -p $HOME/.kube

sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl get ds -A 

kubectl edit ds weave-net -n kube-system

or wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

name --- weave under line 147
            - name: IPALLOC_RANGE
              value: 10.244.0.0/16  ,10.5.0.0/16

12sep master1
kubeadm join 10.128.0.26:6443 --token 4dz30d.d670n8x7lkuawx5c \
	--discovery-token-ca-cert-hash sha256:f9c4f47710a2537dd33a37870f1b0db3992b99c6c695fe63528fce6bba14743b 

kubeadm join 10.128.0.26:6443 --token mbkuzy.jucevqin05wn3e2v --discovery-token-ca-cert-hash sha256:f9c4f47710a2537dd33a37870f1b0db3992b99c6c695fe63528fce6bba14743b 

kubeadm.kubernetes.io/etcd.advertise-client-urls: https://172.31.63.152:2379

kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.31.63.152:6443

        port: 10257
               port: 10259
            2381
:wq
server.go:725] "--cgroups-per-qos enabled, but --cgroup-root was not specified.  defaulting to /"
 container_manager_linux.go:265] "Container manager verified user specified cgroup-root exists" cgroupRoot=[]











disabled_plugins = []
imports = []
oom_score = 0
plugin_dir = ""
required_plugins = []
root = "/var/lib/containerd"
state = "/run/containerd"
temp = ""
version = 2

[cgroup]
  path = ""

[debug]
  address = ""
  format = ""
  gid = 0
  level = ""
  uid = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216
  tcp_address = ""
  tcp_tls_ca = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0

[metrics]
  address = ""
  grpc_histogram = false

[plugins]

  [plugins."io.containerd.gc.v1.scheduler"]
    deletion_threshold = 0
    mutation_threshold = 100
    pause_threshold = 0.02
    schedule_delay = "0s"
    startup_delay = "100ms"

  [plugins."io.containerd.grpc.v1.cri"]
    device_ownership_from_security_context = false
    disable_apparmor = false
    disable_cgroup = false
    disable_hugetlb_controller = true
    disable_proc_mount = false
    disable_tcp_service = true
    enable_selinux = false
    enable_tls_streaming = false
    enable_unprivileged_icmp = false
    enable_unprivileged_ports = false
    ignore_image_defined_volumes = false
    max_concurrent_downloads = 3
    max_container_log_line_size = 16384
    netns_mounts_under_state_dir = false
    restrict_oom_score_adj = false
    sandbox_image = "registry.k8s.io/pause:3.6"
    selinux_category_range = 1024
    stats_collect_period = 10
    stream_idle_timeout = "4h0m0s"
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    systemd_cgroup = false
    tolerate_missing_hugetlb_controller = true
    unset_seccomp_profile = ""

    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      conf_template = ""
      ip_pref = ""
      max_conf_num = 1

    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "runc"
      disable_snapshot_annotations = true
      discard_unpacked_layers = false
      ignore_rdt_not_enabled_errors = false
      no_pivot = false
      snapshotter = "overlayfs"

      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        base_runtime_spec = ""
        cni_conf_dir = ""
        cni_max_conf_num = 0
        container_annotations = []
        pod_annotations = []
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_path = ""
        runtime_root = ""
        runtime_type = ""

        [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime.options]

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          base_runtime_spec = ""
          cni_conf_dir = ""
          cni_max_conf_num = 0
          container_annotations = []
          pod_annotations = []
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_path = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            BinaryName = ""
            CriuImagePath = ""
            CriuPath = ""
            CriuWorkPath = ""
            IoGid = 0
            IoUid = 0
            NoNewKeyring = false
            NoPivotRoot = false
            Root = ""
            ShimCgroup = ""
            SystemdCgroup = false

      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        base_runtime_spec = ""
        cni_conf_dir = ""
        cni_max_conf_num = 0
        container_annotations = []
        pod_annotations = []
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_path = ""
        runtime_root = ""
        runtime_type = ""

        [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime.options]

    [plugins."io.containerd.grpc.v1.cri".image_decryption]
      key_model = "node"

    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]

    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""

  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"

  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"

  [plugins."io.containerd.internal.v1.tracing"]
    sampling_ratio = 1.0
    service_name = "containerd"

  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"

  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false

  [plugins."io.containerd.runtime.v1.linux"]
    no_shim = false
    runtime = "runc"
    runtime_root = ""
    shim = "containerd-shim"
    shim_debug = false

  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
    sched_core = false

  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]

  [plugins."io.containerd.service.v1.tasks-service"]
    rdt_config_file = ""

  [plugins."io.containerd.snapshotter.v1.aufs"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.btrfs"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.devmapper"]
    async_remove = false
    base_image_size = ""
    discard_blocks = false
    fs_options = ""
    fs_type = ""
    pool_name = ""
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.native"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.overlayfs"]
    root_path = ""
    upperdir_label = false

  [plugins."io.containerd.snapshotter.v1.zfs"]
    root_path = ""

  [plugins."io.containerd.tracing.processor.v1.otlp"]
    endpoint = ""
    insecure = false
    protocol = ""

[proxy_plugins]

[stream_processors]

  [stream_processors."io.containerd.ocicrypt.decoder.v1.tar"]
    accepts = ["application/vnd.oci.image.layer.v1.tar+encrypted"]
    args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    path = "ctd-decoder"
    returns = "application/vnd.oci.image.layer.v1.tar"

  [stream_processors."io.containerd.ocicrypt.decoder.v1.tar.gzip"]
    accepts = ["application/vnd.oci.image.layer.v1.tar+gzip+encrypted"]
    args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    path = "ctd-decoder"
    returns = "application/vnd.oci.image.layer.v1.tar+gzip"

[timeouts]
  "io.containerd.timeout.bolt.open" = "0s"
  "io.containerd.timeout.shim.cleanup" = "5s"
  "io.containerd.timeout.shim.load" = "5s"
  "io.containerd.timeout.shim.shutdown" = "3s"
  "io.containerd.timeout.task.state" = "2s"

[ttrpc]
  address = ""
  gid = 0
  uid = 0





 Sep 11 10:57:08 ip-172-31-63-152 systemd[1]: Started kubelet: The Kubernetes Node Agent.
Sep 11 10:57:08 ip-172-31-63-152 kubelet[9919]: Flag --container-runtime-endpoint has been deprecated, This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/admini>
Sep 11 10:57:08 ip-172-31-63-152 kubelet[9919]: Flag --pod-infra-container-image has been deprecated, will be removed in a future release. Image garbage collector will get sandbox image information from CRI.
Sep 11 10:57:08 ip-172-31-63-152 kubelet[9919]: I0911 10:57:08.813145    9919 server.go:203] "--pod-infra-container-image will not be pruned by the image garbage collector in kubelet and should also be set in the remote runtime"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.506047    9919 server.go:467] "Kubelet version" kubeletVersion="v1.28.1"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.506095    9919 server.go:469] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.506440    9919 server.go:895] "Client rotation is on, will bootstrap in background"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.511809    9919 dynamic_cafile_content.go:157] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.514471    9919 certificate_manager.go:562] kubernetes.io/kube-apiserver-client-kubelet: Failed while requesting a signed certificate from the control plane: cannot create cer>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520170    9919 server.go:725] "--cgroups-per-qos enabled, but --cgroup-root was not specified.  defaulting to /"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520475    9919 container_manager_linux.go:265] "Container manager verified user specified cgroup-root exists" cgroupRoot=[]
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520682    9919 container_manager_linux.go:270] "Creating Container Manager object based on Node Config" nodeConfig={"RuntimeCgroupsName":"","SystemCgroupsName":"","KubeletCgr>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520720    9919 topology_manager.go:138] "Creating topology manager with none policy"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520735    9919 container_manager_linux.go:301] "Creating device plugin manager"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520826    9919 state_mem.go:36] "Initialized new in-memory state store"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520930    9919 kubelet.go:393] "Attempting to sync node with API server"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520947    9919 kubelet.go:298] "Adding static pod path" path="/etc/kubernetes/manifests"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520972    9919 kubelet.go:309] "Adding apiserver pod source"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.520991    9919 apiserver.go:42] "Waiting for node sync before watching apiserver pods"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.523826    9919 kuberuntime_manager.go:257] "Container runtime initialized" containerRuntime="containerd" version="1.6.22" apiVersion="v1"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: W0911 10:57:09.524201    9919 probe.go:268] Flexvolume plugin directory at /usr/libexec/kubernetes/kubelet-plugins/volume/exec/ does not exist. Recreating.
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.524826    9919 server.go:1232] "Started kubelet"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: W0911 10:57:09.525090    9919 reflector.go:535] vendor/k8s.io/client-go/informers/factory.go:150: failed to list *v1.Service: Get "https://172.31.63.152:6443/api/v1/services?limit=500&resou>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.525285    9919 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.Service: failed to list *v1.Service: Get "https://172.31.63.152:6443/ap>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.527250    9919 fs_resource_analyzer.go:67] "Starting FS ResourceAnalyzer"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: W0911 10:57:09.527422    9919 reflector.go:535] vendor/k8s.io/client-go/informers/factory.go:150: failed to list *v1.Node: Get "https://172.31.63.152:6443/api/v1/nodes?fieldSelector=metadat>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.527518    9919 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.Node: failed to list *v1.Node: Get "https://172.31.63.152:6443/api/v1/n>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.527580    9919 event.go:289] Unable to write event: '&v1.Event{TypeMeta:v1.TypeMeta{Kind:"", APIVersion:""}, ObjectMeta:v1.ObjectMeta{Name:"ip-172-31-63-152.1783d2f3d5a6db4f">
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.528030    9919 cri_stats_provider.go:448] "Failed to get the info of the filesystem with mountpoint" err="unable to find data in memory cache" mountpoint="/var/lib/containerd>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.528065    9919 kubelet.go:1431] "Image garbage collection failed once. Stats initialization may not have completed yet" err="invalid capacity 0 on image filesystem"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.529883    9919 server.go:162] "Starting to listen" address="0.0.0.0" port=10250
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.530633    9919 server.go:462] "Adding debug handlers to kubelet server"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.531865    9919 ratelimit.go:65] "Setting rate limiting for podresources endpoint" qps=100 burstTokens=10
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.532039    9919 server.go:233] "Starting to serve the podresources API" endpoint="unix:/var/lib/kubelet/pod-resources/kubelet.sock"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.533017    9919 volume_manager.go:291] "Starting Kubelet Volume Manager"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.533140    9919 desired_state_of_world_populator.go:151] "Desired state populator starts to run"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.533223    9919 reconciler_new.go:29] "Reconciler: start to sync state"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: W0911 10:57:09.533548    9919 reflector.go:535] vendor/k8s.io/client-go/informers/factory.go:150: failed to list *v1.CSIDriver: Get "https://172.31.63.152:6443/apis/storage.k8s.io/v1/csidri>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.533603    9919 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.CSIDriver: failed to list *v1.CSIDriver: Get "https://172.31.63.152:644>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.535242    9919 controller.go:146] "Failed to ensure lease exists, will retry" err="Get \"https://172.31.63.152:6443/apis/coordination.k8s.io/v1/namespaces/kube-node-lease/lea>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.561677    9919 cpu_manager.go:214] "Starting CPU manager" policy="none"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.562032    9919 cpu_manager.go:215] "Reconciling" reconcilePeriod="10s"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.562219    9919 state_mem.go:36] "Initialized new in-memory state store"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.568893    9919 policy_none.go:49] "None policy: Start"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.570123    9919 memory_manager.go:169] "Starting memorymanager" policy="None"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.570562    9919 state_mem.go:35] "Initializing new in-memory state store"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.599618    9919 manager.go:471] "Failed to read data from checkpoint" checkpoint="kubelet_internal_checkpoint" err="checkpoint is not found"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.599919    9919 plugin_manager.go:118] "Starting Kubelet Plugin Manager"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.602347    9919 eviction_manager.go:258] "Eviction manager: failed to get summary stats" err="failed to get node info: node \"ip-172-31-63-152\" not found"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.635148    9919 kubelet_node_status.go:70] "Attempting to register node" node="ip-172-31-63-152"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.635562    9919 kubelet_node_status.go:92] "Unable to register node with API server" err="Post \"https://172.31.63.152:6443/api/v1/nodes\": dial tcp 172.31.63.152:6443: connec>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.672295    9919 kubelet_network_linux.go:50] "Initialized iptables rules." protocol="IPv4"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.673455    9919 kubelet_network_linux.go:50] "Initialized iptables rules." protocol="IPv6"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.673487    9919 status_manager.go:217] "Starting to sync pod status with apiserver"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: I0911 10:57:09.673510    9919 kubelet.go:2303] "Starting kubelet main sync loop"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.673575    9919 kubelet.go:2327] "Skipping pod synchronization" err="PLEG is not healthy: pleg has yet to be successful"
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: W0911 10:57:09.674403    9919 reflector.go:535] vendor/k8s.io/client-go/informers/factory.go:150: failed to list *v1.RuntimeClass: Get "https://172.31.63.152:6443/apis/node.k8s.io/v1/runtim>
Sep 11 10:57:09 ip-172-31-63-152 kubelet[9919]: E0911 10:57:09.674450    9919 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.RuntimeClass: failed to list *v1.RuntimeClass: Get "https://172.31.63.1>