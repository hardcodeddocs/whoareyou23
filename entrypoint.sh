#!/bin/sh
set -e
: "${VPN_UUID:?Set VPN_UUID}"
: "${VPN_PATH:?Set VPN_PATH}"
PORT="${PORT:-10000}"

OUTBOUND='{ "protocol": "freedom" }'

if [ "${ENABLE_TOR:-0}" = "1" ]; then
  mkdir -p /tmp/tor
  tor --RunAsDaemon 1 --DataDirectory /tmp/tor --SocksPort 127.0.0.1:9050 \
      --Log "notice file /dev/null"
  i=0
  until nc -z 127.0.0.1 9050 2>/dev/null || [ $i -ge 30 ]; do i=$((i+1)); sleep 1; done
  OUTBOUND='{ "protocol": "socks", "settings": { "servers": [ { "address": "127.0.0.1", "port": 9050 } ] } }'
fi

cat > /tmp/config.json <<EOF
{
  "log": { "loglevel": "none" },
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": ${PORT},
    "protocol": "vless",
    "settings": { "clients": [{ "id": "${VPN_UUID}" }], "decryption": "none" },
    "streamSettings": { "network": "ws", "wsSettings": { "path": "/${VPN_PATH}" } }
  }],
  "outbounds": [ ${OUTBOUND} ]
}
EOF

exec xray run -config /tmp/config.json
