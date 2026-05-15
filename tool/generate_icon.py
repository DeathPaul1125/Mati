"""Generate modern rocket icon for Juegos Kids app."""
from PIL import Image, ImageDraw, ImageFilter
import math
import os

SIZE = 1024
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets")


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def radial_gradient(size, inner, outer, center=None):
    img = Image.new("RGB", (size, size), outer)
    px = img.load()
    cx, cy = center if center else (size / 2, size / 2)
    max_d = math.hypot(max(cx, size - cx), max(cy, size - cy))
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy) / max_d
            d = min(1.0, d)
            t = d ** 1.4
            px[x, y] = lerp(inner, outer, t)
    return img


def linear_gradient(size, top, bottom):
    img = Image.new("RGB", (size, size), top)
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        c = lerp(top, bottom, t)
        for x in range(size):
            px[x, y] = c
    return img


def rounded_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return m


def draw_star(draw, cx, cy, r_out, r_in, points=5, fill=(255, 255, 255, 255), rotation=-math.pi / 2):
    pts = []
    for i in range(points * 2):
        r = r_out if i % 2 == 0 else r_in
        ang = rotation + i * math.pi / points
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    draw.polygon(pts, fill=fill)


def add_soft_shadow(layer, offset=(0, 18), blur=22, opacity=110):
    """Return a shadow image (RGBA) computed from alpha of layer."""
    alpha = layer.split()[-1]
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    shadow_alpha = alpha.point(lambda a: int(a * opacity / 255))
    shadow_full = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    shadow_full.putalpha(shadow_alpha)
    shadow_full = shadow_full.filter(ImageFilter.GaussianBlur(blur))
    out = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    out.paste(shadow_full, offset, shadow_full)
    return out


def draw_rocket(canvas_size, scale=1.0, offset=(0, 0)):
    """Draw a chubby cute rocket facing up, on a transparent canvas."""
    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))

    cx = canvas_size / 2 + offset[0]
    cy = canvas_size / 2 + offset[1]

    # ----- Geometry (in unscaled px) -----
    body_w = 460
    body_h = 480       # capsule height (without nose)
    nose_h = 200
    cone_overhang = 0  # cone sits flush on top of body
    flame_h = 240
    fin_w = 150        # how far fins extend sideways from body
    fin_h = 200

    # Apply scale
    def s(v): return v * scale

    body_w = s(body_w)
    body_h = s(body_h)
    nose_h = s(nose_h)
    flame_h = s(flame_h)
    fin_w = s(fin_w)
    fin_h = s(fin_h)

    # Vertical layout — center the rocket capsule on cy
    body_top = cy - body_h / 2
    body_bottom = cy + body_h / 2
    cone_top = body_top - nose_h
    flame_top = body_bottom - s(20)
    flame_bottom = flame_top + flame_h

    body_left = cx - body_w / 2
    body_right = cx + body_w / 2

    # Helper to draw on the current image (we'll re-create draw after composites)
    d = ImageDraw.Draw(img)

    # ===== 1. FLAME (behind body) =====
    # outer flame — orange, wavy
    outer = [
        (cx - s(110), flame_top),
        (cx - s(140), flame_top + s(90)),
        (cx - s(70), flame_top + s(150)),
        (cx - s(95), flame_top + s(200)),
        (cx, flame_bottom),
        (cx + s(95), flame_top + s(200)),
        (cx + s(70), flame_top + s(150)),
        (cx + s(140), flame_top + s(90)),
        (cx + s(110), flame_top),
    ]
    d.polygon(outer, fill=(255, 138, 36, 255))

    # mid flame — yellow
    mid = [
        (cx - s(75), flame_top),
        (cx - s(95), flame_top + s(80)),
        (cx - s(45), flame_top + s(140)),
        (cx, flame_bottom - s(40)),
        (cx + s(45), flame_top + s(140)),
        (cx + s(95), flame_top + s(80)),
        (cx + s(75), flame_top),
    ]
    d.polygon(mid, fill=(255, 213, 79, 255))

    # core — pale cream
    core = [
        (cx - s(38), flame_top),
        (cx - s(45), flame_top + s(70)),
        (cx, flame_bottom - s(90)),
        (cx + s(45), flame_top + s(70)),
        (cx + s(38), flame_top),
    ]
    d.polygon(core, fill=(255, 248, 220, 255))

    # ===== 2. FINS (behind body) =====
    fin_color = (240, 78, 110, 255)
    fin_dark = (200, 50, 85, 255)

    # left fin
    left_fin = [
        (body_left + s(20), body_bottom - fin_h),
        (body_left + s(40), body_bottom - s(20)),
        (body_left - fin_w + s(20), body_bottom + s(40)),
        (body_left - fin_w, body_bottom + s(10)),
    ]
    d.polygon(left_fin, fill=fin_color)
    # left fin inner shadow (bottom edge darker)
    d.polygon([
        (body_left + s(40), body_bottom - s(20)),
        (body_left - fin_w + s(20), body_bottom + s(40)),
        (body_left - fin_w / 3, body_bottom + s(20)),
    ], fill=fin_dark)

    # right fin (mirrored)
    right_fin = [
        (body_right - s(20), body_bottom - fin_h),
        (body_right - s(40), body_bottom - s(20)),
        (body_right + fin_w - s(20), body_bottom + s(40)),
        (body_right + fin_w, body_bottom + s(10)),
    ]
    d.polygon(right_fin, fill=fin_color)
    d.polygon([
        (body_right - s(40), body_bottom - s(20)),
        (body_right + fin_w - s(20), body_bottom + s(40)),
        (body_right + fin_w / 3, body_bottom + s(20)),
    ], fill=fin_dark)

    # ===== 3. BODY (rounded capsule, white) =====
    body_radius = s(80)
    d.rounded_rectangle(
        (body_left, body_top, body_right, body_bottom),
        radius=int(body_radius),
        fill=(250, 252, 255, 255),
    )

    # body subtle right-side shadow (depth)
    shadow_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_layer)
    sd.rounded_rectangle(
        (body_right - s(90), body_top, body_right, body_bottom),
        radius=int(body_radius),
        fill=(80, 100, 140, 45),
    )
    # mask to body shape so shadow doesn't bleed
    body_mask = Image.new("L", img.size, 0)
    bm = ImageDraw.Draw(body_mask)
    bm.rounded_rectangle(
        (body_left, body_top, body_right, body_bottom),
        radius=int(body_radius), fill=255
    )
    shadow_clipped = Image.new("RGBA", img.size, (0, 0, 0, 0))
    shadow_clipped.paste(shadow_layer, (0, 0), body_mask)
    img = Image.alpha_composite(img, shadow_clipped)
    d = ImageDraw.Draw(img)

    # ===== 4. NOSE CONE =====
    cone_color = (240, 78, 110, 255)
    cone_dark = (200, 50, 85, 255)
    nose_pts = [
        (cx, cone_top),
        (body_right - s(10), body_top + s(40)),
        (body_left + s(10), body_top + s(40)),
    ]
    d.polygon(nose_pts, fill=cone_color)
    # cone shadow on right side
    d.polygon([
        (cx, cone_top),
        (body_right - s(10), body_top + s(40)),
        (cx + s(30), body_top + s(40)),
    ], fill=cone_dark)

    # red band separating cone from body
    d.rounded_rectangle(
        (body_left, body_top + s(25), body_right, body_top + s(75)),
        radius=int(s(20)),
        fill=cone_color,
    )

    # ===== 5. WINDOW (porthole with kawaii face) =====
    win_r = s(135)
    win_cx, win_cy = cx, body_top + s(75) + s(170)

    # outer ring (yellow)
    d.ellipse(
        (win_cx - win_r, win_cy - win_r, win_cx + win_r, win_cy + win_r),
        fill=(255, 196, 80, 255),
    )
    # inner glass
    inner_r = win_r - s(22)
    d.ellipse(
        (win_cx - inner_r, win_cy - inner_r, win_cx + inner_r, win_cy + inner_r),
        fill=(140, 215, 255, 255),
    )
    # darker glass bottom
    d.pieslice(
        (win_cx - inner_r, win_cy - inner_r, win_cx + inner_r, win_cy + inner_r),
        start=15, end=165,
        fill=(95, 180, 235, 255),
    )
    # glass highlight (top-left)
    d.pieslice(
        (win_cx - inner_r + s(8), win_cy - inner_r + s(8),
         win_cx + inner_r - s(8), win_cy + inner_r - s(8)),
        start=200, end=260,
        fill=(220, 240, 255, 220),
    )

    # ----- kawaii face -----
    eye_r = s(22)
    eye_off_x = s(45)
    eye_off_y = s(-12)
    for sx in (-1, 1):
        ex, ey = win_cx + sx * eye_off_x, win_cy + eye_off_y
        d.ellipse((ex - eye_r, ey - eye_r, ex + eye_r, ey + eye_r),
                  fill=(40, 45, 70, 255))
        # sparkle
        sp = s(8)
        d.ellipse((ex + s(4), ey - s(10), ex + s(4) + sp, ey - s(10) + sp),
                  fill=(255, 255, 255, 255))

    # cheeks
    cheek_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    cl = ImageDraw.Draw(cheek_layer)
    cheek_r = s(18)
    for sx in (-1, 1):
        cxp = win_cx + sx * s(78)
        cyp = win_cy + s(22)
        cl.ellipse((cxp - cheek_r, cyp - cheek_r, cxp + cheek_r, cyp + cheek_r),
                   fill=(255, 140, 165, 200))
    cheek_layer = cheek_layer.filter(ImageFilter.GaussianBlur(3))
    img = Image.alpha_composite(img, cheek_layer)
    d = ImageDraw.Draw(img)

    # smile
    smile_w = s(60)
    smile_y = win_cy + s(36)
    d.arc(
        (win_cx - smile_w, smile_y - s(15),
         win_cx + smile_w, smile_y + s(35)),
        start=15, end=165,
        fill=(40, 45, 70, 255),
        width=int(s(8)),
    )

    # ===== 6. RIVETS + bottom band =====
    rivet_r = s(7)
    rivet_y = body_bottom - s(35)
    for ox in (s(-130), s(-70), 0, s(70), s(130)):
        d.ellipse((cx + ox - rivet_r, rivet_y - rivet_r,
                   cx + ox + rivet_r, rivet_y + rivet_r),
                  fill=(190, 200, 220, 255))

    return img


def add_stars(img, count=12, seed=42):
    import random
    rng = random.Random(seed)
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    w, h = img.size
    for _ in range(count):
        x = rng.randint(60, w - 60)
        y = rng.randint(60, h - 60)
        # avoid center area where rocket is
        if abs(x - w / 2) < 250 and abs(y - h / 2) < 320:
            continue
        r = rng.choice([8, 10, 12, 14, 18])
        opacity = rng.randint(160, 230)
        draw_star(d, x, y, r, r * 0.45, fill=(255, 255, 255, opacity))
    # small sparkle dots
    for _ in range(20):
        x = rng.randint(40, w - 40)
        y = rng.randint(40, h - 40)
        if abs(x - w / 2) < 220 and abs(y - h / 2) < 280:
            continue
        r = rng.choice([3, 4, 5])
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 255, 255, 200))
    return Image.alpha_composite(img, overlay)


def make_main_icon():
    # cosmic gradient background: deep indigo -> magenta-ish purple
    bg = linear_gradient(SIZE, (76, 65, 175), (188, 80, 200))  # indigo -> magenta
    # soft radial glow in upper-center
    glow = radial_gradient(SIZE, (255, 200, 230), (76, 65, 175), center=(SIZE / 2, SIZE * 0.35))
    bg = Image.blend(bg, glow, 0.35)
    bg = bg.convert("RGBA")

    # add stars to background first (behind rocket)
    bg_with_stars = add_stars(bg, count=14, seed=7)

    # rocket layer
    rocket = draw_rocket(SIZE, scale=1.0, offset=(0, -20))

    # rocket shadow under the flame for grounding
    shadow = add_soft_shadow(rocket, offset=(0, 30), blur=30, opacity=80)
    composed = Image.alpha_composite(bg_with_stars, shadow)
    composed = Image.alpha_composite(composed, rocket)

    # Apply rounded corners (iOS-style squircle approximation)
    mask = rounded_mask(SIZE, radius=int(SIZE * 0.22))
    final = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    final.paste(composed, (0, 0), mask)
    return final


def make_foreground():
    """Transparent foreground for Android adaptive icon. Rocket must fit in
    66% safe zone (center ~676px of 1024)."""
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    rocket = draw_rocket(SIZE, scale=0.72, offset=(0, -10))
    fg = Image.alpha_composite(fg, rocket)
    return fg


def make_background():
    """Solid/gradient background for adaptive icon (no rocket)."""
    bg = linear_gradient(SIZE, (76, 65, 175), (188, 80, 200))
    glow = radial_gradient(SIZE, (255, 200, 230), (76, 65, 175), center=(SIZE / 2, SIZE * 0.35))
    bg = Image.blend(bg, glow, 0.35).convert("RGBA")
    bg = add_stars(bg, count=10, seed=13)
    return bg


if __name__ == "__main__":
    print("Generating icon.png...")
    main = make_main_icon()
    main.save(os.path.join(OUT_DIR, "icon.png"))
    print("Generating icon_fg.png...")
    fg = make_foreground()
    fg.save(os.path.join(OUT_DIR, "icon_fg.png"))
    print("Generating icon_bg.png...")
    bg = make_background()
    bg.save(os.path.join(OUT_DIR, "icon_bg.png"))
    print("Done.")
