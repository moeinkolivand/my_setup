#!/bin/bash

set -e

BACKUP_DIR="${1:-$HOME/gnome-terminal-backup}"
mkdir -p "$BACKUP_DIR"

echo "🖥️ Backing up GNOME Terminal settings to $BACKUP_DIR"

# 1. Dump GNOME Terminal settings
echo "📦 Dumping dconf terminal settings..."
dconf dump /org/gnome/terminal/legacy/ > "$BACKUP_DIR/terminal-settings.dconf"

# 2. Optionally copy Nerd Fonts if used
FONT_DIR="$HOME/.local/share/fonts"
FONT_BACKUP_DIR="$BACKUP_DIR/fonts"
if find "$FONT_DIR" -iname '*NerdFont*' | grep -q .; then
  echo "🔤 Copying Nerd Fonts..."
  mkdir -p "$FONT_BACKUP_DIR"
  find "$FONT_DIR" -iname '*NerdFont*' -exec cp {} "$FONT_BACKUP_DIR/" \;
else
  echo "⚠️  No Nerd Fonts found in $FONT_DIR"
fi

echo "✅ GNOME Terminal settings backup complete."

