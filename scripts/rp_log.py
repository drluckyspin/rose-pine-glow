#!/usr/bin/env python3
"""Rosé Pine terminal logging (matches scripts/log.bash / moon-dark roles)."""

from __future__ import annotations

import sys

# rose-pine-moon-dark roles
MOON_DARK = {
    "text": "e0def4",
    "subtle": "908caa",
    "muted": "6e6a86",
    "foam": "9ccfd8",
    "iris": "c4a7e7",
    "pine": "3e8fb0",
    "love": "eb6f92",
    "gold": "f6c177",
    "rose": "ea9a97",
}

RESET = "\033[0m"
DIM = "\033[2m"


def _fg(hex6: str) -> str:
    h = hex6.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return f"\033[38;2;{r};{g};{b}m"


def progress(msg: str) -> None:
    """Progress output only (muted)."""
    c = _fg(MOON_DARK["muted"])
    print(f"{DIM}{c}  {msg}{RESET}", file=sys.stderr)


def info_dim(msg: str) -> None:
    progress(msg)


def success(msg: str) -> None:
    c = _fg(MOON_DARK["pine"])
    print(file=sys.stderr)
    print(f"{_fg(MOON_DARK['pine'])}✔{RESET} {DIM}{c}{msg}{RESET}", file=sys.stderr)


def error(msg: str) -> None:
    c = _fg(MOON_DARK["love"])
    print(f"  {_fg(MOON_DARK['love'])}✖{RESET} {DIM}{c}{msg}{RESET}", file=sys.stderr)
