#!/usr/bin/env python3
"""Generate Glamour JSON styles from Rosé Pine palette roles."""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from rp_log import info_dim  # noqa: E402

PALETTES = {
    "rose-pine": {
        "base": "#191724",
        "surface": "#1f1d2e",
        "overlay": "#26233a",
        "muted": "#6e6a86",
        "subtle": "#908caa",
        "text": "#e0def4",
        "love": "#eb6f92",
        "gold": "#f6c177",
        "rose": "#ebbcba",
        "pine": "#31748f",
        "foam": "#9ccfd8",
        "iris": "#c4a7e7",
    },
    "rose-pine-moon": {
        "base": "#232136",
        "surface": "#2a273f",
        "overlay": "#393552",
        "muted": "#6e6a86",
        "subtle": "#908caa",
        "text": "#e0def4",
        "love": "#eb6f92",
        "gold": "#f6c177",
        "rose": "#ea9a97",
        "pine": "#3e8fb0",
        "foam": "#9ccfd8",
        "iris": "#c4a7e7",
    },
    # Moon syntax on main base — pairs with rose-pine-bat Rose-Pine-Moon
    "rose-pine-moon-dark": {
        "base": "#191724",
        "surface": "#2a273f",
        "overlay": "#26233a",
        "muted": "#6e6a86",
        "subtle": "#908caa",
        "text": "#e0def4",
        "love": "#eb6f92",
        "gold": "#f6c177",
        "rose": "#ea9a97",
        "pine": "#3e8fb0",
        "foam": "#9ccfd8",
        "iris": "#c4a7e7",
    },
    "rose-pine-dawn": {
        "base": "#faf4ed",
        "surface": "#fffaf3",
        "overlay": "#f2e9e1",
        "muted": "#9893a5",
        "subtle": "#797593",
        "text": "#464261",
        "love": "#b4637a",
        "gold": "#ea9d34",
        "rose": "#d7827e",
        "pine": "#286983",
        "foam": "#56949f",
        "iris": "#907aa9",
    },
}


def build_style(p: dict) -> dict:
    return {
        "document": {
            "block_prefix": "\n",
            "block_suffix": "\n",
            "color": p["text"],
            "margin": 2,
        },
        "block_quote": {
            "color": p["muted"],
            "italic": True,
            "indent": 1,
            "indent_token": "│ ",
        },
        "paragraph": {},
        "list": {
            "color": p["text"],
            "level_indent": 2,
        },
        "heading": {
            "block_suffix": "\n",
            "color": p["love"],
            "bold": True,
        },
        "h1": {"prefix": "# "},
        "h2": {"prefix": "## "},
        "h3": {"prefix": "### "},
        "h4": {"prefix": "#### "},
        "h5": {"prefix": "##### "},
        "h6": {"prefix": "###### "},
        "text": {},
        "strikethrough": {"crossed_out": True},
        "emph": {"color": p["text"], "italic": True},
        "strong": {"color": p["rose"], "bold": True},
        "hr": {"color": p["overlay"], "format": "\n--------\n"},
        "item": {"block_prefix": "• "},
        "enumeration": {"block_prefix": ". ", "color": p["foam"]},
        "task": {"ticked": "[✓] ", "unticked": "[ ] "},
        "link": {"color": p["pine"], "underline": True},
        "link_text": {"color": p["iris"]},
        "image": {"color": p["pine"], "underline": True},
        "image_text": {"color": p["iris"], "format": "Image: {{.text}} →"},
        "code": {
            "color": p["gold"],
            "background_color": p["surface"],
        },
        "code_block": {
            "color": p["gold"],
            "margin": 2,
            "chroma": {
                "text": {"color": p["text"]},
                "error": {
                    "color": p["text"],
                    "background_color": p["love"],
                },
                "comment": {"color": p["muted"]},
                "comment_preproc": {"color": p["iris"]},
                "keyword": {"color": p["pine"]},
                "keyword_reserved": {"color": p["pine"]},
                "keyword_namespace": {"color": p["pine"]},
                "keyword_type": {"color": p["foam"]},
                "operator": {"color": p["subtle"]},
                "punctuation": {"color": p["text"]},
                "name": {"color": p["text"]},
                "name_builtin": {"color": p["foam"]},
                "name_tag": {"color": p["iris"]},
                "name_attribute": {"color": p["foam"]},
                "name_class": {"color": p["foam"]},
                "name_constant": {"color": p["rose"]},
                "name_decorator": {"color": p["gold"]},
                "name_exception": {},
                "name_function": {"color": p["rose"]},
                "name_other": {},
                "literal": {},
                "literal_number": {"color": p["foam"]},
                "literal_date": {},
                "literal_string": {"color": p["gold"]},
                "literal_string_escape": {"color": p["pine"]},
                "generic_deleted": {"color": p["love"]},
                "generic_emph": {"color": p["gold"], "italic": True},
                "generic_inserted": {"color": p["pine"]},
                "generic_strong": {"color": p["rose"], "bold": True},
                "generic_subheading": {"color": p["iris"]},
                "background": {"background_color": p["base"]},
            },
        },
        "table": {},
        "definition_list": {},
        "definition_term": {},
        "definition_description": {"block_prefix": "\n🠶 "},
        "html_block": {},
        "html_span": {},
    }


def main() -> None:
    styles_dir = Path(__file__).resolve().parent.parent / "styles"
    styles_dir.mkdir(parents=True, exist_ok=True)
    for name, palette in PALETTES.items():
        path = styles_dir / f"{name}.json"
        path.write_text(
            json.dumps(build_style(palette), indent=2) + "\n",
            encoding="utf-8",
        )
        info_dim(f"wrote {path.name}")


if __name__ == "__main__":
    main()
