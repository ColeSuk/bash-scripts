#!/bin/bash
LOCKFILE="/tmp/monitor_dock_detect.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

HDMI_CONNECTOR="HDMI-A-3"
DOCK_CONNECTOR="DP-4"

hdmi_status() { cat /sys/class/drm/card*-"$HDMI_CONNECTOR"/status 2>/dev/null | head -1; }
dock_status() { cat /sys/class/drm/card*-"$DOCK_CONNECTOR"/status 2>/dev/null | head -1; }

read1_hdmi=$(hdmi_status)
read1_dock=$(dock_status)
sleep 0.5
read2_hdmi=$(hdmi_status)
read2_dock=$(dock_status)

if [ "$read1_hdmi" != "$read2_hdmi" ] || [ "$read1_dock" != "$read2_dock" ]; then
  exit 0 # still settling, wait for next poll
fi

PROFILE_LINK="$HOME/.config/hypr/monitors_active.lua"
PROFILE_DOCKED="$(readlink -f "$HOME/.config/hypr/monitors_docked.lua")"
PROFILE_UNDOCKED="$(readlink -f "$HOME/.config/hypr/monitors_undocked.lua")"

[ -z "$PROFILE_DOCKED" ] || [ -z "$PROFILE_UNDOCKED" ] && exit 1

if [ "$read2_hdmi" = "connected" ] && [ "$read2_dock" = "connected" ]; then
  TARGET="$PROFILE_DOCKED"
else
  TARGET="$PROFILE_UNDOCKED"
fi

CURRENT="$(readlink -f "$PROFILE_LINK" 2>/dev/null)"

if [ "$CURRENT" != "$TARGET" ]; then
  ln -sfn "$TARGET" "$PROFILE_LINK"
  hyprctl reload
fi
