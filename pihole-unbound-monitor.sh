#!/bin/bash

# ==============================
# Pi-hole + Unbound Monitor Script
# ==============================
# - Updates Pi-hole if needed
# - Checks Unbound status
# - Sends Gotify notification on update or error
# - Logs to /var/log/pihole-unbound-monitor.log
# ==============================

# === CONFIGURATION ===
GOTIFY_URL="http://your-gotify-url.example.com"
GOTIFY_TOKEN="your_gotify_token_here"
LOG_FILE="/var/log/pihole-unbound-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# === LOGGING FUNCTION ===
log_msg() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

# === SEND GOTIFY NOTIFICATION ===
send_gotify_notification() {
    local title=$1
    local message=$2
    local priority=$3

    curl -s -X POST "${GOTIFY_URL}/message" \
        -H "X-Gotify-Key: ${GOTIFY_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"${title}\",\"message\":\"${message}\",\"priority\":${priority}}" > /dev/null
}

# === UPDATE PI-HOLE IF NEEDED ===
check_pihole_update() {
    if ! command -v pihole >/dev/null; then
        log_msg "Pi-hole command not found."
        return
    fi

    log_msg "Checking Pi-hole for updates..."
    if ! pihole -up | tee -a "$LOG_FILE" | grep -q "Everything is up to date"; then
        log_msg "Pi-hole updated successfully."
        send_gotify_notification "Pi-hole Updated" "Pi-hole was updated automatically on $DATE" 5
    else
        log_msg "Pi-hole is already up to date."
    fi
}

# === CHECK UNBOUND STATUS ===
check_unbound_status() {
    if ! systemctl is-active --quiet unbound; then
        log_msg "Unbound is NOT running!"
        send_gotify_notification "Unbound Error" "Unbound service is down on $DATE" 8
        return
    fi

    # Check for recent error messages
    if journalctl -u unbound --since "5 minutes ago" | grep -iE "error|fail"; then
        log_msg "Recent errors found in Unbound logs."
        send_gotify_notification "Unbound Warning" "Unbound reported errors in the last 5 minutes." 7
    else
        log_msg "Unbound is healthy."
    fi
}

# === MAIN ===
log_msg "Running Pi-hole/Unbound Monitor Script..."
check_pihole_update
check_unbound_status
log_msg "Monitor script completed."
# === END OF SCRIPT ===
# Ensure the script is executable
