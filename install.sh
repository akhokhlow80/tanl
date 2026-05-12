#!/usr/bin/env bash

set -e

v() {
  >&2 echo '[#]' $@
  $@
}

v mkdir -p /etc/tanl
v chmod 600 /etc/tanl

v install tanlhop.sh /usr/bin/tanlhop
v install tanlhop@.service /etc/systemd/system
v install tanlterm.sh /usr/bin/tanlterm
v install tanlterm@.service /etc/systemd/system
