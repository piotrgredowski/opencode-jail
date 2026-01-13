FROM node:22-bookworm

RUN apt-get update && apt-get install -y \
    git curl wget vim dnsutils \
    iptables iproute2 sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u 1000 opencode-user
RUN npm install -g opencode-ai@latest

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
