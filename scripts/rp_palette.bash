#!/bin/bash
# Rosé Pine Moon Dark palette — shared terminal role hex (no # prefix).
# https://rosepinetheme.com/palette/ingredients

RP_HEX_BASE=191724
RP_HEX_SURFACE=2a273f
RP_HEX_OVERLAY=26233a
RP_HEX_MUTED=6e6a86
RP_HEX_SUBTLE=908caa
RP_HEX_TEXT=e0def4
RP_HEX_LOVE=eb6f92
RP_HEX_GOLD=f6c177
RP_HEX_ROSE=ea9a97
RP_HEX_PINE=3e8fb0
RP_HEX_FOAM=9ccfd8
RP_HEX_IRIS=c4a7e7

# Truecolor foreground: _rp_fg <hex6>
_rp_fg() {
    local hex="${1#\#}"
    local r g b
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}
