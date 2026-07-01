#!/usr/bin/env python3
"""Compose premium brand containers around official wallet marks (no redraw)."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ICONS = ROOT / "assets" / "icons"

# Raw marks — geometry preserved; only composited into containers.
NAVY_MARK = ICONS / "wallet_mark_navy.png"
WHITE_MARK = ICONS / "wallet_mark_white.png"

SIZE = 1024
# 30px corner radius at 128pt reference → scaled to output size.
CORNER_RADIUS = int(30 * (SIZE / 128))
CONTAINER_INSET = int(SIZE * 0.08)
LOGO_PADDING_RATIO = 0.22
BORDER_COLOR = (0xE5, 0xE7, 0xEB, 255)
BORDER_WIDTH = max(2, int(1.5 * (SIZE / 128)))
BG_LIGHT = (0xFF, 0xFF, 0xFF, 255)
BG_DARK = (0x10, 0x2A, 0x5C, 255)


def _rounded_rect_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def _fit_logo(mark: Image.Image, target: int) -> Image.Image:
    mark = mark.convert("RGBA")
    bbox = mark.getbbox()
    if bbox:
        mark = mark.crop(bbox)
    mark.thumbnail((target, target), Image.Resampling.LANCZOS)
    return mark


def _compose(
    *,
    bg_color: tuple[int, int, int, int],
    mark: Image.Image,
    border: bool,
) -> Image.Image:
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    box = SIZE - 2 * CONTAINER_INSET
    radius = CORNER_RADIUS
    mask = _rounded_rect_mask(box, radius)

    container = Image.new("RGBA", (box, box), bg_color)
    container.putalpha(mask)

    if border:
        border_layer = Image.new("RGBA", (box, box), (0, 0, 0, 0))
        bdraw = ImageDraw.Draw(border_layer)
        bdraw.rounded_rectangle(
            (
                BORDER_WIDTH // 2,
                BORDER_WIDTH // 2,
                box - BORDER_WIDTH // 2 - 1,
                box - BORDER_WIDTH // 2 - 1,
            ),
            radius=max(1, radius - BORDER_WIDTH // 2),
            outline=BORDER_COLOR,
            width=BORDER_WIDTH,
        )
        container = Image.alpha_composite(container, border_layer)

    shadow = Image.new("RGBA", (box, box), (0, 0, 0, 0))
    shadow_fill = Image.new("RGBA", (box, box), (0, 0, 0, 38))
    shadow = Image.composite(shadow_fill, shadow, mask)
    blur = max(8, int(12 * (SIZE / 1024)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    offset = max(4, int(6 * (SIZE / 1024)))
    canvas.alpha_composite(shadow, (CONTAINER_INSET + offset, CONTAINER_INSET + offset))
    canvas.alpha_composite(container, (CONTAINER_INSET, CONTAINER_INSET))

    inner = box - int(box * LOGO_PADDING_RATIO * 2)
    logo = _fit_logo(mark, inner)
    lx = CONTAINER_INSET + (box - logo.width) // 2
    ly = CONTAINER_INSET + (box - logo.height) // 2
    canvas.alpha_composite(logo, (lx, ly))
    return canvas


def main() -> None:
    if not NAVY_MARK.is_file() or not WHITE_MARK.is_file():
        raise SystemExit(
            f"Missing raw marks. Expected:\n  {NAVY_MARK}\n  {WHITE_MARK}"
        )

    navy = Image.open(NAVY_MARK)
    white = Image.open(WHITE_MARK)

    light = _compose(bg_color=BG_LIGHT, mark=navy, border=True)
    dark = _compose(bg_color=BG_DARK, mark=white, border=False)

    light.save(ICONS / "logo_light.png", optimize=True)
    dark.save(ICONS / "logo_dark.png", optimize=True)
    dark.save(ICONS / "app_icon.png", optimize=True)

    print(f"Generated brand icons in {ICONS}")
    print("  logo_light.png  — white #FFFFFF container, navy mark, border #E5E7EB")
    print("  logo_dark.png   — navy #102A5C container, white mark")
    print("  app_icon.png    — dark brand (1024px)")


if __name__ == "__main__":
    main()
