#!/usr/bin/env bash

set -e

if [[ $# -ne 5 ]]; then
  >&2 echo "usage: $0 <hop path> <hop config path> <term path> <term config path> <test config path>"
  exit 1
fi

v() {
	>&2 echo "[#] $@"
	"$@"
}

hop="$1"
hop_config="$2"
term="$3"
term_config="$4"
test_config="$5"

v source "$test_config"

NSCLIENT0=tanlclnt0-test
NSCLIENT1=tanlclnt1-test
WGCLIENT0=tanlclnt0-test
WGCLIENT1=tanclnt1-test
NSHOP="$HOP_NS"
WGHOP0=tanlhop0

n() {
  >&2 echo "[#] $NSHOP: $@"
  ip netns exec "$NSHOP" "$@"
}

c0() {
  >&2 echo "[#] $NSCLIENT0: $@"
  ip netns exec "$NSCLIENT0" "$@"
}

c1() {
  >&2 echo "[#] $NSCLIENT1: $@"
  ip netns exec "$NSCLIENT1" "$@"
}

cleanup() {
  >&2 echo 'TEST CLEANUP'
  v set +e
  v rm -rf "$client0_privkey_path"
  v rm -rf "$client1_privkey_path"
  v ip link del "$WGCLIENT0"
  v ip link del "$WGCLIENT1"
  c0 ip link del "$WGCLIENT0"
  c1 ip link del "$WGCLIENT1"
  v ip netns del "$NSCLIENT0"
  v ip netns del "$NSCLIENT1"
  >&2 echo 'CLEANUP'
  "$hop" down "$hop_config"
  "$term" down "$term_config"
}

v "$hop" up "$hop_config"
v "$term" up "$term_config"

trap cleanup EXIT INT TERM

v umask 077
client0_privkey_path=$(mktemp)
v wg genkey > "$client0_privkey_path"
client1_privkey_path=$(mktemp)
v wg genkey > "$client1_privkey_path"

# client0
ip netns add $NSCLIENT0
wg_create_if $WGCLIENT0
v "$WG" set $WGCLIENT0                \
  private-key "$client0_privkey_path" \
  listen-port 22830
v ip link set $WGCLIENT0 netns $NSCLIENT0
c0 "$WG" set $WGCLIENT0                   \
  peer "$HOP0_PUBKEY"                     \
  endpoint "$HOP0_ENDPOINT"               \
  allowed-ips 0.0.0.0/0,::/0
c0 ip addr add "$TEST_CLIENT0_ADDR" dev $WGCLIENT0
c0 ip addr add "$TEST_CLIENT0_ADDR6" dev $WGCLIENT0
c0 ip link set dev $WGCLIENT0 up
c0 ip link set dev lo up
c0 ip route add default dev $WGCLIENT0

n "$WG" set "$WGHOP0"                                                   \
  peer "$(cat "$client0_privkey_path" | wg pubkey)"                     \
  allowed-ips "${TEST_CLIENT0_ADDR%/*}/32,${TEST_CLIENT0_ADDR6%/*}/128"

# client1
ip netns add $NSCLIENT1
c1 ip link set dev lo up
wg_create_if $WGCLIENT1
v "$WG" set $WGCLIENT1                \
  private-key "$client1_privkey_path" \
  listen-port 22831
v ip link set $WGCLIENT1 netns "$NSCLIENT1"
c1 "$WG" set $WGCLIENT1     \
  peer "$HOP0_PUBKEY"       \
  endpoint "$HOP0_ENDPOINT" \
  allowed-ips 0.0.0.0/0,::/0
c1 ip addr add "$TEST_CLIENT1_ADDR" dev $WGCLIENT1
c1 ip addr add "$TEST_CLIENT1_ADDR6" dev $WGCLIENT1
c1 ip link set dev $WGCLIENT1 up
c1 ip link set dev lo up
c1 ip route add default dev $WGCLIENT1

n "$WG" set "$WGHOP0"                                                   \
  peer "$(cat "$client1_privkey_path" | wg pubkey)"                     \
  allowed-ips "${TEST_CLIENT1_ADDR%/*}/32,${TEST_CLIENT1_ADDR6%/*}/128" \
  endpoint 127.0.0.1:22831

c0 ping -i0 -W1 -c3 "${TEST_CLIENT1_ADDR%/*}"
c1 ping -i0 -W1 -c3 "${TEST_CLIENT0_ADDR%/*}"
c0 ping -i0 -W1 -c3 "${TEST_CLIENT1_ADDR6%/*}"
c1 ping -i0 -W1 -c3 "${TEST_CLIENT0_ADDR6%/*}"
c0 ping -i0 -W1 -c3 "${TERM_ADDR%/*}"
c0 ping -i0 -W1 -c3 "${TERM_ADDR6%/*}"
c0 ping -W1 -c2 1.1.1.1
c1 ping -W1 -c2 1.1.1.1

c0 iperf3 -s -1 -B "${TEST_CLIENT0_ADDR%/*}" &
sleep 1
c1 iperf3 -c "${TEST_CLIENT0_ADDR%/*}"
c1 iperf3 -s -1 -B "${TEST_CLIENT1_ADDR%/*}" &
sleep 1
c0 iperf3 -c "${TEST_CLIENT1_ADDR%/*}"

c0 "$SHELL"
