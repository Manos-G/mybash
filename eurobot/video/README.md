# Eurobot 2027 rules video

Renders `../eurobot2027-brainrot.html` as a 1080×1920 MP4 (Peter & Stewie, captions, gameplay background,
and screenshots from the rulebook PDF when a line talks about a figure or a points table).
The script, the characters and the gameplay code come from that page, so edit the page first.

## Needs

- `ffmpeg`, Node with Playwright + Chromium, Python 3 with `numpy` and `piper-tts`
- Piper voices `en-us-ryan-high` (Peter) and `en-gb-alan-low` (Stewie), from
  `https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-<name>.tar.gz`, extracted into `<voices>/<name>/`
- `fonts/ArchivoBlack.ttf` and `fonts/Bungee.ttf` (Google Fonts)
- The rules PDF (`Eurobot2027_Rules_EN.pdf`, OFFICIAL 1.0) and `pdftoppm` (poppler-utils), plus Pillow

## Steps

Run in this folder:

```bash
node extract.js ../eurobot2027-brainrot.html lines.json   # script -> lines.json
python3 audio.py <voices>                                  # voices -> full.wav + timeline.json
python3 - <<'PY'                                           # character SVGs + gameplay code -> peter.svg, stewie.svg, game.js
import re
h = open('../eurobot2027-brainrot.html').read()
s = [re.sub(r'<ellipse class="mouth"[^>]*/>', '', x).replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" ', 1)
     for x in re.findall(r'<svg viewBox="0 0 200 2[25]0">.*?</svg>', h, re.S)]
open('peter.svg', 'w').write(s[0]); open('stewie.svg', 'w').write(s[1])
open('game.js', 'w').write(re.search(r'(const ZMAX = 30.*?\n};\n\n/\* ---- Block parkour ---- \*/\nconst blocks = \{.*?\n\};\n)', h, re.S).group(1))
PY
mkdir -p pages shots && pdftoppm -r 200 -png Eurobot2027_Rules_EN.pdf pages/p
python3 crops.py                                           # figures + points snippets -> shots/
node capture.js test                                       # optional: a few still frames
node capture.js full                                       # -> eurobot2027-rules-v2.mp4
```

The crop boxes in `crops.py` are in 100-dpi page units and fit the OFFICIAL 1.0 PDF.
If a new rules version moves the figures, fix the boxes. `capture.js` maps each screenshot to a line
by caption text and stops with an error if a line no longer matches.
