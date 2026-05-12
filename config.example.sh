#!/usr/bin/env bash

# To be sourced by hop.sh, term.sh or test.sh

# Run:
# - on term: wg genkey > term_privkey
#            wg genpsk > term_privkey
# - on hop: wg genkey > hop_privkey
#           copy term_psk from term

wg_create_if() {
  v ip link add "$1" type wireguard
}

export WG=/usr/bin/wg

export HOP0_PRIVKEY_PATH=./hop_privkey
export HOP0_LISTEN_PORT=1000
export HOP0_ADDR=10.100.0.1/16
export HOP0_ADDR6=fdb8:c88e:f182:6d9c::1/112

export HOP1_PRIVKEY_PATH=./hop_privkey
export HOP1_LISTEN_PORT=1001
export HOP1_ADDR=10.101.0.1/32
export HOP1_ADDR6=fdb8:c88e:f182:6d9d::1/112
export HOP1_TERM_PUBKEY=279kgzPtJmc3EBmlBS03kxcX52d0v2472sSBgf6NoGw=
export HOP1_TERM_ENDPOINT=127.0.0.1:2001
# export HOP1_TERM_OBFUSCATE=true

export TERM_PRIVKEY_PATH=./term_privkey
export TERM_PORT=2001
export TERM_OUT_IF=wlan0
export TERM_PSK_PATH=./term_psk
export TERM_ADDR=10.100.0.3/16
export TERM_ADDR6=fdb8:c88e:f182:6d9c::3/112
export TERM_HOP1_PUBKEY=S9jMGEBPT0pTzVtEdXLKzuvYa910fAimCw+4FBc7eBM=
export TERM_HOP1_ENDPOINT=127.0.0.1:1001
# export TERM_HOP1_OBFUSCATE=true

export TEST_CLIENT0_ADDR=10.100.0.2/16
export TEST_CLIENT0_ADDR6=fdb8:c88e:f182:6d9c::2/112
export TEST_CLIENT1_ADDR=10.100.0.4/16
export TEST_CLIENT1_ADDR6=fdb8:c88e:f182:6d9c::4/112
