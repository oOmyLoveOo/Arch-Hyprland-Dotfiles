-- Privacy while sharing the screen
-- Do Not Disturb is turned on while a screenshare is active and restored
-- to its previous state afterwards (see ~/.local/bin/screenshare-privacy.sh).

hl.on("screenshare.state", function(active)
    hl.exec_cmd("~/.local/bin/screenshare-privacy.sh " .. (active and "start" or "stop"))
end)
