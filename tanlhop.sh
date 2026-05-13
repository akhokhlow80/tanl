#!/usr/bin/env bash

set -e

v() {
	>&2 echo "[#] $@"
	"$@"
}

n() {
  >&2 echo "[#] $NS: $@"
  ip netns exec "$NS" "$@"
}

down() {
  set +e
  v ip link del $WG0
  v ip link del $WG1
  n ip link del $WG0
  n ip link del $WG1
  v ip netns del "$NS"
  return 0
}

up() (
  up_() {
    (
      set -e
      v ip netns add "$NS" 
      n ip link set dev lo up
      n sysctl -w net.ipv4.ip_forward=1
      if [[ -z "$DISABLE_IPV6" ]]; then
        n sysctl -w net.ipv6.conf.all.forwarding=1
      fi

      # wg1
      wg_create_if $WG1
      v "$WG" set $WG1                   \
        private-key "$HOP1_PRIVKEY_PATH" \
      	listen-port "$HOP1_LISTEN_PORT"
      v ip link set $WG1 netns "$NS"
      n ip addr add "$HOP1_ADDR" dev $WG1
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip addr add "$HOP1_ADDR6" dev $WG1
      fi
      n ip link set dev $WG1 up
      n "$WG" set $WG1                 \
        peer "$TERM_PUBKEY"            \
        endpoint "$TERM_ENDPOINT"      \
        preshared-key "$TERM_PSK_PATH" \
        allowed-ips 0.0.0.0/0,::/0
      if [[ $TERM_OBFUSCATE ]]; then
        n "$WG" set $WG1      \
          peer "$TERM_PUBKEY" \
          obfuscate true
      fi

      # wg0
      wg_create_if $WG0
      v "$WG" set $WG0                   \
        private-key "$HOP0_PRIVKEY_PATH" \
      	listen-port "$HOP0_LISTEN_PORT"
      v ip link set $WG0 netns "$NS"
      n ip addr add "$HOP0_ADDR" dev $WG0
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip addr add "$HOP0_ADDR6" dev $WG0
      fi
      n ip link set dev $WG0 up

      n ip route add "${TERM_ADDR%/*}/32" dev $WG1
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip route add "${TERM_ADDR6%/*}/128" dev $WG1
      fi
      n ip route add default dev $WG1

      # policy based routing
      # ROUTING_TABLE=10016
      # n ip rule add iif $WG0 table $ROUTING_TABLE
      # n ip route add "${TERM_ADDR%/*}/32" dev $WG1 table $ROUTING_TABLE
      # n ip route add "${TERM_ADDR6%/*}/128" dev $WG1 table $ROUTING_TABLE
      # n ip route add 10.100.0.0/16 dev $WG0 table $ROUTING_TABLE
      # n ip route add 0.0.0.0/0 dev $WG1 table $ROUTING_TABLE

      n ip a
      n "$WG"
    )
  }

  set +e
  up_
  if [[ $? -ne 0 ]]; then
    >&2 echo 'FAIL'
    >&2 echo 'CLEANUP'
    up_failed
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

NS=$HOP_NS
WG0=tanlhop0
WG1=tanlhop1

case "$1" in
  "up")
    pre_up
    up
    post_up
    ;;
  "down")
    pre_down
    down
    post_down
    ;;
  *)
    >&2 echo "unknown command $1"
    exit 1
    ;;
esac
