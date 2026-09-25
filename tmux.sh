#!/bin/sh
set -eu

if ! TMUX_BIN="$(command -v tmux)"; then
  echo 'tmux not found' >&2
  exit 1
fi
if ! ROFI_BIN="$(command -v rofi)"; then
  echo 'rofi not found' >&2
  exit 1
fi
ROFI_OPTS='-dmenu -i -p "Sessions:" -lines 10'

terminal="kitty"

# List existing sessions (just names)
sessions="$("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null || true)"

# Add a "create new" entry at the top
menu="Create new session...\n$sessions"

# Feed the menu into rofi
choice="$(printf '%b' "$menu" | eval "$ROFI_BIN $ROFI_OPTS" || true)"
[ -n "$choice" ] || exit 0

if [ "$choice" = "Create new session..." ]; then
  new_name="$(printf '' | eval "$ROFI_BIN -dmenu -p 'New session name:'" || true)"
  [ -n "$new_name" ] || exit 0
  session="$new_name"
  create=1
else
  session="$choice"
  create=0
fi

# Inside tmux: create (detached) if needed, then switch
if [ -n "${TMUX-}" ]; then
  if [ "$create" -eq 1 ] && ! "$TMUX_BIN" has-session -t "$session" 2>/dev/null; then
    "$TMUX_BIN" new-session -ds "$session"
  fi
  exec "$TMUX_BIN" switch-client -t "$session"
fi

# Outside tmux: one-terminal behavior
pkill -x "$terminal" 2>/dev/null || true
sleep 0.1

if [ "$create" -eq 1 ]; then
  exec "$terminal" -e "$TMUX_BIN" new-session -s "$session"
else
  exec "$terminal" -e "$TMUX_BIN" attach -t "$session"
fi
