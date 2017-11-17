# kube-matchbox-tf

This project is for deploying [Container Linux][8] and [Kubernetes][9] to bare metal environments using [matchbox][10] and [Terraform][1] and is inspired heavily by [munnerz/k8s-matchbox-tf][11]. The following components and add-ons are deployed with the cluster:

- etcd (one instance per master)
- kube-apiserver
- kube-scheduler
- kube-controller-manager
- kube-dns
- kube-proxy
- kube-dashboard
- heapster
- calico (for pod-to-pod networking and network policy)
- [update-operator][12] (for automated Container Linux updates)

## Prerequisites

### Nodes

Your cluster nodes need to be configured to [PXE boot][4].

### Terraform 

Terraform is used to configure `matchbox` programmatically. The latest version can be downloaded from the Terraform [website][1].

### Docker

[Docker][7] is required to build the local development environment. You can alternatively run everything directly on your local machine.

### Network

`matchbox` is used to PXE boot your VMs. To set up your network for this, follow CoreOS's [network setup][2] tutorial. It is required that Container Linux is [cached][3] by default. You can download Container Linux using the [get_coreos][5] script in the [matchbox][6] repository. If you do not want to use a cached version of Container Linux, make sure to use the `container-linux-install` profile instead of the `cached-container-linux-install` profile. These profiles can be found in the profiles Terraform module.

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
[7]: https://www.docker.com/
[8]: https://coreos.com/os/docs/latest/
[9]: https://kubernetes.io/docs/home/
[10]: https://coreos.com/matchbox/docs/latest/
[11]: https://github.com/munnerz/k8s-matchbox-tf
[12]: https://github.com/coreos/container-linux-update-operator