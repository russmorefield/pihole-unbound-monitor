# Unbound DNSSEC Repair and Configuration Script

This script helps fix Unbound's trust anchor issues and configures it for DNSSEC validation with best practices, including root hints and systemd override.

## What it Does

- Stops Unbound
- Deletes old trust anchor file (`root.key`)
- Adds a fresh trust anchor (DNSKEY for the root zone)
- Ensures proper permissions
- Replaces the `pi-hole.conf` Unbound configuration file
- Downloads the latest `root.hints`
- Sets a systemd override to use correct Unbound execution flags
- Restarts and validates Unbound

## Requirements

- Ubuntu/Debian-based system
- Installed `unbound` service
- Root/sudo privileges

## Usage

```bash
sudo bash fix-unbound.sh
```

## Contents

### fix-unbound.sh

```bash
#!/bin/bash

set -e

echo "🔧 Stopping Unbound..."
systemctl stop unbound

echo "🧹 Removing existing trust anchor..."
rm -f /var/lib/unbound/root.key

echo "📝 Writing fresh root DNSKEY..."
cat <<EOF > /var/lib/unbound/root.key
.  86400  IN  DNSKEY  257 3 8 AwEAAaz/tAm8yTn4Mfeh5eyI96WSVexTBAvkMgJzkKTOiW1vkIbzxeF3+/4RgWOq7HrxRixHlFlExOLAJr5emLvN7SWXgnLh4+B5xQlNVz8Og8kvArMtNROxVQuCaSnIDdD5LKyWbRd2n9WGe2R8PzgCmr3EgVLrjyBxWezF0jLHwVN8efS3rCj/EWgvIWgb9tarpVUDK/b58Da+sqqls3eNbuv7pr+eoZG+SrDK6nWeL3c6H5Apxz7LjVc1uTIdsIXxuOLYA4/ilBmSVIzuDWfdRUfhHdY6+cn8HFRm+2hM8AnXGXws9555KrUB5qihylGa8subX2Nn6UwNR1AkUTV74bU=
EOF

echo "🔐 Fixing permissions on root.key..."
chown unbound:unbound /var/lib/unbound/root.key

echo "🧽 Removing old pi-hole.conf..."
rm -f /etc/unbound/unbound.conf.d/pi-hole.conf

echo "📦 Writing updated pi-hole.conf..."
cat <<EOF > /etc/unbound/unbound.conf.d/pi-hole.conf
server:
    verbosity: 0
    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    root-hints: "/var/lib/unbound/root.hints"
    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: yes
    edns-buffer-size: 1232
    prefetch: yes
    prefetch-key: yes
    cache-min-ttl: 3600
    cache-max-ttl: 86400
    num-threads: 2
    so-rcvbuf: 1m
    so-sndbuf: 1m
    rrset-roundrobin: yes
    minimal-responses: yes
    access-control: 127.0.0.0/8 allow
    private-address: 192.168.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    auto-trust-anchor-file: "/var/lib/unbound/root.key"

forward-zone:
    name: "."
    forward-addr: 1.1.1.1
    forward-addr: 1.0.0.1
EOF

echo "💾 Downloading latest root.hints file..."
wget -qO /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache

echo "🛠 Creating systemd override..."
mkdir -p /etc/systemd/system/unbound.service.d
cat <<EOF > /etc/systemd/system/unbound.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/sbin/unbound -d
EOF

echo "🔄 Reloading systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "✅ Checking Unbound config..."
unbound-checkconf

echo "🚀 Starting Unbound..."
systemctl start unbound

echo "📡 Status:"
systemctl status unbound --no-pager
```
