#!/usr/bin/env zsh
set -euo pipefail

# ----- customise here --------------------------------------------------------
SENTINEL="✓ done"          # Change to "· Spelunking… finished" if needed
NOTIFY_SOUND="Funk"        # Any system sound, see System Settings ➜ Sound
# ----------------------------------------------------------------------------

# Ensure terminal-notifier is present
if ! command -v terminal-notifier >/dev/null; then
  echo "➡️  Installing terminal-notifier…"
  brew install terminal-notifier
fi

claude code "$@" 2>&1 | while IFS= read -r line; do
  printf '%s\n' "$line"
  [[ "$line" == *"$SENTINEL"* ]] && \
    terminal-notifier -title "Claude Code" \
                      -message "Generation finished" \
                      -sound "$NOTIFY_SOUND" \
                      -group "claude-code-done"
done