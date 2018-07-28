# Matchbox
variable "config_version" {
  description = <<EOF
(internal) This declares the version of the Matchbox configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF
  default = "1.0"
}

variable "matchbox_http_endpoint" {
  type        = "string"
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "matchbox_rpc_endpoint" {
  type = "string"
  description = "Matchbox gRPC API endpoint (e.g. matchbox.example.com:8081)"
}

# Cluster 
variable "cluster_name" {
  type = "string"

  description = <<EOF
The name of the cluster.
If used in a cloud-environment, this will be prepended to `base_domain` resulting in the URL to the Tectonic console.

Note: This field MUST be set manually prior to creating the cluster.
EOF
}

# CoreOS
variable "container_linux_channel" {
  type        = "string"
  description = "Container Linux channel corresponding to the container_linux_version"
}

variable "container_linux_version" {
  type        = "string"
  description = "Container Linux version of the kernel/initrd to PXE or the image to install"
}

variable "container_linux_oem" {
  type        = "string"
  default     = ""
  description = "Specify an OEM image id to use as base for the installation (e.g. ami, vmware_raw, xen) or leave blank for the default image"
}

# Machines
variable "controller_names" {
  type = "list"
}

variable "controller_macs" {
  type = "list"
}

variable "controller_domains" {
  type = "list"
}

variable "worker_names" {
  type = "list"
}

variable "worker_macs" {
  type = "list"
}

variable "worker_domains" {
  type = "list"
}

variable "extra_names" {
  type = "list"
}

variable "extra_domains" {
  type = "list"
}

# Assets
variable "assets_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

# Networking
variable "cluster_cidr" {
  description = "CIDR IP range to assign Kubernetes pods"
  type        = "string"
  default     = "10.100.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IP range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns, the 15th IP will be reserved for self-hosted etcd, and the 200th IP will be reserved for bootstrap self-hosted etcd.
EOD
  type        = "string"
  default     = "10.3.0.0/16"
}

# PKI
variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key to set as an authorized_key on machines"
}

# API Server
variable "kube_apiserver_url" {
  description = "URL used to reach kube-apiserver"
  type        = "string"
}
