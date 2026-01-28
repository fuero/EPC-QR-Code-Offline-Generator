FROM alpine:3.23 as prep

SHELL ["/bin/sh", "-euc"]

RUN <<EOF
apk add --no-cache git
git clone https://github.com/quasistatic-setup/EPC-QR-Code-Offline-Generator /app
EOF

FROM alpine:3.23

RUN <<EOF
apk add --no-cache python3 curl
addgroup -S web
adduser -S web -G web
EOF

COPY --from=prep /app /app

WORKDIR /app
USER web

CMD ["python", "-m", "http.server", "-b", "0.0.0.0", "8000"]

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -k -s -L -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 | grep -qE "200|301|302|403|404"
