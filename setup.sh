#!/bin/bash

set -e

# Function to ask user for confirmation
ask_user() {
    local prompt="$1"
    local response
    
    while true; do
        echo -n "$prompt (y/n): "
        read -r response
        case $response in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer yes (y) or no (n)." ;;
        esac
    done
}

echo "🚀 Welcome to Interactive System Setup!"
echo "This script will help you install and configure various tools."
echo ""

# --- Rust Installation Section ---
if ask_user "🦀 Do you want to install Rust and Cargo?"; then
    echo "🔁 Installing Rust And Cargo"
    curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "✅ Installing Rust And Cargo Completed!"
    
    # Rust Tools Section
    RUST_INSTALLED=true
    echo ""
    echo "📦 Rust Tools Available:"
    
    if ask_user "📂 Do you want to install eza (modern ls replacement)?"; then
        echo "🔁 Installing eza"
        cargo install eza
        echo "✅ Installing eza Completed!"
    fi
    
    if ask_user "📖 Do you want to install tlrc (tldr client)?"; then
        echo "🔁 Installing Tldr"
        cargo install tlrc --locked
        echo "✅ Installing Tldr Complete!"
    fi
    
    if ask_user "💾 Do you want to install du-dust (modern du)?"; then
        echo "🔁 Installing du-dust"
        cargo install du-dust
        echo "✅ Installing du-dust Complete!"
    fi
    
    if ask_user "🔍 Do you want to install procs (modern ps)?"; then
        echo "🔁 Installing procs"
        cargo install procs
        echo "✅ Installing procs Complete!"
    fi
    
    if ask_user "🧭 Do you want to install navi (interactive cheatsheet)?"; then
        echo "🔁 Installing navi"
        cargo install --locked navi
        echo "✅ Installing navi Complete!"
    fi
else
    RUST_INSTALLED=false
    echo "⏭️ Skipping Rust installation"
fi

echo ""

# --- Fastfetch Installation Section ---
if ask_user "⚡ Do you want to install and configure Fastfetch?"; then
    echo "🔁 Installing Fastfetch"
    sudo apt update
    sudo apt install -y fastfetch
    echo "✅ Installing Fastfetch Complete!"

    # Configure Fastfetch
    FASTFETCH_SRC="$PWD/fastfetch"
    FASTFETCH_DEST="$HOME/.config/fastfetch"

    mkdir -p "$FASTFETCH_DEST/ascii"
    cp "$FASTFETCH_SRC/config.jsonc" "$FASTFETCH_DEST/" 2>/dev/null || echo "⚠️ config.jsonc not found in $FASTFETCH_SRC"
    cp "$FASTFETCH_SRC/ascii/samurai.txt" "$FASTFETCH_DEST/ascii/" 2>/dev/null || echo "⚠️ samurai.txt not found in $FASTFETCH_SRC/ascii"

    echo "✅ Fastfetch configuration restored!"
else
    echo "⏭️ Skipping Fastfetch installation"
fi

echo ""

# --- Zsh and Terminal Configuration Section ---
if ask_user "🐚 Do you want to install and configure Zsh with Oh My Zsh?"; then
    # Handle input arguments or use defaults
    GNOME_DIR="$PWD/gnome-terminal-backup"
    ZSH_DIR="$PWD/zsh-config"

    echo "📁 Using GNOME Terminal config from: $GNOME_DIR"
    echo "📁 Using Zsh config from: $ZSH_DIR"

    # Install Dependencies
    echo "📦 Installing required packages..."
    sudo apt update
    sudo apt install -y zsh git curl fonts-powerline dconf-cli

    # Restore Zsh Config
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

    # Ask about setting Zsh as default shell
    if ask_user "🔄 Do you want to set Zsh as your default shell?"; then
        chsh -s "$(which zsh)"
        echo "✅ Zsh set as default shell"
    else
        echo "⏭️ Keeping current default shell"
    fi

    # Install Fonts
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

    echo "✅ Zsh configuration completed!"
    echo "🔄 Please restart your terminal or log out/in for all changes to take effect."
    echo "💡 If you installed Zsh, run 'zsh' to start using it immediately."
else
    echo "⏭️ Skipping Zsh installation"
fi

echo ""

# --- GNOME Terminal Configuration Section ---
if ask_user "🖥️ Do you want to restore GNOME Terminal settings?"; then
    GNOME_DIR="$PWD/gnome-terminal-backup"
    echo "🖥️ Restoring GNOME Terminal profile..."
    CONF_FILE="$GNOME_DIR/terminal-settings.dconf"

    if [ -f "$CONF_FILE" ]; then
        dconf load /org/gnome/terminal/legacy/ < "$CONF_FILE"
        echo "✅ GNOME Terminal settings restored!"
    else
        echo "⚠️ terminal-settings.dconf not found in $GNOME_DIR"
    fi
else
    echo "⏭️ Skipping GNOME Terminal configuration"
fi

echo ""

# --- Helix Editor Section ---
if ask_user "📝 Do you want to install Helix editor?"; then
    echo "🔁 Installing helix"
    sudo add-apt-repository ppa:maveonair/helix-editor -y
    sudo apt update
    sudo apt install helix -y
    echo "✅ Installing helix Complete!"
else
    echo "⏭️ Skipping Helix editor installation"
fi

# --- Done ---
echo ""
echo "🎉 Setup complete!"
echo "📋 Summary of what was installed/configured:"

if [ "$RUST_INSTALLED" = true ]; then
    echo "  ✅ Rust and selected Rust tools"
fi
