# -----------------------------------------------------------------------------------------------------------
# Rosé Pine Glow — Makefile
# -----------------------------------------------------------------------------------------------------------
# Glamour styles for https://github.com/charmbracelet/glow
#
#   make help        — list targets
#   make check       — verify tools
#   make build       — regenerate styles/*.json
#   make test        — validate JSON + Glamour render
#   make screenshots — gallery PNGs
#   make install     — interactive install to ~/.config/glow
#   make preview     — glow examples/sample.md (STYLE=rose-pine-moon-dark)
# -----------------------------------------------------------------------------------------------------------

include Common.make

# Override default preview style:
#   make preview STYLE=rose-pine-dawn
