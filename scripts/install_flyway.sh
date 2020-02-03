#!/bin/bash
set -eux

flyway_version="6.0.8"

cd /tmp
curl -o /tmp/flyway-commandline-${flyway_version}-linux-x64.tar.gz -sSL \
  https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${flyway_version}/flyway-commandline-${flyway_version}-linux-x64.tar.gz
tar -xzvf /tmp/flyway-commandline-${flyway_version}-linux-x64.tar.gz
mv flyway-${flyway_version} /usr/local
ln -s /usr/local/flyway-${flyway_version}/flyway /usr/local/bin
/usr/local/bin/flyway -v
