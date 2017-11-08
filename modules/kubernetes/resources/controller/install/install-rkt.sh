#!/bin/bash

/usr/bin/rkt run \
  --insecure-options=image \
  --trust-keys-from-https \
  --volume assets,kind=host,source=$(pwd) \
  --mount volume=assets,target=/assets \
  docker://${hyperkube_image} \
  --net=host \
  --dns=host \
  --exec=/bin/bash -- /assets/install.sh /assets "/hyperkube -- kubectl"
