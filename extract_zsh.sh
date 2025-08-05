#!/bin/bash

set -e

# Get config directory from CLI argument, fallback to ~/zsh-config
CONFIG_DIR="$PWD/zsh-config"

echo "📁 Using backup directory: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# Copy .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
  echo "📄 Copying .zshrc..."
  cp "$HOME/.zshrc" "$CONFIG_DIR/"
else
  echo "⚠️  ~/.zshrc not found, skipping..."
fi

# Copy Powerlevel10k config if it exists
if [ -f "$HOME/.p10k.zsh" ]; then
  echo "🎨 Copying Powerlevel10k config..."
  cp "$HOME/.p10k.zsh" "$CONFIG_DIR/"
else
  echo "⚠️  ~/.p10k.zsh not found, skipping..."
fi

# Copy custom plugins/themes
CUSTOM_SRC="$HOME/.oh-my-zsh/custom"
if [ -d "$CUSTOM_SRC" ] && [ "$(ls -A "$CUSTOM_SRC")" ]; then
  echo "📦 Copying custom plugins/themes..."
  mkdir -p "$CONFIG_DIR/custom"
  cp -r "$CUSTOM_SRC"/* "$CONFIG_DIR/custom/"
else
  echo "⚠️  No custom plugins/themes found in $CUSTOM_SRC, skipping..."
fi

# Copy Nerd Fonts (optional)
FONTS_SRC="$HOME/.local/share/fonts"
FONT_MATCHES=$(find "$FONTS_SRC" -iname '*NerdFont*' 2>/dev/null)
if [ -n "$FONT_MATCHES" ]; then
  echo "🔤 Copying Nerd Fonts..."
  mkdir -p "$CONFIG_DIR/fonts"
  find "$FONTS_SRC" -iname '*NerdFont*' -exec cp {} "$CONFIG_DIR/fonts/" \;
else
  echo "⚠️  No Nerd Fonts found in $FONTS_SRC, skipping..."
fi

echo "✅ Zsh config backup complete at: $CONFIG_DIR"
