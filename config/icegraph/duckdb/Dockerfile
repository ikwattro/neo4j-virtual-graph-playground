FROM debian:12-slim
ARG TARGETARCH
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates && rm -rf /var/lib/apt/lists/*
RUN DUCKDB_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "amd64") && \
    curl -fsSL "https://github.com/duckdb/duckdb/releases/download/v1.2.2/duckdb_cli-linux-${DUCKDB_ARCH}.zip" \
    -o /tmp/duckdb.zip && \
    unzip /tmp/duckdb.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/duckdb && \
    rm /tmp/duckdb.zip
RUN duckdb -c "INSTALL httpfs; INSTALL iceberg;"
RUN mkdir -p /data
COPY init.sql /init.sql
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
VOLUME ["/data"]
ENTRYPOINT ["/entrypoint.sh"]
