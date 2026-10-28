"""Cut figures and rule snippets out of the rendered PDF pages (200 dpi; boxes are in 100-dpi page units)."""
import json
from PIL import Image
# name: (pdf page, x0, y0, x1, y1, label)
BOX = {
 "fig1":     (5,  100, 505, 680, 800, "RULES p.4 · FIGURE 1"),
 "note":     (5,   75, 395, 715, 487, "RULES p.4"),
 "fig2":     (7,   68, 205, 690, 615, "RULES p.6 · FIGURE 2"),
 "fig3":     (8,   80, 228, 700, 515, "RULES p.7 · FIGURE 3"),
 "fig4":     (9,   80, 630, 705, 915, "RULES p.8 · FIGURE 4"),
 "fig5":     (10, 200,  68, 578, 385, "RULES p.9 · FIGURE 5"),
 "fig6":     (12, 200,  85, 578, 288, "RULES p.11 · FIGURE 6"),
 "wall":     (12,  72, 446, 268, 682, "RULES p.11 · FIGURE 7a"),
 "tower":    (12, 265, 345, 462, 682, "RULES p.11 · FIGURE 7b"),
 "gate":     (12, 458, 400, 686, 682, "RULES p.11 · FIGURE 7c"),
 "e1pts":    (11,  75, 825, 520, 950, "RULES p.10 · E.1.c"),
 "e1steal":  (11,  85, 755, 712, 808, "RULES p.10 · E.1.b"),
 "grailsize":(13,  90, 415, 712, 450, "RULES p.12 · E.2.b"),
 "levels":   (13,  90, 457, 712, 596, "RULES p.12 · E.2.b"),
 "e2pts":    (13,  75, 762, 420, 836, "RULES p.12 · E.2.c"),
 "e3pts":    (14,  75, 425, 560, 499, "RULES p.13 · E.3.c"),
 "e4phase":  (15,  90, 530, 712, 570, "RULES p.14 · E.4.b"),
 "e4moat":   (15,  90, 612, 712, 712, "RULES p.14 · E.4.b"),
 "e4pts":    (15,  75, 795, 600, 922, "RULES p.14 · E.4.c"),
 "fpts":     (16,  70,  72, 712, 610, "RULES p.15 · F. POINTS"),
}
meta = {}
for name, (pg, x0, y0, x1, y1, label) in BOX.items():
    im = Image.open(f"pages/p-{pg:02d}.png").convert("RGB").crop((x0 * 2, y0 * 2, x1 * 2, y1 * 2))
    im.save(f"shots/{name}.png")
    meta[name] = {"label": label, "w": im.width, "h": im.height}
json.dump(meta, open("shots/meta.json", "w"), indent=1)
# contact sheet for a visual check
thumbs = [Image.open(f"shots/{n}.png") for n in BOX]
W = 1600; cols = 4; cw = W // cols
rows = []
for i in range(0, len(thumbs), cols):
    row = [t.resize((cw - 10, int(t.height * (cw - 10) / t.width))) for t in thumbs[i:i + cols]]
    rows.append(row)
H = sum(max(t.height for t in r) + 10 for r in rows)
sheet = Image.new("RGB", (W, H), (60, 60, 60)); y = 0
for r in rows:
    for j, t in enumerate(r): sheet.paste(t, (j * cw + 5, y + 5))
    y += max(t.height for t in r) + 10
sheet.save("shots_sheet.jpg", quality=80)
print(len(BOX), "crops")
