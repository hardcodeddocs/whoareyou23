FROM alpine:3.20
ARG XRAY_VERSION=1.8.24

RUN apk add --no-cache curl unzip ca-certificates tor \
 && curl -fsSL -o /tmp/x.zip \
    https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip \
 && unzip /tmp/x.zip xray -d /usr/local/bin \
 && chmod +x /usr/local/bin/xray && rm /tmp/x.zip

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
