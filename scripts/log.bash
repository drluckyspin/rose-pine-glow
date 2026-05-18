#!/bin/bash

# -----------------------------------------------------------------------------------------------------------
# Script Name: log.bash
# Description: Rosé Pine Moon Dark themed logging (stdout-safe: all logs go to stderr).
# -----------------------------------------------------------------------------------------------------------

VERBOSE=false

# shellcheck source=scripts/rp_palette.bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/rp_palette.bash"

RESET='\033[0m'
DIM='\033[2m'

# Role colors (moon-dark)
RP_TEXT=$(_rp_fg "$RP_HEX_TEXT")
RP_SUBTLE=$(_rp_fg "$RP_HEX_SUBTLE")
RP_MUTED=$(_rp_fg "$RP_HEX_MUTED")
RP_FOAM=$(_rp_fg "$RP_HEX_FOAM")
RP_IRIS=$(_rp_fg "$RP_HEX_IRIS")
RP_PINE=$(_rp_fg "$RP_HEX_PINE")
RP_LOVE=$(_rp_fg "$RP_HEX_LOVE")
RP_GOLD=$(_rp_fg "$RP_HEX_GOLD")
RP_ROSE=$(_rp_fg "$RP_HEX_ROSE")

get_terminal_width() {
    local width
    width=$(tput cols 2>/dev/null || echo 80)
    if [ "$width" -gt 120 ]; then
        width=120
    fi
    echo "$width"
}

log() {
    echo -e "${RP_TEXT}${1}${RESET}" >&2
}

log_dim() {
    echo -e "${DIM}${RP_SUBTLE}  ${1}${RESET}" >&2
}

log_info() {
    echo -e "${RP_IRIS}${1}${RESET}" >&2
}

# Progress / status lines only (muted — low contrast on dark terminals).
log_progress() {
    echo -e "${DIM}${RP_MUTED}  ${1}${RESET}" >&2
}

# Readable secondary lines (menus, hints) — subtle, not muted.
log_option() {
    echo -e "  ${RP_SUBTLE}${1}${RESET}" >&2
}

# Alias for Makefile/scripts that already call log_info_dim.
log_info_dim() {
    log_progress "$@"
}

log_success() {
    echo "" >&2
    echo -e "${RP_PINE}✔${RESET} ${DIM}${RP_PINE}${1}${RESET}" >&2
}

log_error() {
    echo -e "  ${RP_LOVE}✖${RESET} ${DIM}${RP_LOVE}${1}${RESET}" >&2
}

log_warning() {
    echo -e "  ${RP_GOLD}▲${RESET} ${DIM}${RP_GOLD}${1}${RESET}" >&2
}

# Interactive read prompts (flush with section titles; message in foam, default/hint in text).
log_prompt() {
    local msg="$1"
    local default="${2:-}"
    if [[ -n "$default" ]]; then
        printf "${RP_FOAM}%s ${RESET}${RP_TEXT}[%s]${RESET}${DIM}${RP_SUBTLE}: ${RESET}" "$msg" "$default" >&2
    else
        printf "${RP_FOAM}%s${RESET}${DIM}${RP_SUBTLE}: ${RESET}" "$msg" >&2
    fi
}

log_confirm_prompt() {
    local msg="$1"
    local hint="$2"
    printf "${RP_FOAM}%s ${RESET}${RP_TEXT}[%s]${RESET}${DIM}${RP_SUBTLE}: ${RESET}" "$msg" "$hint" >&2
}

log_separator() {
    local terminal_width
    terminal_width=$(get_terminal_width)
    printf "${DIM}${RP_MUTED}" >&2
    printf '=-%.0s' $(seq 1 $((terminal_width / 2))) >&2
    printf "=%b\n" "${RESET}" >&2
}

log_indent() {
    local log_func=$1
    shift
    echo -ne "  " >&2
    $log_func "$@"
}

log_centered() {
    local terminal_width message padding pad_str
    message="$1"
    terminal_width=$(get_terminal_width)
    padding=$(((terminal_width - ${#message}) / 2))
    pad_str=$(printf '%*s' "$padding" '')
    echo -e "${pad_str}${RP_TEXT}${message}${RESET}" >&2
}

log_verbose() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        log_info_dim "$*"
    fi
}

log_banner() {
    echo -e "
    ${RP_IRIS}██████╗  ██████╗ ███████╗███████╗     ${RP_ROSE}██████╗ ██╗███╗   ██╗███████╗${RESET}
    ${RP_IRIS}██╔══██╗██╔═══██╗██╔════╝██╔════╝     ${RP_ROSE}██╔══██╗██║████╗  ██║██╔════╝${RESET}
    ${RP_IRIS}██████╔╝██║   ██║███████╗█████╗       ${RP_ROSE}██████╔╝██║██╔██╗ ██║█████╗  ${RESET}
    ${RP_IRIS}██╔══██╗██║   ██║╚════██║██╔══╝       ${RP_ROSE}██╔═══╝ ██║██║╚██╗██║██╔══╝  ${RESET}
    ${RP_IRIS}██║  ██║╚██████╔╝███████║███████╗     ${RP_ROSE}██║     ██║██║ ╚████║███████╗${RESET}
    ${RP_IRIS}╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝     ${RP_ROSE}╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝${RESET}
                        ${RP_GOLD}Rosé Pine Glow — Glamour styles for Charm Glow${RESET}
    " >&2
}


# -----------------------------------------------------------------------------------------------------------
# Example usage
# -----------------------------------------------------------------------------------------------------------   
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_separator
    log_banner
    log "This is a normal message."
    log_dim "This is a dim message."
    log_info "This is an info message."
    log_progress "This is a progress message."
    log_option "This is a menu option line."
    log_success "This is a success message."
    log_warning "This is a warning message."
    log_error "This is an error message."
    log_indent log_success "This is an indented message."
    log_centered "This is a centered message"
    log_separator
fi