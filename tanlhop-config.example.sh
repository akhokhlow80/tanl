#!/usr/bin/env bash

# To be sourced by tanlhop.sh

wg_create_if() {
  v ip link add "$1" type wireguard
}

export WG=/usr/bin/wg

export HOP_NS=${HOP_NS:-tanlhop} # Set by systemd unit file

# export DISABLE_IPV6=1

export HOP0_PRIVKEY_PATH=/etc/tanl/hop/$HOP_NS/private_key
export HOP0_LISTEN_PORT=1000
export HOP0_ADDR=10.100.0.1/16
export HOP0_ADDR6=fdb8:c88e:f182:6d9c::1/112

export HOP1_PRIVKEY_PATH=/etc/tanl/hop/$HOP_NS/private_key
export HOP1_LISTEN_PORT=1001
export HOP1_ADDR=10.101.0.1/32
export HOP1_ADDR6=fdb8:c88e:f182:6d9d::1/112

export TERM_PSK_PATH=/etc/tanl/hop/$HOP_NS/term_psk
export TERM_PUBKEY=b9Bep7RyyLM5ya/0WDi/5i5Ep6NCa2u0gcXvM4zN42I=
export TERM_ENDPOINT=127.0.0.1:2001
export TERM_ADDR=10.100.0.3/16
export TERM_ADDR6=fdb8:c88e:f182:6d9c::3/112
# export TERM_OBFUSCATE=true
