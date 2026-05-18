
#!/usr/bin/env python3
"""Generate README gallery previews (terminal-style PNGs)."""

from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    raise SystemExit("Install Pillow: pip install pillow")

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "screenshots"

VARIANTS = {
    "rose-pine": {
        "title": "Rosé Pine",
        "base": "#191724",
        "surface": "#1f1d2e",
        "text": "#e0def4",
        "love": "#eb6f92",
        "gold": "#f6c177",
        "pine": "#31748f",
        "iris": "#c4a7e7",
        "foam": "#9ccfd8",
        "muted": "#6e6a86",
    },
    "rose-pine-moon": {
        "title": "Rosé Pine Moon",
        "base": "#232136",
        "surface": "#2a273f",
        "text": "#e0def4",
        "love": "#eb6f92",
        "gold": "#f6c177",
        "pine": "#3e8fb0",
        "iris": "#c4a7e7",
        "foam": "#9ccfd8",
        "muted": "#6e6a86",
    },
    "rose-pine-moon-dark": {
        "title": "Rosé Pine Moon Dark",
        "base": "#191724",
        "surface": "#2a273f",
        "text": "#e0def4",
        "love": "#eb6f92",
        "gold": "#f6c177",
        "pine": "#3e8fb0",
        "iris": "#c4a7e7",
        "foam": "#9ccfd8",
        "muted": "#6e6a86",
    },
    "rose-pine-dawn": {
        "title": "Rosé Pine Dawn",
        "base": "#faf4ed",
        "surface": "#fffaf3",
        "text": "#464261",
        "love": "#b4637a",
        "gold": "#ea9d34",
        "pine": "#286983",
        "iris": "#907aa9",
        "foam": "#56949f",
        "muted": "#9893a5",
    },
}


def hex_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def font_paths() -> list[Path]:
    home = Path.home()
    return [
        home / "Library/Fonts/JetBrainsMonoNL-Regular.ttf",
        home / "Library/Fonts/JetBrainsMono-Regular.ttf",
        home / "Library/Fonts/JetBrainsMono[wght].ttf",
        Path("/usr/share/fonts/truetype/jetbrains/JetBrainsMono-Regular.ttf"),
        Path("/usr/share/fonts/TTF/JetBrainsMono-Regular.ttf"),
        Path("/System/Library/Fonts/Menlo.ttc"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"),
    ]


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in font_paths():
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def render(name: str, v: dict) -> None:
    w, h = 920, 520
    img = Image.new("RGB", (w, h), hex_rgb(v["base"]))
    draw = ImageDraw.Draw(img)
    draw.rectangle((24, 24, w - 24, h - 24), fill=hex_rgb(v["surface"]))

    f_title = font(22)
    f_body = font(15)
    f_code = font(14)
    x, y = 48, 48

    draw.text((x, y), v["title"], fill=hex_rgb(v["love"]), font=f_title)
    y += 40
    draw.text(
        (x, y),
        "All natural pine, faux fur and a bit of soho vibes.",
        fill=hex_rgb(v["text"]),
        font=f_body,
    )
    y += 32
    draw.text((x, y), "│ Block quote in muted tones.", fill=hex_rgb(v["muted"]), font=f_body)
    y += 36
    link_label = "Link text"
    draw.text((x, y), link_label, fill=hex_rgb(v["iris"]), font=f_body)
    label_w = draw.textlength(link_label, font=f_body)
    draw.text(
        (x + label_w + 8, y),
        "https://rosepinetheme.com",
        fill=hex_rgb(v["pine"]),
        font=f_body,
    )
    y += 40
    draw.rectangle((x, y, x + 420, y + 88), fill=hex_rgb(v["base"]))
    draw.text((x + 12, y + 10), "func greet() {", fill=hex_rgb(v["pine"]), font=f_code)
    draw.text((x + 12, y + 32), '  fmt.Println("hello")', fill=hex_rgb(v["gold"]), font=f_code)
    draw.text((x + 12, y + 54), "}", fill=hex_rgb(v["pine"]), font=f_code)
    y += 100
    draw.text((x, y), "foam · iris · gold · love · pine", fill=hex_rgb(v["foam"]), font=f_body)

    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{name}.png"
    img.save(path)
    print(f"wrote {path}")


def main() -> None:
    for name, palette in VARIANTS.items():
        render(name, palette)


if __name__ == "__main__":
    main()
