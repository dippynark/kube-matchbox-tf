#!/bin/bash

set -x

export ASSETS_DIR=$1
alias kubectl="$2"

wait_for_apiserver() {
    while true ; do
        if ! kubectl get nodes ; then
            sleep 5;
        else
            return;
        fi
    done
}

echo "## Waiting for apiserver"
wait_for_apiserver

kubectl apply -Rf $ASSETS_DIR/manifests/
