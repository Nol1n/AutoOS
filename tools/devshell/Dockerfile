FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential git curl python3-venv python3-pip qemu-kvm libvirt-daemon-system \
    libvirt-clients virtinst swtpm && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
COPY . /workspace
CMD ["/bin/bash"]
