#!/bin/sh

iface="wlp3s0"


daily=$(vnstat -i "$iface" --oneline | cut -d ';' -f 6)
monthly=$(vnstat -i "$iface" --oneline | cut -d ';' -f 11)

echo '{"text": "'"$daily"'", "tooltip": "Daily: '"$daily"' Monthly: '"$monthly"'"}'
