# Pi-hole/Unbound Monitor
![GitHub release (latest by SemVer)](https://img.shields.io/github/v/release/russmorefield/pihole-unbound-monitor?sort=semver&color=purple&label=version)
> [!CAUTION]
> This project is currently under development

<p align="center">
  <img src="assets/alt-logo.png" alt="Pi-hole Unbound Monitor Logo" width="800"/>
</p>

This script automates the process of:

- Checking if Pi-hole needs updating and updating it if required
- Verifying if the Unbound DNS service is running and checking logs for recent errors
- Sending notifications via [Gotify](https://gotify.net/) if any issues are detected

## 🚀 Features

- ✅ Silent operation for up-to-date systems
- ⚠️ Notifies via Gotify on:
    - Pi-hole update success
    - Unbound service errors or status down
- 📝 Logs all activity to `/var/log/pihole-unbound-monitor.log`

## 🔧 Setup Instructions

## 📜 Script Source

<!-- START:monitor-script -->
<!-- END:monitor-script -->

1. **Edit the Script**  
     Replace the following variables in `pihole-unbound-monitor.sh`:

     ```bash
     GOTIFY_URL="http://your-gotify-url.example.com"
     GOTIFY_TOKEN="your_gotify_token_here"
     ```

2. **Make Executable**

     ```bash
     chmod +x pihole-unbound-monitor.sh
     ```

3. **Run Manually or via Cron**

     **Manual:**

     ```bash
     sudo ./pihole-unbound-monitor.sh
     ```

    **Cron (e.g., run every 6 hours):**  
         Add to your crontab:

    ```bash
    0 */6 * * * /path/to/pihole-unbound-monitor.sh
    ```

4. **(Optional) Run as a systemd Service**

     Create a unit file at `/etc/systemd/system/pihole-unbound-monitor.service`:

     ```ini
     [Unit]
     Description=Pi-hole Unbound Monitor

     [Service]
     ExecStart=/usr/local/bin/pihole-unbound-monitor.sh
     Restart=on-failure

     [Install]
     WantedBy=multi-user.target
     ```

     Then reload and enable the service:

     ```bash
     sudo systemctl daemon-reexec
     sudo systemctl enable --now pihole-unbound-monitor.service
     ```

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
