FROM debian:jessie-slim

RUN apt-get update && \
    apt-get install -y \
        openssl \
        curl \
        bash \
        python \
        make \
        graphviz \
        jq \
        unzip \
        fonts-liberation && \
    rm -rf /var/lib/apt/lists

# Install gcloud SDK
ENV GCLOUD_VERSION 178.0.0
ENV GCLOUD_HASH 2e0bbbf81c11164bf892cf0b891751ba4e5172661eff907ad1f7fc0b6907e296
RUN cd /tmp && \
    curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz > /tmp/gcloud.tar.gz && \
    echo "${GCLOUD_HASH}  /tmp/gcloud.tar.gz" | sha256sum -c && \
    tar xvf /tmp/gcloud.tar.gz && \
    /tmp/google-cloud-sdk/install.sh && \
    rm -rfv /tmp/gcloud*

# Add gcloud binaries to PATH
ENV PATH /tmp/google-cloud-sdk/bin:$PATH

RUN gcloud components install -q kubectl

# Install terraform
ENV TERRAFORM_VERSION 0.10.8
ENV TERRAFORM_HASH b786c0cf936e24145fad632efd0fe48c831558cc9e43c071fffd93f35e3150db
RUN cd /tmp && \
    curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > /tmp/terraform.zip && \
    echo "${TERRAFORM_HASH}  /tmp/terraform.zip" | sha256sum -c && \
    unzip /tmp/terraform.zip && \
    mv terraform /usr/local/bin && \
    rm -rfv /tmp/terraform*

# Install matchbox terraform provider
ENV MATCHBOX_TERRAFORM_PROVIDER_VERSION v0.1.2
ENV MATCHBOX_TERRAFORM_PROVIDER_HASH 8eea005b67754edee3deddd6b788471b21b8edb77ad1bf3b2c3934eef29c3766
RUN cd /tmp && \
    curl -L https://github.com/coreos/terraform-provider-matchbox/releases/download/${MATCHBOX_TERRAFORM_PROVIDER_VERSION}/terraform-provider-matchbox-${MATCHBOX_TERRAFORM_PROVIDER_VERSION}-linux-amd64.tar.gz > /tmp/plugin.tar.gz && \
    echo "${MATCHBOX_TERRAFORM_PROVIDER_HASH}  /tmp/plugin.tar.gz" | sha256sum -c && \
    tar xvf /tmp/plugin.tar.gz && \
    mv terraform-provider-matchbox-${MATCHBOX_TERRAFORM_PROVIDER_VERSION}-linux-amd64/* /usr/local/bin && \
    rm -rfv /tmp/terraform-provider-matchbox-${MATCHBOX_TERRAFORM_PROVIDER_VERSION}-linux-amd64* plugin.tar.gz

# Install helm
ENV HELM_VERSION v2.4.1
RUN cd /tmp && \
    curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz > /tmp/helm.tar.gz && \
    tar xvf /tmp/helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin && \
    rm -rfv /tmp/linux-amd64*

ENV HOME /root
# copy contents of the git
WORKDIR /terraform
ADD . /terraform