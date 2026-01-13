FROM ubuntu:24.04

# 1. Install dependencies and Firejail
RUN apt-get update && apt-get install -y \
    firejail \
    curl \
    ca-certificates \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 2. Install OpenCode (adjusting to their official install script)
RUN curl -fsSL https://opencode.ai/install | bash

# 3. Create a non-root user (Firejail prefers this)
RUN useradd -m opencode-user
USER opencode-user
WORKDIR /home/opencode-user

ENTRYPOINT ["firejail"]