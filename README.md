# kube-matchbox-tf

This project is for deploying Kubernetes to bare metal environments using matchbox and Terraform. The following components and add-ons are deployed with the cluster:

- etcd
- kube-apiserver
- kube-scheduler
- kube-controller-manager
- kube-dns
- kube-proxy
- kube-dashboard
- heapster
- calico (for pod-to-pod networking and network policy)

## Prerequisites

### Nodes

Your cluster nodes need to be configured to [PXE boot][4].

### Terraform 

Terraform is used to configure matchbox programmatically. The latest version can be downloaded from the Terraform [website][1].

### Docker

Docker is required to build the local development environment. You can alternatively run everything directly on your local machine.

### Network

Matchbox is used to PXE boot your VMs. To set up your network for this, follow CoreOS's [network setup][2] tutorial. It is required that CoreOS is [cached][3] by default. You can download CoreOS using the [get_coreos][5] script in the [matchbox][6] repository. If you do not want to do this, make sure to use the `container-linux-install` profile instead of the `cached-container-linux-install` profile. These profiles can be found in the profiles Terraform module.

## Quickstart

```bash
# Create environment tfvars file. An example can be found at environments/example
export STATE_BUCKET_NAME=terraform-state-bucket
make docker_image
make docker_tf_init
make docker_tf_plan
make docker_tf_apply
# Start machines in the same domain as matchbox
```

[1]: https://www.terraform.io/
[2]: https://coreos.com/matchbox/docs/latest/network-setup.html
[3]: https://coreos.com/matchbox/docs/latest/api.html#assets
[4]: https://coreos.com/os/docs/latest/booting-with-ipxe.html
[5]: https://github.com/coreos/matchbox/blob/master/scripts/get-coreos
[6]: https://github.com/coreos/matchbox
