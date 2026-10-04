#!/bin/bash
# OmaRGB theme sync (headless): paint the theme accent on all RGB hardware
# after every theme change. Runs without the bar widget via theme-set.d.
set -euo pipefail

THEME_NAME="${1:-}"
BRIDGE="$HOME/.config/omarchy/plugins/io.github.ilkaydnc.omargb/bridge/openrgb_bridge.py"

# Resolve theme dir: `omarchy theme dir` returns the display-case path, which
# may not exist on disk (themes live lowercase). Prefer an existing dir.
THEME_DIR="$(omarchy theme dir "$THEME_NAME" 2>/dev/null || true)"
if [[ ! -f "$THEME_DIR/colors.toml" ]]; then
  LOW="${THEME_NAME,,}"
  if [[ -f "$HOME/.config/omarchy/themes/$LOW/colors.toml" ]]; then
    THEME_DIR="$HOME/.config/omarchy/themes/$LOW"
  else
    THEME_DIR="/usr/share/omarchy/themes/$LOW"
  fi
fi
COLORS="$THEME_DIR/colors.toml"

ACCENT="$(grep -E '^\s*accent\s*=' "$COLORS" 2>/dev/null | head -1 | grep -oE '#[0-9a-fA-F]{6}' || true)"
if [[ -z "$ACCENT" ]]; then
  exit 0
fi
# Vivid lift mirroring the plugin's Model.ledAccent exactly (HSV: keep hue,
# S>=70 V>=90, neutrals with S<5 pass through).
VIVID="$(python3 - "$ACCENT" <<'EOF'
import colorsys, sys
h = sys.argv[1].lstrip('#')
r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
mx, mn = max(r, g, b), min(r, g, b)
d = mx - mn
if d == 0:
    hh = 0.0
elif mx == r:
    hh = ((g - b) / d) % 6
elif mx == g:
    hh = (b - r) / d + 2
else:
    hh = (r - g) / d + 4
hh = (hh * 60) % 360
ss = 0.0 if mx == 0 else d / mx
vv = mx
if round(ss * 100) < 5:
    print('#' + h.lower())
else:
    ss, vv = max(ss, 0.70), max(vv, 0.90)
    c = vv * ss
    x = c * (1 - abs((hh / 60) % 2 - 1))
    m = vv - c
    if hh < 60: rr, gg, bb = c, x, 0.0
    elif hh < 120: rr, gg, bb = x, c, 0.0
    elif hh < 180: rr, gg, bb = 0.0, c, x
    elif hh < 240: rr, gg, bb = 0.0, x, c
    elif hh < 300: rr, gg, bb = x, 0.0, c
    else: rr, gg, bb = c, 0.0, x
    print('#%02x%02x%02x' % (round((rr + m) * 255), round((gg + m) * 255), round((bb + m) * 255)))
EOF
)"

python3 "$BRIDGE" --once --cmd "{\"op\":\"set_all\",\"color\":\"$VIVID\"}" >/dev/null 2>&1 || true
