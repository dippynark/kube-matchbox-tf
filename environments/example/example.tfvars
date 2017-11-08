# Matchbox
matchbox_http_endpoint = "http://matchbox.example.com:8080"
matchbox_rpc_endpoint = "matchbox.example.com:8081"

# Cluster
cluster_name = "example"

# CoreOS
container_linux_version = "1520.8.0"
container_linux_channel = "stable"
container_linux_oem = ""

# Machines
controller_names = ["node1"]
controller_macs = ["12:34:56:78:90:ab"]
controller_domains = ["node1.example.com"]
worker_names = []
worker_macs = []
worker_domains = []

# PKI
ssh_authorized_key = "ssh-rsa ..."

# API Server
kube_apiserver_url = "https://cluster.example.com:6443"
