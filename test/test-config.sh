#!/usr/bin/env bash

wg_create_if() {
  v ip link add "$1" type wireguard
}

export WG=/usr/bin/wg

# export DISABLE_IPV6=1

export HOP0_PUBKEY=$(cat test/hop_privkey | wg pubkey)
export HOP0_ENDPOINT=127.0.0.1:1000
export HOP_NS=tanlhop

export TERM_ADDR=10.100.0.3/16
export TERM_ADDR6=fdb8:c88e:f182:6d9c::3/112

export TEST_CLIENT0_ADDR=10.100.0.2/16
export TEST_CLIENT0_ADDR6=fdb8:c88e:f182:6d9c::2/112
export TEST_CLIENT1_ADDR=10.100.0.4/16
export TEST_CLIENT1_ADDR6=fdb8:c88e:f182:6d9c::4/112
