#!/usr/bin/env bash
set -euo pipefail
umask 077
WORK="$(mktemp -d /tmp/vpn.XXXXXX)"
trap 'shred -u "$WORK"/* 2>/dev/null || true; rm -rf "$WORK"; clear' EXIT

UUID="$(cat /proc/sys/kernel/random/uuid)"
WSPATH="$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')"

echo "=== Add these in Render > Environment (via Tor Browser) ==="
echo "VPN_UUID=$UUID"
echo "VPN_PATH=$WSPATH"
echo "ENABLE_TOR=1"
echo
read -rp "Render host once deployed (e.g. my-private-proxy.onrender.com): " HOST
HOST="${HOST#https://}"; HOST="${HOST%/}"

LINK="vless://${UUID}@${HOST}:443?encryption=none&security=tls&sni=${HOST}&type=ws&host=${HOST}&path=%2F${WSPATH}#Tor-Chain"
echo
echo "=== Client link ==="
echo "$LINK"
echo
if command -v qrencode >/dev/null; then
  qrencode -t ANSIUTF8 "$LINK"
else
  echo "(No QR tool. Type the link into the device, or run: sudo apt install qrencode)"
fi
echo
read -rp "Import it on your devices now, then press Enter to wipe everything..."
