#!/bin/sh
set -e

apk update && apk add curl --no-cache
curl -sfL https://get.k3s.io | \
INSTALL_K3S_VERSION="v1.29.15+k3s1" \
INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" \
sh -