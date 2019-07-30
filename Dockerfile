# Build Helm 3
FROM ubuntu:18.04 AS helm3

RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
               ca-certificates \
               wget \
               git \
               build-essential \
               curl \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/*

RUN set -ex \
    && wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz \
    && tar -xvf go1.12.7.linux-amd64.tar.gz \
    && mv go /usr/local

ENV GOPATH="/root/.go"
ENV GOROOT=/usr/local/go
ENV PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

RUN set -ex \
    && mkdir -p "${GOPATH}/bin" \
    && mkdir -p "${GOPATH}/src/github.com"

RUN curl https://glide.sh/get | sh

RUN set -ex \
    && cd $GOPATH/src/ \
    && mkdir -p helm.sh \
    && cd helm.sh \
    && git clone https://github.com/helm/helm.git \
    && cd helm \
    && git checkout 2f16e0ed26dc592bb1a0e4a0224aa7d1c28df18d \
    && make bootstrap build
# @end Build Helm 3


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
COPY --from=helm3 /root/.go/src/helm.sh/helm/bin/helm /usr/local/bin/helm
ENV HELM_HOME="/usr/local/helm3"
RUN mkdir -p ${HELM_HOME}
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
RUN curl -o /usr/local/bin/kubedog -sSL https://dl.bintray.com/flant/kubedog/v0.3.2/kubedog-linux-amd64-v0.3.2
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


COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["tail", "-f", "/dev/null"]
