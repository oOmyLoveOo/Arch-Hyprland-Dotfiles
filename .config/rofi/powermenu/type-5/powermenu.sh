#!/usr/bin/env bash

# Rutas
dir="$HOME/.config/rofi/powermenu/type-5"
theme='style-1'

# Opciones
lock=" Lock"
suspend=" Suspend"
logout=" Logout"
reboot=" Reboot"
shutdown=" Shutdown"

# Lanzar Rofi
chosen=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi -dmenu -p "System" -theme ${dir}/${theme}.rasi)

# Lógica con comodines
case "$chosen" in
    *Lock*)
        hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf
        ;;
    *Suspend*)
        # Ejecuta el lock en segundo plano, espera 1 segundo y suspende
        hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf & sleep 1 && systemctl suspend
        ;;
    *Logout*)
        hyprctl dispatch 'hl.dsp.exit()'
        ;;
    *Reboot*)
        systemctl reboot
        ;;
    *Shutdown*)
        # El sleep evita que Rofi corte el comando de apagado a la mitad
        systemd-run --user systemctl poweroff
        ;;
esac
