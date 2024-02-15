#!/usr/bin/env bash
#
file_path="/nix/var/nix/profiles/system"
time_since_change=$(($(date +%s) - $(stat -c %Y "$file_path")))

color=00AA00
if ((time_since_change < 60)); then
formatted_time="$time_since_change seconds"
elif ((time_since_change < 3600)); then
formatted_time="$((time_since_change / 60)) minutes"
elif ((time_since_change < 86400)); then
formatted_time="$((time_since_change / 3600)) hours"
else
formatted_time="$((time_since_change / 86400)) days"
if ((time_since_change >= 259200)); then
    color=ff0000
fi
fi

echo "$formatted_time"
