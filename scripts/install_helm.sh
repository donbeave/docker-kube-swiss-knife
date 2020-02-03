#!/bin/bash
set -eux

helm_version="3.0.3"

cd /tmp
curl -o /tmp/helm-v${helm_version}-linux-amd64.tar.gz -sSL https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz
tar -xzvf /tmp/helm-v${helm_version}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm
/usr/local/bin/helm version

/scripts/cleanup.sh
