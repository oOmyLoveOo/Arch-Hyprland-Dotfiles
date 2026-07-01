#!/usr/bin/env bash
#
# Wuke's Arch Linux backup — Phase 3
# Backs up: SSH, NetworkManager, critical /etc files, Kali VM, and pkglists
# Usage: ./backup.sh
#
set -euo pipefail

BACKUP_ROOT="/run/media/wuke/Backup_arch/arch-backup"
DEST="$BACKUP_ROOT/$(date +%Y-%m-%d)"

if [ ! -d "/run/media/wuke/Backup_arch" ]; then
    echo "!! External disk not mounted at /run/media/wuke/Backup_arch. Connect it first."
    exit 1
fi

echo "==> Backup destination: $DEST"
mkdir -p "$DEST"

echo "==> Backing up ~/.ssh..."
cp -a "$HOME/.ssh" "$DEST/ssh"

echo "==> Backing up network profiles (sudo)..."
sudo cp -a /etc/NetworkManager/system-connections "$DEST/network-connections"
sudo chown -R "$USER:$USER" "$DEST/network-connections"

echo "==> Backing up fstab and pacman.conf..."
mkdir -p "$DEST/etc"
cp /etc/fstab /etc/pacman.conf "$DEST/etc/"

echo "==> Backing up Kali VM definition..."
mkdir -p "$BACKUP_ROOT/vms"
virsh -c qemu:///system dumpxml kali > "$BACKUP_ROOT/vms/kali.xml" 2>/dev/null || echo "!! Kali domain not found, skipping."

echo "==> Syncing Kali disk image..."
if virsh -c qemu:///system domstate kali 2>/dev/null | grep -q running; then
    echo "!! Kali is running — shut it down first for a consistent backup. Skipping disk sync this time."
else
    sudo rsync -ah -S --progress ~/VMs/Disks/kali.qcow2 "$BACKUP_ROOT/vms/kali.qcow2"
    sudo chown "$USER:$USER" "$BACKUP_ROOT/vms/kali.qcow2"
fi

echo "==> Generating pkglists..."
mkdir -p "$DEST/pkglists" "$HOME/dotfiles/arch_resource"
pacman -Qqen > "$DEST/pkglists/pkglist_native.txt"
pacman -Qqem > "$DEST/pkglists/pkglist_aur.txt"
flatpak list --app --columns=application > "$DEST/pkglists/pkglist_flatpak.txt" 2>/dev/null || true
cp "$DEST/pkglists/"*.txt "$HOME/dotfiles/arch_resource/"

echo
echo "==> Backup complete: $DEST"
echo "    Next step: rsync of /home (separate, takes longer)."
