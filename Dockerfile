FROM debian:12

RUN apt-get update && apt-get install -y \
    curl wget jq tmux liblua5.3-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /beammp/config

COPY start.sh /beammp/start.sh
COPY config/ServerConfig.toml.template /beammp/config/ServerConfig.toml.template
COPY build.sh /beammp/build.sh
RUN chmod +x /beammp/start.sh
RUN chmod +x /beammp/build.sh

CMD ["/beammp/build.sh"]
CMD ["/beammp/start.sh"]

