#!/usr/bin/env bash

wg_create_if() {
  v ip link add "$1" type wireguard
}

export WG=/usr/bin/wg

# export DISABLE_IPV6=1

export TERM_WGIF=tanlterm
export TERM_PRIVKEY_PATH=test/term_privkey
export TERM_PORT=2001
export TERM_OUT_IF=wlan0
export TERM_ADDR=10.100.0.2/16
export TERM_ADDR6=fdb8:c88e:f182:6d9c::2/112
export HOP1_PUBKEY=$(cat test/hop_privkey | wg pubkey)
export HOP1_PSK_PATH=test/hop-term_psk
export HOP1_ENDPOINT=127.0.0.1:1001
# export HOP1_OBFUSCATE=true
