FROM ubuntu:18.04

MAINTAINER Alexey Zhokhov <alexey@zhokhov.com>

ENV DEBIAN_FRONTEND noninteractive


# Locale config
RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
               locales \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/*

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN locale-gen en_US.UTF-8

ADD locale.sh /
RUN chmod a+x /locale.sh
RUN /locale.sh
# @end Locale config


# Install basic dependencies
RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
               ca-certificates \
               apt-transport-https \
               ssh \
               net-tools \
               software-properties-common \
               procps \
               dnsutils \
               unzip \
               zip \
               git \
               nano \
               curl \
               wget \
               httpie \
               gpg-agent \
               dirmngr \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/*
# @end Install basic dependencies


# Install Helm 3
RUN set -ex \
    && cd /tmp \
    && wget https://get.helm.sh/helm-v3.0.0-beta.4-linux-amd64.tar.gz \
    && tar -xzvf helm-v3.0.0-beta.4-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod 755 /usr/local/bin/helm \
    && rm helm-v3.0.0-beta.4-linux-amd64.tar.gz \
    && rm -rf /tmp/*
RUN helm version
# @end Install Helm 3


# Install gomplate
RUN curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v3.5.0/gomplate_linux-amd64-slim
RUN chmod 755 /usr/local/bin/gomplate
RUN gomplate --version
# @end Install gomplate


# Install Docker
RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
               apt-transport-https \
               ca-certificates \
               curl \
               gnupg2 \
               software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/*
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
               docker-ce \
               docker-ce-cli \
               containerd.io \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/*
# @end Install Docker


# Install kubectl
RUN curl -o /usr/local/bin/kubectl -sSL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod 755 /usr/local/bin/kubectl
RUN kubectl version --client=true
RUN mkdir -p $HOME/.kube/
# @end Install kubectl


# Install kubedog
RUN curl -o /usr/local/bin/kubedog -sSL https://dl.bintray.com/flant/kubedog/v0.3.4/kubedog-linux-amd64-v0.3.4
RUN chmod 755 /usr/local/bin/kubedog
# @end Install kubedog


# Install kubectx
RUN curl -o /usr/local/bin/kubectx -sSL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx
RUN chmod 755 /usr/local/bin/kubectx
# @end Install kubectx


# Install kubens
RUN curl -o /usr/local/bin/kubens -sSL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
RUN chmod 755 /usr/local/bin/kubens
# @end Install kubens


# Install Flyway
RUN set -ex \
    && cd /tmp \
    && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/5.2.4/flyway-commandline-5.2.4-linux-x64.tar.gz \
    && tar -xzvf flyway-commandline-5.2.4-linux-x64.tar.gz \
    && mv flyway-5.2.4 /usr/local \
    && ln -s /usr/local/flyway-5.2.4/flyway /usr/local/bin \
    && rm flyway-commandline-5.2.4-linux-x64.tar.gz \
    && rm -rf /tmp/*
# @end Install Flyway


COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["tail", "-f", "/dev/null"]
