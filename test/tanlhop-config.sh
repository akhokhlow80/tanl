#!/usr/bin/env bash

wg_create_if() {
  v ip link add "$1" type wireguard
}

export WG=/usr/bin/wg

export HOP_NS=tanlhop

export HOP0_PRIVKEY_PATH=test/hop_privkey
export HOP0_LISTEN_PORT=1000
export HOP0_ADDR=10.100.0.1/16
export HOP0_ADDR6=fdb8:c88e:f182:6d9c::1/112

export HOP1_PRIVKEY_PATH=test/hop_privkey
export HOP1_LISTEN_PORT=1001
export HOP1_ADDR=10.101.0.1/32
export HOP1_ADDR6=fdb8:c88e:f182:6d9d::1/112

export TERM_PSK_PATH=test/hop-term_psk
export TERM_PUBKEY=$(cat test/term_privkey | wg pubkey)
export TERM_ENDPOINT=127.0.0.1:2001
export TERM_ADDR=10.100.0.3/16
export TERM_ADDR6=fdb8:c88e:f182:6d9c::3/112
# export TERM_OBFUSCATE=true
