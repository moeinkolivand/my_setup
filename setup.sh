#!/bin/bash

set -e

# --- 1. Handle input arguments or use defaults ---
GNOME_DIR="$PWD/gnome-terminal-backup"
ZSH_DIR="$PWD/zsh-config"

echo "📁 Using GNOME Terminal config from: $GNOME_DIR"
echo "📁 Using Zsh config from: $ZSH_DIR"

# --- 2. Install Dependencies ---
echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y zsh git curl fonts-powerline dconf-cli

# --- 3. Restore Zsh Config ---
echo "🐚 Restoring Zsh configuration..."

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "⚙️ Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Copy .zshrc and .p10k.zsh
cp "$ZSH_DIR/.zshrc" "$HOME/" 2>/dev/null || echo "⚠️ .zshrc not found in $ZSH_DIR"
cp "$ZSH_DIR/.p10k.zsh" "$HOME/" 2>/dev/null || echo "⚠️ .p10k.zsh not found in $ZSH_DIR"

# Copy custom themes/plugins if available
if [ -d "$ZSH_DIR/custom" ]; then
  echo "🔌 Copying custom themes and plugins..."
  mkdir -p "$HOME/.oh-my-zsh/custom"
  cp -r "$ZSH_DIR/custom/"* "$HOME/.oh-my-zsh/custom/" || echo "⚠️ Nothing to copy from $ZSH_DIR/custom"
fi

# Set Zsh as default shell
chsh -s "$(which zsh)"

# --- 4. Install Fonts ---
echo "🔤 Installing Nerd Fonts from both config directories..."

FONT_DEST="$HOME/.local/share/fonts"
mkdir -p "$FONT_DEST"

copy_fonts() {
  local source_dir="$1/fonts"
  if [ -d "$source_dir" ]; then
    find "$source_dir" \( -iname '*.ttf' -o -iname '*.otf' \) -exec cp -n {} "$FONT_DEST/" \;
  else
    echo "⚠️ No fonts directory in $source_dir"
  fi
}

copy_fonts "$ZSH_DIR"
copy_fonts "$GNOME_DIR"

# Refresh font cache
fc-cache -fv

# --- 5. Restore GNOME Terminal Settings ---
echo "🖥️ Restoring GNOME Terminal profile..."
CONF_FILE="$GNOME_DIR/terminal-settings.dconf"

if [ -f "$CONF_FILE" ]; then
  dconf load /org/gnome/terminal/legacy/ < "$CONF_FILE"
else
  echo "⚠️ terminal-settings.dconf not found in $GNOME_DIR"
fi

echo "🔁 Installing Rust And Cargo"
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh   
echo "✅ Installing Rust And Cargo Completed!"

echo "🔁 Installing Tldr"
cargo install tlrc --locked
echo "✅ Installing Tldr Complete!"

# --- Done ---
echo ""
echo "✅ Setup complete!"
echo "🔁 Please restart your terminal or log out/in for all changes to take effect."
