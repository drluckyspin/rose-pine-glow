#!/usr/bin/env bash
# Install Rosé Pine Glow styles and configure Charm Glow.
#
# Usage:
#   ./scripts/install.bash
#   ./scripts/install.bash --yes --style rose-pine-moon-dark
#   make install
#   make install INSTALL_STYLE=rose-pine-dawn

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=scripts/log.bash
source "$SCRIPT_DIR/log.bash"

STYLES_SRC="$REPO_ROOT/styles"
DEFAULT_STYLES_DEST="${GLOW_STYLES_DIR:-$HOME/.config/glow/styles}"
DEFAULT_STYLE="${INSTALL_STYLE:-rose-pine-moon-dark}"
ASSUME_YES=false
NONINTERACTIVE=false
CHOSEN_STYLE=""

VARIANTS=(
  "rose-pine|Rosé Pine (main)|Official main palette"
  "rose-pine-moon|Rosé Pine Moon|Official moon base"
  "rose-pine-moon-dark|Rosé Pine Moon Dark|Moon accents, main base"
  "rose-pine-dawn|Rosé Pine Dawn|Light theme"
)

usage() {
  cat <<'EOF'
Usage: install.bash [options]

  Installs Glamour JSON styles and sets glow.yml to your chosen default.

Options:
  -y, --yes              Accept defaults (styles dir, moon-dark, update config)
  -s, --style NAME       Default style (rose-pine, rose-pine-moon, rose-pine-moon-dark, rose-pine-dawn)
  -d, --styles-dir PATH  Install styles here (default: ~/.config/glow/styles)
  -c, --config PATH      glow.yml path (default: auto-detect)
  -n, --non-interactive  Same as --yes (for CI)
  -h, --help             Show this help

Environment:
  INSTALL_STYLE          Default style name (same as --style)
  GLOW_STYLES_DIR        Styles install directory
  GLOW_CONFIG_FILE       glow.yml path
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) ASSUME_YES=true; NONINTERACTIVE=true; shift ;;
    -n|--non-interactive) NONINTERACTIVE=true; shift ;;
    -s|--style) DEFAULT_STYLE="$2"; shift 2 ;;
    -d|--styles-dir) DEFAULT_STYLES_DEST="$2"; shift 2 ;;
    -c|--config) GLOW_CONFIG_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown option: $1"; usage; exit 1 ;;
  esac
done

require_glow() {
  if ! command -v glow >/dev/null 2>&1; then
    log_error "glow is not installed. Install with: brew install glow"
    exit 1
  fi
}

discover_glow_config() {
  if [[ -n "${GLOW_CONFIG_FILE:-}" ]]; then
    echo "$GLOW_CONFIG_FILE"
    return
  fi

  local candidates=()
  if [[ "$(uname -s)" == "Darwin" ]]; then
    candidates+=(
      "$HOME/Library/Application Support/glow/glow.yml"
      "$HOME/Library/Preferences/glow/glow.yml"
    )
  fi
  candidates+=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/glow/glow.yml"
  )
  if [[ -n "${GLOW_CONFIG_HOME:-}" ]]; then
    candidates=("$GLOW_CONFIG_HOME/glow.yml" "${candidates[@]}")
  fi

  local c
  for c in "${candidates[@]}"; do
    if [[ -f "$c" ]]; then
      echo "$c"
      return
    fi
  done

  if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$HOME/Library/Application Support" ]]; then
    echo "$HOME/Library/Application Support/glow/glow.yml"
  else
    echo "${XDG_CONFIG_HOME:-$HOME/.config}/glow/glow.yml"
  fi
}

style_exists() {
  local name="$1"
  [[ -f "$STYLES_SRC/${name}.json" ]]
}

prompt() {
  local msg="$1"
  local default="${2:-}"
  if $NONINTERACTIVE; then
    echo "$default"
    return
  fi
  local reply
  if [[ -n "$default" ]]; then
    log_prompt "$msg" "$default"
    read -r reply </dev/tty
    echo "${reply:-$default}"
  else
    log_prompt "$msg"
    read -r reply </dev/tty
    echo "$reply"
  fi
}

confirm() {
  local msg="$1"
  local default="${2:-y}"
  if $ASSUME_YES; then
    [[ "$default" =~ ^[Yy] ]]
    return
  fi
  local reply hint
  if [[ "$default" =~ ^[Yy] ]]; then hint="Y/n"; else hint="y/N"; fi
  log_confirm_prompt "$msg" "$hint"
  read -r reply </dev/tty
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy] ]]
}

choose_style() {
  CHOSEN_STYLE="$DEFAULT_STYLE"

  if ! style_exists "$DEFAULT_STYLE"; then
    log_error "Default style not found: $DEFAULT_STYLE (run: make build)"
    exit 1
  fi

  if $NONINTERACTIVE; then
    return
  fi

  log_info "Choose your default Glow style"
  local i=1 line id _label desc
  for line in "${VARIANTS[@]}"; do
    IFS='|' read -r id _label desc <<<"$line"
    log_option "$i) $id — $desc"
    ((i++)) || true
  done
  echo "" >&2

  local pick
  pick="$(prompt "Enter number (1-4) or style name" "$DEFAULT_STYLE")"

  if [[ "$pick" =~ ^[1-4]$ ]]; then
    IFS='|' read -r id _ _ <<<"${VARIANTS[$((pick - 1))]}"
    CHOSEN_STYLE="$id"
    return
  fi
  if style_exists "$pick"; then
    CHOSEN_STYLE="$pick"
    return
  fi

  log_warning "Unknown choice '$pick', using $DEFAULT_STYLE"
  CHOSEN_STYLE="$DEFAULT_STYLE"
}

copy_styles() {
  local dest="$1"
  mkdir -p "$dest"
  local f base
  for f in "$STYLES_SRC"/*.json; do
    base="$(basename "$f")"
    cp "$f" "$dest/$base"
    log_progress "Installed $base"
  done
}

update_glow_config() {
  local config_path="$1"
  local style_path="$2"
  local width="${3:-80}"
  local pager="${4:-false}"

  python3 - "$config_path" "$style_path" "$width" "$pager" <<'PY'
import re
import sys
from pathlib import Path

config_path, style_path, width, pager = sys.argv[1:5]
path = Path(config_path)
default = f'''# style name or JSON path
style: "{style_path}"
mouse: false
pager: {str(pager).lower()}
width: {width}
all: false
showLineNumbers: false
preserveNewLines: false
'''

if path.exists():
    text = path.read_text()
    backup = path.with_suffix(path.suffix + ".bak")
    backup.write_text(text)
    print(f"backup:{backup}", flush=True)
else:
    text = default
    path.parent.mkdir(parents=True, exist_ok=True)

def set_key(key: str, value: str) -> None:
    global text
    pattern = rf"^{re.escape(key)}:.*$"
    if key == "style":
        line = f'style: "{style_path}"'
    elif key in ("pager", "mouse", "all", "showLineNumbers", "preserveNewLines"):
        line = f"{key}: {str(value).lower()}"
    else:
        line = f"{key}: {value}"
    if re.search(pattern, text, flags=re.M):
        text = re.sub(pattern, line, text, count=1, flags=re.M)
    else:
        text = text.rstrip() + "\n" + line + "\n"

set_key("style", style_path)
set_key("width", width)
set_key("pager", pager)
path.write_text(text if text.endswith("\n") else text + "\n")
print(f"config:{path}", flush=True)
PY
}

main() {
  log_info "Rosé Pine Glow — install"
  echo ""

  require_glow

  if [[ ! -d "$STYLES_SRC" ]] || ! compgen -G "$STYLES_SRC"/*.json >/dev/null; then
    log_error "No styles found in $STYLES_SRC — run: make build"
    exit 1
  fi

  local styles_dest config_path chosen_style style_file width pager

  if $NONINTERACTIVE; then
    styles_dest="$DEFAULT_STYLES_DEST"
  else
    styles_dest="$(prompt "Styles install directory" "$DEFAULT_STYLES_DEST")"
  fi
  styles_dest="${styles_dest/#\~/$HOME}"

  log_progress "Installing styles to $styles_dest"
  copy_styles "$styles_dest"
  log_success "Installed $(find "$styles_dest" -maxdepth 1 -name 'rose-pine*.json' | wc -l | tr -d ' ') style files"
  echo ""

  choose_style
  chosen_style="$CHOSEN_STYLE"

  if ! style_exists "$chosen_style"; then
    log_error "Missing style file: ${chosen_style}.json"
    exit 1
  fi
  style_file="$styles_dest/${chosen_style}.json"

  config_path="$(discover_glow_config)"
  log_progress "Glow config: $config_path"

  if $NONINTERACTIVE; then
    width=80
    pager=false
  else
    echo "" >&2
    width="$(prompt "Word wrap width" "100")"
    if confirm "Disable pager in glow.yml? (recommended)"; then
      pager=false
    else
      pager=true
    fi
    if [[ -f "$config_path" ]]; then
      if ! confirm "Update $config_path with style: $chosen_style?"; then
        log_warning "Skipped config update. Add manually:"
        log_dim "style: \"$style_file\""
        exit 0
      fi
    fi
  fi

  local py_out line
  py_out="$(update_glow_config "$config_path" "$style_file" "$width" "$pager")"
  while IFS= read -r line; do
    case "$line" in
      backup:*) log_progress "Backed up existing config to ${line#backup:}" ;;
      config:*) log_progress "Wrote ${line#config:}" ;;
    esac
  done <<<"$py_out"

  log_dim "Default style: $chosen_style"
  echo ""
  log_info "Example usage:"
  log_indent log_dim "glow -s \"$style_file\" examples/sample.md"
  log_indent log_dim "glow   # TUI uses glow.yml"
  log_success "Install complete"
}

main "$@"
