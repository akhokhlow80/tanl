#!/usr/bin/env bash

# To be sourced by tanlterm.sh

wg_create_if() {
  v ip link add "$1" type wireguard
}

export WG=/usr/bin/wg

export TERM_WGIF=${TERM_WGIF:-tanlterm} # Set by systemd unit file
export TERM_PRIVKEY_PATH=/etc/tanl/term/$TERM_WGIF/private_key
export TERM_PORT=2001
export TERM_OUT_IF=wlan0
export TERM_ADDR=10.100.0.3/16
export TERM_ADDR6=fdb8:c88e:f182:6d9c::3/112
export HOP1_PUBKEY=S9jMGEBPT0pTzVtEdXLKzuvYa910fAimCw+4FBc7eBM=
export HOP1_PSK_PATH=/etc/tanl/term/$TERM_WGIF/hop1_psk
export HOP1_ENDPOINT=127.0.0.1:1001
# export HOP1_OBFUSCATE=true
