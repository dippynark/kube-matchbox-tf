// Configure the matchbox provider
provider "matchbox" {
  endpoint    = "${var.matchbox_rpc_endpoint}"
  client_cert = "${file("/root/.matchbox/client.crt")}"
  client_key  = "${file("/root/.matchbox/client.key")}"
  ca          = "${file("/root/.matchbox/ca.crt")}"
}
