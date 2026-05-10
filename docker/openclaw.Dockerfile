FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    APT_LISTCHANGES_FRONTEND=none \
    NEEDRESTART_MODE=a \
    OPENCLAW_HOME=/workspace/.openclaw \
    OPENCLAW_STATE_DIR=/workspace/.openclaw

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq bash \
  && npm install -g openclaw \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY scripts/start-openclaw.sh /usr/local/bin/start-openclaw.sh
RUN chmod +x /usr/local/bin/start-openclaw.sh

ENTRYPOINT ["/usr/local/bin/start-openclaw.sh"]
