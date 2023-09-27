ARG VARIANT="17"

FROM mcr.microsoft.com/vscode/devcontainers/java:${VARIANT}

# ARG PROXY_HOST=host.docker.internal
# ARG PROXY_PORT=3128

# ENV http_proxy="http://${PROXY_HOST}:${PROXY_PORT}"
# ENV https_proxy=${http_proxy}

# ENV PROXY_HOST=${PROXY_HOST}
# ENV PROXY_PORT=${PROXY_PORT}

# COPY ./settings.xml /root/.m2/settings.xml

RUN echo 'alias ll="ls -l"' >> ~/.bashrc

# Docker from Docker approach
# https://github.com/microsoft/vscode-dev-containers/tree/main/containers/docker-from-docker

# Install Docker CE CLI
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install Docker Compose
# RUN LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
#     && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
#     && chmod +x /usr/local/bin/docker-compose

USER root

EXPOSE 3000