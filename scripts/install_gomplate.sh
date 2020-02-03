#!/bin/bash
set -eux

gomplate_version="3.6.0"

cd /tmp
curl -o /usr/local/bin/gomplate -sSL \
  https://github.com/hairyhenderson/gomplate/releases/download/v${gomplate_version}/gomplate_linux-amd64-slim
chmod +x /usr/local/bin/gomplate
/usr/local/bin/gomplate --version

/scripts/cleanup.sh
