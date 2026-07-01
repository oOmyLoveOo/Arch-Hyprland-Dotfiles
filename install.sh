#!/usr/bin/env bash
#
# Wuke's Arch Linux + Hyprland dotfiles installer
# Usage: ./install.sh
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> Dotfiles directory: $DOTFILES_DIR"

# 1. Enable multilib (needed for lib32-*/Steam)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "==> Enabling multilib..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy
fi

# 2. Packages — read from arch_resource/pkglist_*.txt (kept fresh by backup.sh)
echo "==> Installing pacman packages..."
sudo pacman -S --needed - < "$DOTFILES_DIR/arch_resource/pkglist_native.txt"

if command -v yay &>/dev/null; then
    echo "==> Installing AUR packages with yay..."
    yay -S --needed - < "$DOTFILES_DIR/arch_resource/pkglist_aur.txt"
else
    echo "!! yay not found — install yay-bin manually first, then re-run this script."
fi

if command -v flatpak &>/dev/null && [ -s "$DOTFILES_DIR/arch_resource/pkglist_flatpak.txt" ]; then
    echo "==> Installing Flatpak apps..."
    while read -r app; do
        [ -n "$app" ] && flatpak install -y flathub "$app"
    done < "$DOTFILES_DIR/arch_resource/pkglist_flatpak.txt"
fi

# 3. Oh My Zsh + Powerlevel10k + plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 4. Stow
echo "==> Stowing dotfiles into $HOME..."
cd "$DOTFILES_DIR"
stow --target="$HOME" --restow .

# 5. Executable permissions
chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
find "$HOME/.config/rofi" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$HOME/.config/swaync/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# 6. Default color scheme
echo "==> Applying default color scheme..."
"$HOME/.local/bin/wallpaper_manager.sh" reapply || true

echo
echo "==> Manual steps NOT automated here:"
echo "    - Restore ~/.ssh, /etc/NetworkManager/system-connections, and Kali VM from the external backup."
echo "    - Run 'envycontrol -s hybrid' (or your preferred mode) after the NVIDIA driver is installed."
echo
echo "==> Done! Restart your session or log into Hyprland to apply everything."
echo "    Default shell is zsh — run 'chsh -s \$(which zsh)' if it isn't already your default."
