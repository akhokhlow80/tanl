#!/usr/bin/env bash

set -e

v() {
  >&2 echo '[#]' $@
  $@
}

v mkdir -p /etc/tanl
v chmod 600 /etc/tanl

v install hop/tanlhop.sh /usr/bin/tanlhop
v install hop/tanlhop@.service /etc/systemd/system
v install term/tanlterm.sh /usr/bin/tanlterm
v install term/tanlterm@.service /etc/systemd/system
