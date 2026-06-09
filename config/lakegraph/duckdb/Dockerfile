FROM debian:12-slim
ARG TARGETARCH
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates && rm -rf /var/lib/apt/lists/*
RUN DUCKDB_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "amd64") && \
    curl -fsSL "https://github.com/duckdb/duckdb/releases/download/v1.2.2/duckdb_cli-linux-${DUCKDB_ARCH}.zip" \
    -o /tmp/duckdb.zip && \
    unzip /tmp/duckdb.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/duckdb && \
    rm /tmp/duckdb.zip
# Pre-install httpfs extension so it's baked into the image (no internet needed at runtime)
RUN duckdb -c "INSTALL httpfs;"
RUN mkdir -p /data
COPY duckdbrc /root/.duckdbrc
COPY init.sql /init.sql
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
VOLUME ["/data"]
ENTRYPOINT ["/entrypoint.sh"]
