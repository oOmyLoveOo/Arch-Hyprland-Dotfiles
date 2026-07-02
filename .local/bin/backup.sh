#!/usr/bin/env bash
#
# Wuke's Arch Linux backup — Phase 3
# Backs up: SSH, NetworkManager, critical /etc files, Kali VM, and pkglists
# Usage: ./backup.sh
#
set -euo pipefail

BACKUP_ROOT="/run/media/$USER/Backup_arch/arch-backup"
DEST="$BACKUP_ROOT/$(date +%Y-%m-%d)"

if ! mountpoint -q "/run/media/$USER/Backup_arch"; then
    echo "!! External disk not mounted at /run/media/$USER/Backup_arch. Connect it first."
    exit 1
fi

echo "==> Backup destination: $DEST"
mkdir -p "$DEST"

FAILED=()

backup_ssh() {
    cp -a "$HOME/.ssh" "$DEST/ssh"
}

backup_network() {
    sudo cp -a /etc/NetworkManager/system-connections "$DEST/network-connections"
    sudo chown -R "$USER:$USER" "$DEST/network-connections"
}

backup_etc() {
    mkdir -p "$DEST/etc"
    cp /etc/fstab /etc/pacman.conf "$DEST/etc/"
}

backup_kali_definition() {
    mkdir -p "$BACKUP_ROOT/vms"
    if ! virsh -c qemu:///system dumpxml kali > "$BACKUP_ROOT/vms/kali.xml" 2>/dev/null; then
        echo "!! Kali domain not found, skipping."
    fi
}

backup_kali_disk() {
    mkdir -p "$BACKUP_ROOT/vms"
    if virsh -c qemu:///system domstate kali 2>/dev/null | grep -q running; then
        echo "!! Kali is running — shut it down first for a consistent backup. Skipping disk sync this time."
        return 1
    fi
    sudo rsync -ah -S --progress ~/VMs/Disks/kali.qcow2 "$BACKUP_ROOT/vms/kali.qcow2"
    sudo chown "$USER:$USER" "$BACKUP_ROOT/vms/kali.qcow2"
}

backup_pkglists() {
    mkdir -p "$DEST/pkglists" "$HOME/dotfiles/arch_resource"
    pacman -Qqen > "$DEST/pkglists/pkglist_native.txt"
    pacman -Qqem > "$DEST/pkglists/pkglist_aur.txt"
    if command -v flatpak &>/dev/null; then
        flatpak list --app --columns=application > "$DEST/pkglists/pkglist_flatpak.txt"
    else
        echo "!! flatpak not installed, writing empty pkglist_flatpak.txt"
        : > "$DEST/pkglists/pkglist_flatpak.txt"
    fi
    cp "$DEST/pkglists/"*.txt "$HOME/dotfiles/arch_resource/"
}

backup_claude_code() {
    mkdir -p "$DEST/claude-code"
    if [ -f "$HOME/.claude/settings.json" ]; then
        cp "$HOME/.claude/settings.json" "$DEST/claude-code/settings.json"
    else
        echo "!! No settings.json found, skipping."
    fi
    if [ -f "$HOME/.claude/CLAUDE.md" ]; then
        cp "$HOME/.claude/CLAUDE.md" "$DEST/claude-code/CLAUDE.md"
    else
        echo "!! No CLAUDE.md found, skipping."
    fi
}

# Runs each step in a subshell so a failure inside one step aborts only
# that step (thanks to the inherited `set -e`), never the whole backup —
# every section below always gets a chance to run and report its own result.
run_step() {
    local name="$1"; shift
    echo "==> $name..."
    if ( "$@" ); then
        return 0
    fi
    echo "!! FAILED: $name (see message above)"
    FAILED+=("$name")
}

run_step "Backing up ~/.ssh" backup_ssh
run_step "Backing up network profiles (sudo)" backup_network
run_step "Backing up fstab and pacman.conf" backup_etc
run_step "Backing up Kali VM definition" backup_kali_definition
run_step "Syncing Kali disk image" backup_kali_disk
run_step "Generating pkglists" backup_pkglists
run_step "Backing up Claude Code config" backup_claude_code

echo
if [ "${#FAILED[@]}" -eq 0 ]; then
    echo "==> Backup complete: $DEST"
else
    echo "==> Backup finished WITH FAILURES: ${FAILED[*]}"
    echo "    Review the messages above BEFORE wiping the system."
fi
echo "    Next step: rsync of /home (separate, takes longer)."
