#!/bin/bash
# 1. Variables de Entorno
export XDG_RUNTIME_DIR=/run/user/1000
export WAYLAND_DISPLAY=wayland-1
export DISPLAY=:0

# 2. Rutas
HYPRSUNSET="/usr/bin/hyprsunset"
BRIGHTNESS="/usr/bin/brightnessctl"
NOTIFY="/usr/bin/notify-send"
STATE_FILE="/tmp/swaync-night-state"

# 3. Funciones
activar_noche() {
    if ! pgrep -x "hyprsunset" > /dev/null; then
        # Sin la 'K' y con nohup para que no muera al cerrar el script
        nohup $HYPRSUNSET --temperature 4000 > /dev/null 2>&1 &
        sleep 0.5
        $BRIGHTNESS set 35%
        $NOTIFY "Night Mode" "Brillo al 35% y Luz Cálida" -i weather-clear-night
    fi
    echo "true" > "$STATE_FILE"
}

activar_dia() {
    pkill hyprsunset
    $BRIGHTNESS set 70%
    $NOTIFY "Morning mode" "Brillo al 70% y Luz Normal" -i weather-clear
    echo "false" > "$STATE_FILE"
}

# 4. Lógica
case $1 in
    --force-night)
        activar_noche
        ;;
    --force-day)
        activar_dia
        ;;
    *)
        if pgrep -x "hyprsunset" > /dev/null; then
            activar_dia
        else
            activar_noche
        fi
        ;;
esac
