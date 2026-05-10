FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive \
    APT_LISTCHANGES_FRONTEND=none \
    NEEDRESTART_MODE=a

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ca-certificates jq vim wget python3 python3-pip \
    procps iproute2 net-tools dnsutils file unzip tar bash-completion \
    xfce4 xfce4-goodies xfce4-terminal \
    dbus-x11 x11-xserver-utils \
    tigervnc-standalone-server websockify novnc \
    docker.io docker-compose-plugin \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
