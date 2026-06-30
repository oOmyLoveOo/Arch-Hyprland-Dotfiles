#!/usr/bin/env bash
#
# Wuke's Arch Linux + Hyprland dotfiles installer
# Usage: ./install.sh
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Dotfiles directory: $DOTFILES_DIR"

# ----------------------------------------------------------------------------
# 1. Required packages
# ----------------------------------------------------------------------------
PACMAN_PKGS=(
    hyprland waybar swaync rofi kitty thunar yazi
    btop cava fastfetch wallust
    brightnessctl playerctl pavucontrol cmatrix tty-clock
    network-manager-applet nm-connection-editor blueman bluez
    cliphist wl-clipboard udiskie
    grim slurp swappy
    hyprlock hypridle hyprsunset hyprpolkitagent
    gnome-keyring
    ttf-jetbrains-mono-nerd otf-font-awesome
    zsh stow
)

AUR_PKGS=(
    awww
    rofimoji
)

echo "==> Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

if command -v yay &>/dev/null; then
    echo "==> Installing AUR packages with yay..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
else
    echo "!! yay not found — install these manually from the AUR: ${AUR_PKGS[*]}"
fi

# ----------------------------------------------------------------------------
# 2. Oh My Zsh + Powerlevel10k + plugins (only if not already installed)
# ----------------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "==> Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "==> Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# ----------------------------------------------------------------------------
# 3. Stow the dotfiles (creates symlinks into $HOME)
# ----------------------------------------------------------------------------
echo "==> Stowing dotfiles into $HOME..."
cd "$DOTFILES_DIR"
stow --target="$HOME" --restow .

# ----------------------------------------------------------------------------
# 4. Make scripts executable
# ----------------------------------------------------------------------------
echo "==> Setting executable permissions on scripts..."
chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
find "$HOME/.config/rofi" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$HOME/.config/swaync/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# ----------------------------------------------------------------------------
# 5. Apply default color scheme (static Tokyo Night)
# ----------------------------------------------------------------------------
echo "==> Applying default color scheme..."
"$HOME/.local/bin/wallpaper_manager.sh" reapply || true

echo
echo "==> Done! Restart your session or log into Hyprland to apply everything."
echo "    Default shell is zsh — run 'chsh -s \$(which zsh)' if it isn't already your default."
