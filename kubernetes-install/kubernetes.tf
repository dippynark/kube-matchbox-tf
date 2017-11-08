// Self-hosted Kubernetes cluster
module "kubernetes" {
  source = "../modules/kubernetes"  

  # Matchbox
  matchbox_http_endpoint = "${var.matchbox_http_endpoint}"

  # Cluster
  cluster_name = "${var.cluster_name}"
  
  # CoreOS
  container_linux_channel = "${var.container_linux_channel}"
  container_linux_version = "${var.container_linux_version}"
  container_linux_oem = "${var.container_linux_oem}"

  # Machines
  controller_names   = "${var.controller_names}"
  controller_macs    = "${var.controller_macs}"
  controller_domains = "${var.controller_domains}"
  worker_names       = "${var.worker_names}"
  worker_macs        = "${var.worker_macs}"
  worker_domains     = "${var.worker_domains}"

  # Assets
  assets_dir  = "${var.assets_dir}"

  # PKI
  ssh_authorized_key     = "${var.ssh_authorized_key}" 

  # Etcd
  etcd_names           = "${var.controller_names}"
  etcd_endpoints       = "${var.controller_domains}"
  
  # API Server
  kube_apiserver_url = "${var.kube_apiserver_url}"

  kubelet_bootstrap_token = "${random_id.kubelet_bootstrap_token.hex}"
}

resource "random_id" "kubelet_bootstrap_token" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    # ami_id = "${var.ami_id}"
  }

  byte_length = 64
}
