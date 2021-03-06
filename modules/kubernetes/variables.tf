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

# Cluster
variable "cluster_name" {
  type = "string"

  description = <<EOF
The name of the cluster.

Note: This field MUST be set manually prior to creating the cluster.
EOF
}

variable "container_images" {
  description = "(internal) Container images to use"
  type        = "map"

  default = {
    hyperkube                   = "gcr.io/google_containers/hyperkube:v1.15.1"
    hyperkube_arm               = "gcr.io/google_containers/hyperkube-arm:v1.15.1"
    etcd                        = "quay.io/coreos/etcd:v3.3.10"
  }
}

variable "istio_namespace" {
  type = "string"
  default = "istio-system"
}

variable "istio_version" {
  type = "string"
  default = "0.4.0"
}

variable "verbosity" {
  type = "string"
  default = "1"
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
  type    = "string"
  default = "10.100.0.0/16"

  description = "This declares the IP range to assign Kubernetes pod IPs in CIDR notation."
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

variable "ca_cert" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The content of the PEM-encoded CA certificate, used to generate Tectonic Console's server certificate.
If left blank, a CA certificate will be automatically generated.
EOF
}

variable "ca_key_alg" {
  type    = "string"
  default = "RSA"

  description = <<EOF
(optional) The algorithm used to generate ca_key.
The default value is currently recommend.
This field is mandatory if `ca_cert` is set.
EOF
}

variable "ca_key" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The content of the PEM-encoded CA key, used to generate Tectonic Console's server certificate.
This field is mandatory if `ca_cert` is set.
EOF
}

variable "kubelet_bootstrap_token" {
  type = "string"
}

# Apiserver
variable "kube_apiserver_url" {
  description = "Secure URL used to reach kube-apiserver (e.g. https://cluster.example.com:443)"
  type        = "string"
}

# DNS
variable "kube_dns_service_ip" {
  type    = "string"
  default = "10.3.0.10"

  description = <<EOF
The Kubernetes service IP used to reach kube-dns inside the cluster
as returned by `kubectl -n kube-system get service kube-dns`.
EOF
}

# Etcd
variable "etcd_names" {
  description = "List of etcd endpoint names"
  type = "list"
}

variable "etcd_endpoints" {
  description = "List of etcd endpoints to connect with (hostnames/IPs only)"
  type        = "list"
}

variable "etcd_ca_cert_path" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The path of the file containing the CA certificate for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `etcd_servers`, `etcd_client_cert_path`, and `etcd_client_key_path` must also be set.
EOF
}

variable "etcd_client_cert_path" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The path of the file containing the client certificate for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `etcd_servers`, `etcd_ca_cert_path`, and `etcd_client_key_path` must also be set.
EOF
}

variable "etcd_client_key_path" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The path of the file containing the client key for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `etcd_servers`, `etcd_ca_cert_path`, and `etcd_client_cert_path` must also be set.
EOF
}


