# This output is meant to be used to inject a dependency on the generated
# assets. As of TerraForm v0.9, it is difficult to make a module depend on
# another module (no depends_on, no triggers), or to make a data source
# depend on a module (no depends_on, no triggers, generally no dummy variable).
#
# For instance, using the 'archive_file' data source against the generated
# assets, which is a common use-case, is tricky. There is no mechanism for
# defining explicit dependencies and the only available variables are for the
# source, destination and archive type, leaving little opportunities for us to
# inject a dependency. Thanks to the property described below, this output can
# be used as part of the output filename, in order to enforce the creation of
# the archive after the assets have been properly generated.
#
# Both localfile and template_dir providers compute their IDs by hashing
# the content of the resources on disk. Because this output is computed from the
# combination of all the resources' IDs, it can't be guessed and can only be
# interpolated once the assets have all been created.
output "id" {
  value = "${sha1("${var.controller_names} ${var.worker_names} ${local_file.controller_kubeconfig.id} ${local_file.admin_kubeconfig.id} ${local_file.controller_manifest_etcd.id} ${local_file.controller_manifest_scheduler.id} ${local_file.controller_manifest_controller_manager.id}")}"
}

output "install_id" {
  value = "${sha1("${template_dir.install.id}")}"
}

# Output files
output "controller_kubeconfig" {
  value = "${data.template_file.controller_kubeconfig.*.rendered}"
}

output "kube_controller_manager_kubeconfig" {
  value = "${data.template_file.kube_controller_manager_kubeconfig.rendered}"
}

output "controller_manifest_etcd" {
  value = "${data.template_file.controller_manifest_etcd.rendered}"
}

output "controller_manifest_apiserver" {
  value = "${data.template_file.controller_manifest_apiserver.rendered}"
}

output "controller_manifest_controller_manager" {
  value = "${data.template_file.controller_manifest_controller_manager.rendered}"
}

output "controller_manifest_scheduler" {
  value = "${data.template_file.controller_manifest_scheduler.rendered}"
}

output "install_output_directory" {
  value = "${template_dir.install.destination_dir}"
}

# PKI
output "ca_cert" {
  value = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert}"
}

output "ca_key_alg" {
  value = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
}

output "ca_key" {
  value = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
}

# APIServer TLS
output "apiserver_cert" {
  value = "${join(" ", tls_locally_signed_cert.apiserver.*.cert_pem)}"
}

output "apiserver_key_alg" {
  value = "${join(" ", tls_locally_signed_cert.apiserver.*.key_algorithm)}"
}

output "apiserver_key" {
  value = "${join(" ", tls_private_key.apiserver.*.private_key_pem)}"
}

output "service_account_key" {
  value = "${join(" ", tls_private_key.service-account.*.private_key_pem)}"
}

# Machines
output "controller_names" {
  value = "${var.controller_names}"
}
output "controller_macs" {
  value = "${var.controller_macs}"
}
output "worker_names" {
  value = "${var.worker_names}"
}
output "worker_macs" {
  value = "${var.worker_macs}"
}









