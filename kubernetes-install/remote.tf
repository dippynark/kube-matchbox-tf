# Secure copy kubeconfig to all nodes
resource "null_resource" "copy-config" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  triggers {
    kubeconfig = "${module.kubernetes.controller_kubeconfig[count.index]}"
    kube_controller_manager_kubeconfig = "${module.kubernetes.kube_controller_manager_kubeconfig}"
    ca_cert = "${module.kubernetes.ca_cert}"
    id = "${module.kubernetes.install_id}"
  }

  connection {
    type    = "ssh"
    host    = "${element(concat(var.controller_domains, var.worker_domains), count.index)}"
    user    = "core"
    timeout = "60m"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent = false
  }
  
  provisioner "file" {
    content     = "${module.kubernetes.controller_kubeconfig[count.index]}"
    destination = "/home/core/kubeconfig"
  }

  provisioner "file" {
    content     = "${module.kubernetes.kube_proxy_kubeconfig}"
    destination = "/home/core/kube-proxy-kubeconfig"
  }

  provisioner "file" {
    content     = "${module.kubernetes.kube_controller_manager_kubeconfig}"
    destination = "/home/core/kube-controller-manager-kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes",
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig", 
      "sudo mv /home/core/kube-proxy-kubeconfig /etc/kubernetes/kube-proxy-kubeconfig",
      "sudo mv /home/core/kube-controller-manager-kubeconfig /etc/kubernetes/kube-controller-manager-kubeconfig", 
    ]
  }
}

# Template node-specific vars into etcd manifest. We do this
# here so that the Kubernetes module can provide a single stable
# output for the Kubernetes configuration. In future, this may
# change so that multiple Controller manifests are output, but
# only one consistent worker manifest is produced.
data "template_file" "controller_manifest_etcd" {
  count = "${length(var.controller_domains)}"
  template = "${module.kubernetes.controller_manifest_etcd}"

  vars {
    domain_name = "${element(var.controller_domains, count.index)}"
    etcd_name = "${element(var.controller_names, count.index)}"
  }
}

data "template_file" "controller_manifest_apiserver" {
  count = "${length(var.controller_domains)}"
  template = "${module.kubernetes.controller_manifest_apiserver}"

  vars {
    domain_name = "${element(var.controller_domains, count.index)}"
  }
}

resource "null_resource" "controller_bootstrap" {
  count = "${length(var.controller_domains)}"

  triggers {
    id = "${module.kubernetes.id}"

    ca = "${module.kubernetes.ca_cert}"
    ca_key = "${module.kubernetes.ca_key}"
    apiserver_crt = "${module.kubernetes.apiserver_cert}"
    apiserver_key = "${module.kubernetes.apiserver_key}"
    service_account_key = "${module.kubernetes.service_account_key}"
  }

  connection {
    type    = "ssh"
    host    = "${element(var.controller_domains, count.index)}"
    user    = "core"
    timeout = "60m"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  # Manifests
  provisioner "file" {
    content     = "${element(data.template_file.controller_manifest_etcd.*.rendered, count.index)}"
    destination = "$HOME/etcd.yaml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.controller_manifest_apiserver.*.rendered, count.index)}"
    destination = "$HOME/kube-apiserver.yaml"
  }

  provisioner "file" {
    content     = "${module.kubernetes.controller_manifest_controller_manager}"
    destination = "$HOME/kube-controller-manager.yaml"
  }

  provisioner "file" {
    content     = "${module.kubernetes.controller_manifest_scheduler}"
    destination = "$HOME/kube-scheduler.yaml"
  }

  # PKI
  provisioner "file" {
    content     = "${module.kubernetes.ca_cert}"
    destination = "$HOME/ca.crt"
  }

  provisioner "file" {
    content     = "${module.kubernetes.ca_key}"
    destination = "$HOME/ca.key"
  }

  provisioner "file" {
    content     = "${module.kubernetes.apiserver_cert}"
    destination = "$HOME/apiserver.crt"
  }

  provisioner "file" {
    content     = "${module.kubernetes.apiserver_key}"
    destination = "$HOME/apiserver.key"
  }

  provisioner "file" {
    content     = "${module.kubernetes.service_account_key}"
    destination = "$HOME/service-account.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/tls /etc/kubernetes/manifests",
      # Copy controller manifests into place
      "sudo mv /home/core/etcd.yaml /home/core/kube-apiserver.yaml /home/core/kube-controller-manager.yaml /home/core/kube-scheduler.yaml /etc/kubernetes/manifests/",
      # Copy TLS files into place
      "sudo mv /home/core/ca.crt /home/core/ca.key /home/core/apiserver.crt /home/core/apiserver.key /home/core/service-account.key /etc/kubernetes/tls/",
    ]
  }
}

resource "null_resource" "worker_bootstrap" {
  count = "${length(var.worker_domains)}"

  triggers {
    id = "${module.kubernetes.id}"

    ca = "${module.kubernetes.ca_cert}"
  }

  connection {
    type    = "ssh"
    host    = "${element(var.worker_domains, count.index)}"
    user    = "core"
    timeout = "60m"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  # PKI
  provisioner "file" {
    content     = "${module.kubernetes.ca_cert}"
    destination = "$HOME/ca.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/tls",
      # Copy TLS files into place
      "sudo mv /home/core/ca.crt /etc/kubernetes/tls/",
    ]
  }

}

resource "null_resource" "install_addons" {
  connection {
    type    = "ssh"
    host    = "${var.controller_domains[0]}"
    user    = "core"
    timeout = "60m"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  triggers {
    id = "${module.kubernetes.install_id}"
  }

  provisioner "file" {
    source = "${module.kubernetes.install_output_directory}"
    destination = "$HOME/kubernetes"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/kubernetes",
      "sudo cp -R /home/core/kubernetes/ /opt/ && sudo rm -Rf /home/core/kubernetes",
      "cd /opt/kubernetes",
      "sudo /bin/bash ./install-rkt.sh",
    ]
  }
}
