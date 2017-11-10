// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded container_linux_version into matchbox assets.
resource "matchbox_profile" "cached-container-linux-install" {
  name   = "cached-container-linux-install"
  kernel = "/assets/coreos/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"
}

// Container Linux Install profile
resource "matchbox_profile" "container-linux-install" {
  name   = "container-linux-install"
  kernel = "http://stable.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "http://stable.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"
}

// Create a simple profile which just sets an SSH authorized_key
resource "matchbox_profile" "simple-install" {
  name                   = "simple-install"
  container_linux_config = "${file("${path.module}/cl/simple.yaml.tmpl")}"
}

// Self-hosted Kubernetes controller profile
resource "matchbox_profile" "kube-controller" {
  name                   = "kube-controller"
  container_linux_config = "${file("${path.module}/cl/kube-controller.yaml.tmpl")}"
}

// Self-hosted Kubernetes worker profile
resource "matchbox_profile" "kube-worker" {
  name                   = "kube-worker"
  container_linux_config = "${file("${path.module}/cl/kube-worker.yaml.tmpl")}"
}