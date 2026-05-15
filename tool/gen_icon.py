"""Genera el icono de la app (1024x1024) usando Pillow."""
from PIL import Image, ImageDraw, ImageFilter
import math
import os

SIZE = 1024
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets")
os.makedirs(OUT_DIR, exist_ok=True)


def make_gradient(size, top, bottom):
    img = Image.new("RGB", (size, size), top)
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        for x in range(size):
            px[x, y] = (r, g, b)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


def star_polygon(cx, cy, r_out, r_in, points=5, rotation=-math.pi / 2):
    verts = []
    for i in range(points * 2):
        ang = rotation + i * math.pi / points
        r = r_out if i % 2 == 0 else r_in
        verts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return verts


def draw_star_face(draw, cx, cy, r_out, fill, outline=None):
    pts = star_polygon(cx, cy, r_out, r_out * 0.45)
    draw.polygon(pts, fill=fill, outline=outline, width=8 if outline else 0)
    eye_r = r_out * 0.07
    eye_dx = r_out * 0.20
    eye_dy = -r_out * 0.05
    for sign in (-1, 1):
        ex = cx + sign * eye_dx
        ey = cy + eye_dy
        draw.ellipse(
            (ex - eye_r, ey - eye_r, ex + eye_r, ey + eye_r),
            fill=(40, 40, 60),
        )
        gleam_r = eye_r * 0.35
        draw.ellipse(
            (ex - gleam_r + eye_r * 0.3, ey - gleam_r - eye_r * 0.2,
             ex + gleam_r + eye_r * 0.3, ey + gleam_r - eye_r * 0.2),
            fill=(255, 255, 255),
        )
    mouth_w = r_out * 0.34
    mouth_h = r_out * 0.22
    my = cy + r_out * 0.12
    draw.arc(
        (cx - mouth_w, my - mouth_h, cx + mouth_w, my + mouth_h),
        start=10, end=170, fill=(60, 30, 30), width=int(r_out * 0.05),
    )
    cheek_r = r_out * 0.08
    for sign in (-1, 1):
        cxh = cx + sign * r_out * 0.32
        cyh = cy + r_out * 0.10
        draw.ellipse(
            (cxh - cheek_r, cyh - cheek_r, cxh + cheek_r, cyh + cheek_r),
            fill=(255, 150, 170, 200),
        )


def main():
    img = make_gradient(SIZE, (90, 145, 230), (170, 100, 220)).convert("RGBA")

    overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)

    deco = [
        (180, 220, 38, (255, 255, 255, 60)),
        (820, 180, 28, (255, 255, 255, 80)),
        (140, 820, 50, (255, 255, 255, 55)),
        (870, 860, 30, (255, 255, 255, 70)),
        (760, 520, 22, (255, 255, 255, 90)),
        (260, 540, 20, (255, 255, 255, 90)),
    ]
    for cx, cy, r, fill in deco:
        pts = star_polygon(cx, cy, r, r * 0.45)
        od.polygon(pts, fill=fill)

    od.ellipse((SIZE * 0.08, SIZE * 0.08, SIZE * 0.92, SIZE * 0.92),
               fill=(255, 255, 255, 28))

    draw_star_face(
        od,
        cx=SIZE / 2,
        cy=SIZE / 2,
        r_out=SIZE * 0.34,
        fill=(255, 210, 60, 255),
        outline=(230, 160, 30, 255),
    )

    img = Image.alpha_composite(img, overlay)

    mask = rounded_mask(SIZE, radius=int(SIZE * 0.22))
    rounded = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    rounded.paste(img, (0, 0), mask=mask)

    out_main = os.path.join(OUT_DIR, "icon.png")
    rounded.save(out_main, format="PNG")
    print("Saved:", out_main)

    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fg)
    draw_star_face(
        fd,
        cx=SIZE / 2,
        cy=SIZE / 2,
        r_out=SIZE * 0.28,
        fill=(255, 210, 60, 255),
        outline=(230, 160, 30, 255),
    )
    out_fg = os.path.join(OUT_DIR, "icon_fg.png")
    fg.save(out_fg, format="PNG")
    print("Saved:", out_fg)

    bg = make_gradient(SIZE, (90, 145, 230), (170, 100, 220)).convert("RGBA")
    out_bg = os.path.join(OUT_DIR, "icon_bg.png")
    bg.save(out_bg, format="PNG")
    print("Saved:", out_bg)


if __name__ == "__main__":
    main()
