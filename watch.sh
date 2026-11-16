#!/usr/bin/env bash
# watch.sh - log any change to sensitive files
LOG="/home/admin_mjumbe/ironclad/changes.log"
FILES="/etc/passwd /etc/shadow /etc/sudoers /etc/ssh/sshd_config /etc/ssh/sshd_config.d"

inotifywait -m -r -e modify,create,delete,attrib $FILES 2>/dev/null |
while read -r path event file; do
  printf '%s  %s  %s%s\n' "$(date '+%F %T')" "$event" "$path" "$file" >> "$LOG"
done
