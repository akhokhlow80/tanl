## Term

```bash
./install.sh

WGIF=tanlterm # choose the name of the wg interface
umask 077

mkdir -p /etc/tanl/term/$WGIF
cp tanlterm-config.example.sh /etc/tanl/term/$WGIF/config.sh
# beware that config is an executable script!
# don't forget to update tanlhop's public key
$EDITOR /etc/tanl/term/$WGIF/config.sh

wg genkey > /etc/tanl/term/$WGIF/private_key
wg genpsk > /etc/tanl/term/$WGIF/hop1_psk

systemctl enable --now tanlterm@$WGIF.service

# To get term public key:
cat /etc/tanl/term/$WGIF/private_key | wg pubkey
```

## Hop

```bash
./install.sh

NS=tanlhop # choose the name of the namespace (to be created in /var/run/netns)
umask 077

mkdir -p /etc/tanl/hop/$NS
cp tanlhop-config.example.sh /etc/tanl/hop/$NS/config.sh

# beware that config is an executable script!
# don't forget to update tanlterm's public key
$EDITOR /etc/tanl/hop/$NS/config.sh

wg genkey > /etc/tanl/hop/$NS/private_key
# copy term psk to /etc/tanl/hop/$NS/term_psk
systemctl enable --now tanlhop@$NS.service

# To get hop public key:
cat /etc/tanl/hop/$NS/private_key | wg pubkey
```

## Test

```bash
./test/test.sh ./tanlhop.sh test/tanlhop-config.sh ./tanlterm.sh test/tanlterm-config.sh test/test-config.sh
```
