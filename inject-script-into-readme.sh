#!/bin/bash

README="README.md"
SCRIPT="pihole-unbound-monitor.sh"

if [[ ! -f "$SCRIPT" ]]; then
    echo "❌ Script file '$SCRIPT' not found!"
    exit 1
fi

# Indent script content for proper Markdown formatting
SCRIPT_CONTENT=$(sed 's/^/    /' "$SCRIPT")

# Replace content between markers
awk -v content="$SCRIPT_CONTENT" '
BEGIN { in_block=0 }
/<!-- START:monitor-script -->/ {
    print; print content; in_block=1; next
}
/<!-- END:monitor-script -->/ {
    in_block=0
}
!in_block
' "$README" > "$README.tmp" && mv "$README.tmp" "$README"

echo "✅ Injected '$SCRIPT' into '$README'."
# Check if the script was successfully injected
if grep -q "<!-- START:monitor-script -->" "$README"; then
    echo "✅ Successfully injected script content."
else
    echo "❌ Failed to inject script content."
    exit 1
fi

