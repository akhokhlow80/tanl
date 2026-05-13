#!/usr/bin/env bash

set -e

v() {
	>&2 echo "[#] $@"
	"$@"
}

down() {
  set +e
  v iptables -t nat -D POSTROUTING -o "$TERM_OUT_IF" -j MASQUERADE
  v ip6tables -t nat -D POSTROUTING -o "$TERM_OUT_IF" -j MASQUERADE
  v ip link del $WGTERM
  v sysctl -w net.ipv4.ip_forward=0
  v sysctl -w net.ipv6.conf.all.forwarding=0
  return 0
}

up() (
  up_() {
    (
      set -e
      v sysctl -w net.ipv4.ip_forward=1
      v sysctl -w net.ipv6.conf.all.forwarding=1
      wg_create_if $WGTERM
      v "$WG" set $WGTERM                \
        private-key "$TERM_PRIVKEY_PATH" \
      	listen-port "$TERM_PORT"
      v "$WG" set $WGTERM                   \
        peer "$HOP1_PUBKEY"                 \
        preshared-key "$HOP1_PSK_PATH"      \
        endpoint "$HOP1_ENDPOINT"           \
        allowed-ips 0.0.0.0/0,::/0
      if [[ $HOP1_OBFUSCATE ]]; then
        v "$WG" set $WGTERM   \
          peer "$HOP1_PUBKEY" \
          obfuscate true
      fi
      v ip addr add "$TERM_ADDR" dev $WGTERM
      v ip addr add "$TERM_ADDR6" dev $WGTERM
      v ip link set dev $WGTERM up
      v ip link set dev lo up
      v iptables -t nat -I POSTROUTING -o "$TERM_OUT_IF" -j MASQUERADE
      v ip6tables -t nat -I POSTROUTING -o "$TERM_OUT_IF" -j MASQUERADE
      v "$WG" $WGTERM
      v ip a $WGTERM
    )
  }
  set +e
  up_
  if [[ $? -ne 0 ]]; then
    >&2 echo 'FAIL'
    >&2 echo 'CLEANUP'
    down
    return 1
  fi
  set -e
)

if [[ $# -ne 2 ]]; then
  >&2 echo "usage: $0 { up | down } <path to config bash script>"
  exit 1
fi

v source "$2"

WGTERM=$TERM_WGIF

case "$1" in
  "up")
    up
    ;;
  "down")
    down
    ;;
  *)
    >&2 echo "unknown command $1"
    exit 1
    ;;
esac
