FROM centos

MAINTAINER smccarty@redhat.com

RUN yum install -y podman iproute audit procps-ng; yum clean all

RUN mkdir /podman-security-benchmark

COPY . /podman-security-benchmark

WORKDIR /podman-security-benchmark

ENTRYPOINT ["/bin/sh", "podman-security.sh"]
