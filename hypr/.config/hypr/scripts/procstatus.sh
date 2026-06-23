#!/usr/bin/env bash
# Summon / dismiss the "process status" scratchpad (btop + bandwhich).
#
# First press: reveal the special workspace and lazily spawn the kitty window
# into it. Subsequent presses just toggle the special workspace's visibility,
# preserving btop/bandwhich state.

set -uo pipefail

if hyprctl clients -j | grep -q '"class": "procstatus"'; then
    # Window already exists — just flip the scratchpad's visibility.
    hyprctl dispatch togglespecialworkspace procstatus
else
    # Reveal the (empty) scratchpad, then spawn into it. The windowrule in
    # hyprland.conf assigns class:procstatus to special:procstatus.
    hyprctl dispatch togglespecialworkspace procstatus
    # Smaller font + tighter padding so both split panes clear btop's 80x24
    # minimum on this HiDPI display.
    exec kitty -o font_size=10 -o window_padding_width=6 \
        --class procstatus --session "$HOME/.config/kitty/procstatus.session"
fi
