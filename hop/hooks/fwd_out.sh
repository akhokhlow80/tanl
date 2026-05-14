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
  v ip link del "$OUT_VETH"
  n ip link del $IN_VETH
  n ip route del "${HOP0_ADDR%/*}/32" dev $IN_VETH
  if [[ -z "$DISABLE_IPV6" ]]; then
    n ip route del "${HOP0_ADDR6%/*}/128" dev $IN_VETH
  fi
  return 0
}

up() (
  up_() {
    (
      v ip link add "$OUT_VETH" type veth peer $IN_VETH netns "$NS"
      v ip addr add "$OUT_VETH_ADDR" dev "$OUT_VETH"
      if [[ -z "$DISABLE_IPV6" ]]; then
        v ip addr add "$OUT_VETH_ADDR6" dev "$OUT_VETH"
      fi
      n ip addr add "$IN_VETH_ADDR" dev $IN_VETH
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip addr add "$IN_VETH_ADDR6" dev $IN_VETH
      fi
      n ip link set dev $IN_VETH up
      v ip link set dev "$OUT_VETH" up

      n ip route add "${HOP0_ADDR%/*}/32" dev $IN_VETH
      if [[ -z "$DISABLE_IPV6" ]]; then
        n ip route add "${HOP0_ADDR6%/*}/128" dev $IN_VETH
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

if [[ $# -ne 9 ]]; then
  >&2 echo "usage: $0 { up | down } <disable ipv6> <out veth> <out veth addr> <out veth addr6> <in veth addr> <in veth addr6> <hop0 addr> <hop0 addr6>"
  exit 1
fi

DISABLE_IPV6="$2"
OUT_VETH="$3"
IN_VETH=veth0
OUT_VETH_ADDR="$4"
OUT_VETH_ADDR6="$5"
IN_VETH_ADDR="$6"
IN_VETH_ADDR6="$7"
HOP0_ADDR="$8"
HOP0_ADDR6="$9"
