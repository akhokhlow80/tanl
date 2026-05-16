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
  v ip link del "$HOST_VETH"
  n ip link del $NS_VETH
  return 0
}

up() (
  up_() {
    (
      set -e
      v ip link add "$HOST_VETH" type veth peer $NS_VETH netns "$NS"
      v ip addr add "$HOST_VPN_ADDR" dev "$HOST_VETH"
      v ip addr add "$HOST_VETH_ADDR" dev "$HOST_VETH"
      if [[ -z "$DISABLE_IPV6" ]]; then
        v ip addr add "$HOST_VPN_ADDR6" dev "$HOST_VETH"
        v ip addr add "$HOST_VETH_ADDR6" dev "$HOST_VETH"
      fi
      n ip addr add "$NS_VETH_ADDR" dev $NS_VETH
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip addr add "$NS_VETH_ADDR6" dev $NS_VETH
      fi
      n ip link set dev $NS_VETH up
      v ip link set dev "$HOST_VETH" up

      n ip route add "${HOST_VPN_ADDR%/*}" dev $NS_VETH
      n ip route add "${HOST_ADDR%/*}" dev $NS_VETH
      v ip route add "$VPN" via "${NS_VETH_ADDR%/*}" dev "$HOST_VETH"
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip route add "${HOST_VPN_ADDR6%/*}" dev $NS_VETH
        n ip route add "${HOST_ADDR6%/*}" dev $NS_VETH
        v ip route add "$VPN6" via "${NS_VETH_ADDR6%/*}" dev "$HOST_VETH"
      fi
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

if [[ $# -ne 14 ]]; then
  >&2 echo "usage: $0 { up | down } <hop ns> <vpn> <vpn6> <disable ipv6> <host veth> <host addr> <host addr6> <host vpn addr> <host vpn addr6> <host veth addr> <host veth addr6> <ns veth addr> <ns veth addr6>"
  exit 1
fi

NS="$2"
VPN="$3"
VPN6="$4"
DISABLE_IPV6="$5"
HOST_VETH="$6"
NS_VETH=veth0
HOST_ADDR="$7"
HOST_ADDR6="$8"
HOST_VPN_ADDR="$9"
HOST_VPN_ADDR6="${10}"
HOST_VETH_ADDR="${11}"
HOST_VETH_ADDR6="${12}"
NS_VETH_ADDR="${13}"
NS_VETH_ADDR6="${14}"

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
