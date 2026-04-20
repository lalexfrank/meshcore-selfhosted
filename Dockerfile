FROM alpine:3.19

LABEL org.opencontainers.image.title="MeshCore Self-Hosted" \
      org.opencontainers.image.description="Self-hosted MeshCore web application with auto-updates" \
      org.opencontainers.image.url="https://github.com/lalexfrank/meshcore-selfhosted" \
      org.opencontainers.image.source="https://github.com/lalexfrank/meshcore-selfhosted" \
      net.unraid.docker.webui="http://[IP]:[PORT:80]/" \
      net.unraid.docker.icon="https://raw.githubusercontent.com/lalexfrank/meshcore-selfhosted/main/icon.png"

RUN apk add --no-cache nginx curl unzip && \
    mkdir -p /app/web /run/nginx

COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
