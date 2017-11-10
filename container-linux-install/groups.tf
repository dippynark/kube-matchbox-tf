// Default matcher group for machines
resource "matchbox_group" "container-linux-install" {
  count = "${length(var.machine_names)}"

  name    = "${format("container-linux-install-%s", element(var.machine_names, count.index))}"
  profile = "${matchbox_profile.cached-container-linux-install.name}"

  selector {
    mac = "${element(var.machine_macs, count.index)}"
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

// Match machines which have CoreOS Container Linux installed
resource "matchbox_group" "simple" {
  count = "${length(var.machine_names)}"

  name    = "${format("simple-%s", element(var.machine_names, count.index))}"
  profile = "${matchbox_profile.simple.name}"

  selector {
    mac = "${element(var.machine_macs, count.index)}"
    os = "installed"
  }

  metadata {
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}
