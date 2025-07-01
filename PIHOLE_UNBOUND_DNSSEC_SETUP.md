# ✅ DNSSEC with Pi-hole + Unbound: Best Practices

## 🔧 Part 1: Disable DNSSEC in Pi-hole (Web UI)

### Open Pi-hole Admin Panel
Navigate to: `http://<your-pihole-ip>/admin`

### Go to:
**Settings → DNS**

### Uncheck the box labeled:
```
✅ “Use DNSSEC”
```

Scroll down and click **“Save”**

> This disables DNSSEC validation in Pi-hole itself, avoiding unnecessary duplication since **Unbound** already validates queries.

---

## 🔁 Part 2: Enable `proxy-dnssec` for Pi-hole → Unbound communication

This allows Pi-hole to pass the DNSSEC `"AD"` flag from Unbound to your local clients.

### Step-by-Step

#### SSH into your Pi-hole server:
```bash
ssh user@<pihole-ip>
```

#### Create a new Dnsmasq configuration file
You can name it something like `99-dnssec.conf`:
```bash
sudo nano /etc/dnsmasq.d/99-dnssec.conf
```

#### Add the following line:
```ini
proxy-dnssec
```

#### Save and close the file
- Press `Ctrl+O` to write the file
- Press `Enter` to confirm
- Press `Ctrl+X` to exit

#### Restart the Pi-hole DNS service:
```bash
pihole restartdns
```

---

## 🧪 Confirm It’s Working

### Check Unbound is doing DNSSEC
Run from your Pi-hole host:
```bash
dig +dnssec dnssec-failed.org @127.0.0.1
```

You should see:
```bash
;; ->>HEADER<<- ... status: SERVFAIL ...
```

> This means Unbound is rejecting invalid DNSSEC — ✅ it’s working!

---

### Check that the AD (Authenticated Data) bit is passed to clients
From a client on your LAN:
```bash
dig +dnssec google.com
```

Look for:
```bash
;; flags: qr rd ra ad;
```

If you see `ad` in the flags, DNSSEC validation is still effective — just offloaded to Unbound.

---

## ✅ Summary

| Feature                    | Status        |
|---------------------------|---------------|
| Pi-hole DNSSEC            | ❌ Disabled    |
| Unbound DNSSEC            | ✅ Enabled     |
| DNSSEC proxy to clients   | ✅ Enabled     via `proxy-dnssec` |