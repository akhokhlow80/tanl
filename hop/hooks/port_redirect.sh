#!/usr/bin/env bash

set -e

v() {
	>&2 echo "[#] $@"
	"$@"
}
down() {
  set +e
  IFS=',' read -ra ports_parsed <<< "$FROM_PORTS"
  for port in "${ports_parsed[@]}"; do
    port=$(printf "%s" "$port" | awk '{$1=$1};1')
    v iptables -t nat -D PREROUTING -p "$PROTO" -d "$ADDR" --dport "$port" -j DNAT --to "$ADDR":"$TO_PORT"
    if [[ -z "$DISABLE_IPV6" ]]; then
      v iptables -t nat -D PREROUTING -p "$PROTO" -d "$ADDR6" --dport "$port" -j DNAT --to "$ADDR6":"$TO_PORT"
    fi
  done
  return 0
}

up() (
  up_() {
    (
      set -e
      IFS=',' read -ra ports_parsed <<< "$FROM_PORTS"
      for port in "${ports_parsed[@]}"; do
        port=$(printf "%s" "$port" | awk '{$1=$1};1')
        v iptables -t nat -A PREROUTING -p "$PROTO" -d "$ADDR" --dport "$port" -j DNAT --to "$ADDR":"$TO_PORT"
        if [[ -z "$DISABLE_IPV6" ]]; then
          v iptables -t nat -A PREROUTING -p "$PROTO" -d "$ADDR6" --dport "$port" -j DNAT --to "$ADDR6":"$TO_PORT"
        fi
      done
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

if [[ $# -ne 7 ]]; then
  >&2 echo "usage: $0 { up | down } <disable ipv6> <addr> <addr6> <from ports> <to port> <proto>"
  exit 1
fi

DISABLE_IPV6="$2"
ADDR="$3"
ADDR6="$4"
FROM_PORTS="$5"
TO_PORT="$6"
PROTO="$7"

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
