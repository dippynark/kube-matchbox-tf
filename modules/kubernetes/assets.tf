# kubelet kubeconfig
data "template_file" "kubelet_kubeconfig" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  template = "${file("${path.module}/resources/controller/kubeconfig")}"

  vars {
    ca_cert      = "${base64encode(var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert)}"
    cert = "${base64encode(element(tls_locally_signed_cert.kubelet.*.cert_pem, count.index))}"
    key  = "${base64encode(element(tls_private_key.kubelet.*.private_key_pem, count.index))}"
    server       = "${var.kube_apiserver_url}"
    user = "kubelet"
  }
}

resource "local_file" "kubelet_kubeconfig" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  content  = "${element(data.template_file.kubelet_kubeconfig.*.rendered, count.index)}"
  filename = "${var.assets_dir}/controller/${element(concat(var.controller_names, var.worker_names, var.extra_names), count.index)}-kubeconfig"
}

# kube-proxy kubeconfig
data "template_file" "kube_proxy_kubeconfig" {
  template = "${file("${path.module}/resources/controller/kubeconfig")}"

  vars {
    ca_cert      = "${base64encode(var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert)}"
    cert = "${base64encode(tls_locally_signed_cert.kube_proxy.cert_pem)}"
    key  = "${base64encode(tls_private_key.kube_proxy.private_key_pem)}"
    server       = "${var.kube_apiserver_url}"
    user = "kube-proxy"
  }
}

resource "local_file" "kube_proxy_kubeconfig" {
  content  = "${data.template_file.kube_proxy_kubeconfig.rendered}"
  filename = "${var.assets_dir}/controller/kube-proxy-kubeconfig"
}

# kube-controller-manager kubeconfig
data "template_file" "kube_controller_manager_kubeconfig" {
  template = "${file("${path.module}/resources/controller/kubeconfig")}"

  vars {
    ca_cert      = "${base64encode(var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert)}"
    cert = "${base64encode(tls_locally_signed_cert.kube_controller_manager.cert_pem)}"
    key  = "${base64encode(tls_private_key.kube_controller_manager.private_key_pem)}"
    server       = "${var.kube_apiserver_url}"
    user = "kube-controller-manager"
  }
}

resource "local_file" "kube_controller_manager_kubeconfig" {
  content  = "${data.template_file.kube_controller_manager_kubeconfig.rendered}"
  filename = "${var.assets_dir}/controller/kube-controller-manager-kubeconfig"
}

# admin kubeconfig
data "template_file" "admin_kubeconfig" {
  template = "${file("${path.module}/resources/controller/kubeconfig")}"

  vars {
    ca_cert    = "${base64encode(var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert)}"
    cert = "${base64encode(tls_locally_signed_cert.admin.cert_pem)}"
    key  = "${base64encode(tls_private_key.admin.private_key_pem)}"
    server     = "${var.kube_apiserver_url}"
    user = "admin"
  }
}

resource "local_file" "admin_kubeconfig" {
  content  = "${data.template_file.admin_kubeconfig.rendered}"
  filename = "${var.assets_dir}/admin/kubeconfig"
}

# etcd manifest
data "template_file" "controller_manifest_etcd" {
    template = "${file("${path.module}/resources/controller/manifests/etcd.yaml")}"

    vars {
        etcd_image = "${var.container_images["etcd"]}"
        etcd_initial_cluster = "${join(",", formatlist("%s=http://%s:2380", var.etcd_names, var.etcd_endpoints))}"
        etcd_initial_cluster_token = "cluster-token"
    }
}

resource "local_file" "controller_manifest_etcd" {
  content  = "${data.template_file.controller_manifest_etcd.rendered}"
  filename = "${var.assets_dir}/controller/manifests/etcd.yaml"
}

# kube-apiserver manifest
data "template_file" "controller_manifest_apiserver" {
    template = "${file("${path.module}/resources/controller/manifests/kube-apiserver.yaml")}"
    
    vars {
      verbosity = "${var.verbosity}"
      service_cidr = "${var.service_cidr}"
      hyperkube_image = "${var.container_images["hyperkube"]}"
      secure_port = "${replace(element(split(":", var.kube_apiserver_url), 2), "/", "")}"
    }
}

resource "local_file" "controller_manifest_apiserver" {
  content  = "${data.template_file.controller_manifest_apiserver.rendered}"
  filename = "${var.assets_dir}/controller/manifests/kube-apiserver.yaml"
}

# kube-controller-manager manifest
data "template_file" "controller_manifest_controller_manager" {
    template = "${file("${path.module}/resources/controller/manifests/kube-controller-manager.yaml")}"
    
    vars {
      verbosity = "${var.verbosity}"
      hyperkube_image = "${var.container_images["hyperkube"]}"
      cluster_cidr        = "${var.cluster_cidr}"
    }
}

resource "local_file" "controller_manifest_controller_manager" {
  content  = "${data.template_file.controller_manifest_controller_manager.rendered}"
  filename = "${var.assets_dir}/controller/manifests/kube-controller-manager.yaml"
}

# kube-scheduler manifest
data "template_file" "controller_manifest_scheduler" {
    template = "${file("${path.module}/resources/controller/manifests/kube-scheduler.yaml")}"
    
    vars {
      verbosity = "${var.verbosity}"
      hyperkube_image = "${var.container_images["hyperkube"]}"
    }
}

resource "local_file" "controller_manifest_scheduler" {
  content  = "${data.template_file.controller_manifest_scheduler.rendered}"
  filename = "${var.assets_dir}/controller/manifests/kube-scheduler.yaml"
}

# install manifests
# Self-hosted manifests (resources/assets/manifests/)
resource "template_dir" "install" {
  source_dir      = "${path.module}/resources/controller/install"
  destination_dir = "${var.assets_dir}/controller/install"

  vars {
    hyperkube_image                   = "${var.container_images["hyperkube"]}"
    hyperkube_arm_image               = "${var.container_images["hyperkube_arm"]}"

    flannel_image                     = "${var.container_images["flannel"]}"
    flannel_arm_image                 = "${var.container_images["flannel_arm"]}"

    istio_version                     = "${var.istio_version}"
    istio_namespace                   = "${var.istio_namespace}"
    # If there is only one master, standalone_master_domain will be set to its domain
    # Otherwise this will be set to the empty string
    # This is to make sure the update operator schedules again after an update when there is a single master
    standalone_master_domain          = "${replace(replace("1", "/^${length(var.controller_domains)}$/", element(var.controller_domains, 0)), "/^1$/", "\"\"")}"

    etcd_endpoints = "${join(",", formatlist("http://%s:2379", var.etcd_endpoints))}"

    # Choose the etcd endpoints to use.
    # 1. If experimental mode is enabled (self-hosted etcd), then use
    # var.etcd_service_ip.
    # 2. Else if no etcd TLS certificates are provided, i.e. we bootstrap etcd
    # nodes ourselves (using http), then use insecure http var.etcd_endpoints.
    # 3. Else (if etcd TLS certific are provided), then use the secure https
    # var.etcd_endpoints.
    service_cidr        = "${var.service_cidr}"
    cluster_cidr        = "${var.cluster_cidr}"
    kube_dns_service_ip = "${var.kube_dns_service_ip}"
  }
}
