# Kubernetes CA (resources/tls/{ca.crt,ca.key})
resource "tls_private_key" "kube-ca" {
  count = "${var.ca_cert == "" ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "kube-ca" {
  count = "${var.ca_cert == "" ? 1 : 0}"

  key_algorithm   = "${tls_private_key.kube-ca.algorithm}"
  private_key_pem = "${tls_private_key.kube-ca.private_key_pem}"

  subject {
    common_name  = "kube-ca"
  }

  is_ca_certificate     = true
  validity_period_hours = 43800

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "local_file" "kube-ca-key" {
  content  = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
  filename = "${var.assets_dir}/tls/ca.key"
}

resource "local_file" "kube-ca-crt" {
  content  = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert}"
  filename = "${var.assets_dir}/tls/ca.crt"
}

# Kubernetes API Server (resources/tls/{apiserver.key,apiserver.crt})
resource "tls_private_key" "apiserver" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "apiserver" {
  key_algorithm   = "${tls_private_key.apiserver.algorithm}"
  private_key_pem = "${tls_private_key.apiserver.private_key_pem}"

  subject {
    common_name  = "kube-apiserver"
    organization = "kube-master"
  }

  dns_names = [
    "${replace(element(split(":", var.kube_apiserver_url), 1), "/", "")}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
  ]

  ip_addresses = [
    "${cidrhost(var.service_cidr, 1)}",
  ]
}

resource "tls_locally_signed_cert" "apiserver" {
  cert_request_pem = "${tls_cert_request.apiserver.cert_request_pem}"

  ca_key_algorithm   = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
  ca_private_key_pem = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
  ca_cert_pem        = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem): var.ca_cert}"

  validity_period_hours = 17520

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "apiserver-key" {
  content  = "${tls_private_key.apiserver.private_key_pem}"
  filename = "${var.assets_dir}/tls/apiserver.key"
}

resource "local_file" "apiserver-crt" {
  content  = "${tls_locally_signed_cert.apiserver.cert_pem}"
  filename = "${var.assets_dir}/tls/apiserver.crt"
}

# Kubelet
resource "tls_private_key" "kubelet" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "kubelet" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  key_algorithm   = "${element(tls_private_key.kubelet.*.algorithm, count.index)}"
  private_key_pem = "${element(tls_private_key.kubelet.*.private_key_pem, count.index)}"

  subject {
    common_name  = "system:node:${element(concat(var.controller_domains, var.worker_domains, var.extra_domains), count.index)}"
    organization = "system:nodes"
  }
}

resource "tls_locally_signed_cert" "kubelet" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  cert_request_pem = "${element(tls_cert_request.kubelet.*.cert_request_pem, count.index)}"

  ca_key_algorithm   = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
  ca_private_key_pem = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
  ca_cert_pem        = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "kubelet-key" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  content  = "${element(tls_private_key.kubelet.*.private_key_pem, count.index)}"
  filename = "${var.assets_dir}/tls/${element(concat(var.controller_names, var.worker_names, var.extra_names), count.index)}-kubelet.key"
}

resource "local_file" "kubelet-crt" {
  count = "${length(var.controller_names) + length(var.worker_names) + length(var.extra_names)}"

  content  = "${element(tls_locally_signed_cert.kubelet.*.cert_pem, count.index)}"
  filename = "${var.assets_dir}/tls/${element(concat(var.controller_names, var.worker_names, var.extra_names), count.index)}-kubelet.crt"
}

# Kube Proxy
resource "tls_private_key" "kube_proxy" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "kube_proxy" {
  key_algorithm   = "${tls_private_key.kube_proxy.algorithm}"
  private_key_pem = "${tls_private_key.kube_proxy.private_key_pem}"

  subject {
    common_name  = "system:kube-proxy"
  }
}

resource "tls_locally_signed_cert" "kube_proxy" {
  cert_request_pem = "${tls_cert_request.kube_proxy.cert_request_pem}"

  ca_key_algorithm   = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
  ca_private_key_pem = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
  ca_cert_pem        = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "kube_proxy_key" {
  content  = "${tls_private_key.kube_proxy.private_key_pem}"
  filename = "${var.assets_dir}/tls/kube-proxy.key"
}

resource "local_file" "kube_proxy_crt" {
  content  = "${tls_locally_signed_cert.kube_proxy.cert_pem}"
  filename = "${var.assets_dir}/tls/kube-proxy.crt"
}

# Kube Controller Manager
resource "tls_private_key" "kube_controller_manager" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "kube_controller_manager" {
  key_algorithm   = "${tls_private_key.kube_controller_manager.algorithm}"
  private_key_pem = "${tls_private_key.kube_controller_manager.private_key_pem}"

  subject {
    common_name  = "system:kube-controller-manager"
  }
}

resource "tls_locally_signed_cert" "kube_controller_manager" {
  cert_request_pem = "${tls_cert_request.kube_controller_manager.cert_request_pem}"

  ca_key_algorithm   = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
  ca_private_key_pem = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
  ca_cert_pem        = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "kube_controller_manager_key" {
  content  = "${tls_private_key.kube_controller_manager.private_key_pem}"
  filename = "${var.assets_dir}/tls/kube-controller-manager.key"
}

resource "local_file" "kube_controller_manager_crt" {
  content  = "${tls_locally_signed_cert.kube_controller_manager.cert_pem}"
  filename = "${var.assets_dir}/tls/kube-controller-manager.crt"
}

# Admin
resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "admin" {
  key_algorithm   = "${tls_private_key.admin.algorithm}"
  private_key_pem = "${tls_private_key.admin.private_key_pem}"

  subject {
    common_name  = "admin"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "admin" {
  cert_request_pem = "${tls_cert_request.admin.cert_request_pem}"

  ca_key_algorithm   = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.key_algorithm) : var.ca_key_alg}"
  ca_private_key_pem = "${var.ca_cert == "" ? join(" ", tls_private_key.kube-ca.*.private_key_pem) : var.ca_key}"
  ca_cert_pem        = "${var.ca_cert == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_cert}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# Kubernetes Service Account (resources/assets/tls/{service-account.key,service-account.pub})
resource "tls_private_key" "service-account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "service-account-key" {
  content  = "${tls_private_key.service-account.private_key_pem}"
  filename = "${var.assets_dir}/tls/service-account.key"
}

resource "local_file" "service-account-crt" {
  content  = "${tls_private_key.service-account.public_key_pem}"
  filename = "${var.assets_dir}/tls/service-account.pub"
}
