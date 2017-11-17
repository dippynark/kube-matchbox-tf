// Install Container Linux to disk
resource "matchbox_group" "container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  name    = "${format("container-linux-install-%s", element(concat(var.controller_names, var.worker_names), count.index))}"
  profile = "${module.profiles.cached-container-linux-install}"

  selector {
    mac = "${element(concat(var.controller_macs, var.worker_macs), count.index)}"
  }

  metadata {
    container_linux_channel = "${var.container_linux_channel}"
    container_linux_version = "${var.container_linux_version}"
    container_linux_oem     = "${var.container_linux_oem}"
    ignition_endpoint       = "${var.matchbox_http_endpoint}/ignition"
    baseurl                 = "${var.matchbox_http_endpoint}/assets/coreos"
    ssh_authorized_key      = "${var.ssh_authorized_key}"
  }
}

// Provision controller
resource "matchbox_group" "kube-controller" {
  count   = "${length(var.controller_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.controller_names, count.index))}"
  profile = "${module.profiles.kube-controller}"

  selector {
    mac = "${element(var.controller_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name          = "${element(var.controller_domains, count.index)}"
    k8s_dns_service_ip   = "${var.kube_dns_service_ip}"
    ssh_authorized_key   = "${var.ssh_authorized_key}"
    mac_address          = "${element(var.controller_macs, count.index)}"

    # extra data
    kubelet_image_url = "docker://${element(split(":", var.container_images["hyperkube"]), 0)}"
    kubelet_image_tag = "${element(split(":", var.container_images["hyperkube"]), 1)}"
  }
}

//Provision worker
resource "matchbox_group" "kube-worker" {
  count   = "${length(var.worker_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.worker_names, count.index))}"
  profile = "${module.profiles.kube-worker}"

  selector {
    mac = "${element(var.worker_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name          = "${element(var.worker_domains, count.index)}"
    k8s_dns_service_ip   = "${var.kube_dns_service_ip}"
    ssh_authorized_key   = "${var.ssh_authorized_key}"
    mac_address          = "${element(var.worker_macs, count.index)}"

    # extra data
    kubelet_image_url = "docker://${element(split(":", var.container_images["hyperkube"]), 0)}"
    kubelet_image_tag = "${element(split(":", var.container_images["hyperkube"]), 1)}"
  }
}