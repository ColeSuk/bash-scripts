#!/bin/bash
LOCKFILE="/tmp/monitor_dock_detect.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

PROFILE_LINK="$HOME/.config/hypr/monitors_active.lua"
PROFILE_DOCKED="$(readlink -f "$HOME/.config/hypr/monitors_docked.lua")"
PROFILE_UNDOCKED="$(readlink -f "$HOME/.config/hypr/monitors_undocked.lua")"

if [ -z "$PROFILE_DOCKED" ] || [ -z "$PROFILE_UNDOCKED" ]; then
  echo "monitor_dock_detect.sh: couldn't resolve profile paths. aborting" >&2
  exit 1
fi

CURRENT="$(readlink -f "$PROFILE_LINK" 2>/dev/null)"

if [ "$CURRENT" = "$PROFILE_UNDOCKED" ]; then
  TARGET="$PROFILE_DOCKED"
else
  TARGET="$PROFILE_UNDOCKED"
fi

ln -sfn "$TARGET" "$PROFILE_LINK"
hyprctl reload
