#!/usr/bin/env bash

set -e

echo "📦 Installing dependencies..."
sudo apt update
sudo apt install -y \
  cmake \
  pkg-config \
  libfreetype6-dev \
  libfontconfig1-dev \
  libxcb-xfixes0-dev \
  libxkbcommon-dev \
  python3 \
  curl \
  git \
  unzip

echo "🚀 Installing Rust (via rustup)..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "🛠 Building Alacritty from source..."
cargo install alacritty

echo "📂 Linking Alacritty to /usr/local/bin..."
sudo ln -sf "$HOME/.cargo/bin/alacritty" /usr/local/bin/alacritty

echo "🖼️ Creating desktop entry..."
sudo tee /usr/share/applications/Alacritty.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Alacritty
Exec=alacritty
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF

echo "🎉 Alacritty installation complete!"

echo "🖼️ Apply Configs..."
mkdir -p ~/.config/alacritty
cp alacritty.toml ~/.config/alacritty/alacritty.toml

echo "🔁 You may need to log out and back in to see the launcher in your menu."
