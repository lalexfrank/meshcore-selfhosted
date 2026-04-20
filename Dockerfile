FROM alpine:3.19

RUN apk add --no-cache nginx curl unzip && \
    mkdir -p /app/web /run/nginx

COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
