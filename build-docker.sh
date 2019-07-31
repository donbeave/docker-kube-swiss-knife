#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

PACKAGE="kube-swiss-knife"
VERSION="latest"

echo "> 1. Building Docker image"
echo ""
docker build -t donbeave/$PACKAGE:$VERSION .
