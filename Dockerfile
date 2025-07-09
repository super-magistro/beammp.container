FROM debian:12

RUN apt-get update && apt-get install -y \
    curl wget jq tmux liblua5.3-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /beammp

COPY start.sh /start.sh
RUN mkdir -p /beammp/config
COPY config/ServerConfig.toml.template /config/ServerConfig.toml.template

RUN chmod +x /start.sh

VOLUME ["/beammp"]

CMD ["/start.sh"]

