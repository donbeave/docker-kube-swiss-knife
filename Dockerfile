FROM debian:buster

MAINTAINER Alexey Zhokhov <alexey@zhokhov.com>

ENV DEBIAN_FRONTEND noninteractive

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

ADD scripts /scripts
RUN chmod a+x /scripts/*

RUN /scripts/install_locales_utf8.sh
RUN /scripts/install_helm.sh
RUN /scripts/install_docker.sh
RUN /scripts/install_flyway.sh
RUN /scripts/install_gomplate.sh


# Install kubectl
RUN curl -o /usr/local/bin/kubectl -sSL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod 755 /usr/local/bin/kubectl
RUN kubectl version --client=true
RUN mkdir -p $HOME/.kube/
# @end Install kubectl


# Install kubedog
RUN curl -o /usr/local/bin/kubedog -sSL https://dl.bintray.com/flant/kubedog/v0.4.0/kubedog-linux-amd64-v0.4.0
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
