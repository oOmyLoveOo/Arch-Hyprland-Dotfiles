#!/usr/bin/env bash
## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
## Adapted alternative powermenu with a confirmation dialog (not used by default,
## kept here in case you want a "are you sure?" step before shutdown/reboot/logout).

dir="$HOME/.config/rofi/powermenu/type-5"
theme='style-1'

lastlogin="`last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7`"
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

# Hibernate option removed (not used)
lock=' Lock'
suspend=' Suspend'
logout=' Logout'
reboot=' Reboot'
shutdown=' Shutdown'
yes=' '
no=' '

rofi_cmd() {
    rofi -dmenu \
        -p " $USER@$host" \
        -mesg " Last Login: $lastlogin |  Uptime: $uptime" \
        -eh 2 \
        -theme ${dir}/${theme}.rasi
}

confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you sure?' \
        -theme ${dir}/${theme}.rasi
}

confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            systemctl poweroff --force --force
        elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
        elif [[ $1 == '--suspend' ]]; then
            hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf & sleep 1 && systemctl suspend
        elif [[ $1 == '--logout' ]]; then
            hyprctl dispatch exit
        fi
    else
        exit 0
    fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $lock)
        hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf
        ;;
    $suspend)
        run_cmd --suspend
        ;;
    $logout)
        run_cmd --logout
        ;;
esac
