#!/usr/bin/env python3
# adjust_lightness.py (file automatically generated then properly reviewed, trimmed, and edited)
import sys, re

def parse_hex(s):
    """
    Parse a hex color string (0x/#)AARRGGBB or (0x/#)RRGGBB and return a tuple (A,R,G,B).
    """
    s = s.strip()
    # Match 8-digit hex (AARRGGBB)
    m = re.match(r'^(?:0x|#)?([0-9a-fA-F]{8})$', s)
    if m:
        hex8 = m.group(1)
        a = int(hex8[0:2],16)
        r = int(hex8[2:4],16)
        g = int(hex8[4:6],16)
        b = int(hex8[6:8],16)
        return (a, r, g, b)
    # Match 6-digit hex (RRGGBB)
    m = re.match(r'^(?:0x|#)?([0-9a-fA-F]{6})$', s)
    if m:
        hex6 = m.group(1)
        r = int(hex6[0:2],16)
        g = int(hex6[2:4],16)
        b = int(hex6[4:6],16)
        return (255, r, g, b)
    # No match
    raise ValueError(f"Unrecognized color format: {s!r}")

def to_hex(a,r,g,b):
    """
    Convert (A,R,G,B) tuple to hex string 0xAARRGGBB.
    """
    return f'0x{a:02x}{r:02x}{g:02x}{b:02x}'

def perceived_luminance(r,g,b):
    """
    Calculate the perceived luminance of the color (r,g,b).
    Uses the formula: 0.2126*R + 0.7152*G + 0.0722*B
    """
    return 0.2126*r + 0.7152*g + 0.0722*b

def lighten_toward_white(r,g,b,fraction):
    """
    Lighten the color (r,g,b) toward white (255.255.255) by the given fraction (0.0 to 1.0).
    """
    nr = round(r + (255 - r) * fraction)
    ng = round(g + (255 - g) * fraction)
    nb = round(b + (255 - b) * fraction)
    return nr, ng, nb

def darken_toward_black(r,g,b,fraction):
    """
    Darken the color (r,g,b) toward black (000.000.000) by the given fraction (0.0 to 1.0).
    """
    nr = round(r * (1 - fraction))
    ng = round(g * (1 - fraction))
    nb = round(b * (1 - fraction))
    return nr, ng, nb

def adjust_lightness(color_str, low_threshold=150.0, high_threshold=200.0, max_strength=0.5):
    """
    Adjust the lightness of the color to be within the specified luminance thresholds (not very light nor very dark).
    If the perceived luminance is below low_threshold, lighten it toward white.
    If above high_threshold, darken it toward black.
    """
    a,r,g,b = parse_hex(color_str)
    # Get luminance
    lum = perceived_luminance(r,g,b)
    # Good luminance: return
    if low_threshold <= lum <= high_threshold:
        return to_hex(a,r,g,b)
    # Too dark: lighten
    if lum < low_threshold:
        frac = min(1.0, (low_threshold - lum) / low_threshold * max_strength)
        nr,ng,nb = lighten_toward_white(r,g,b, frac)
        return to_hex(a,nr,ng,nb)
    # Too light: darken
    frac = min(1.0, (lum - high_threshold) / (255.0 - high_threshold) * max_strength) if high_threshold < 255 else max_strength
    nr,ng,nb = darken_toward_black(r,g,b, frac)
    return to_hex(a,nr,ng,nb)

def main(argv):
    if len(argv) < 2:
        print("Usage: adjust_lightness.py COLOR [LOW_THRESH] [HIGH_THRESH] [MAX_STRENGTH]", file=sys.stderr)
        print("  COLOR: color in hex format 0xAARRGGBB or #RRGGBB", file=sys.stderr)
        print("  LOW_THRESH: optional, default 150.0 - low luminance threshold (to accept darker colors, reduce the number)", file=sys.stderr)
        print("  HIGH_THRESH: optional, default 200.0 - high luminance threshold (to accept lighterer colors, increase the number)", file=sys.stderr)
        print("  MAX_STRENGTH: optional, default 0.50 - maximum adjustment strength (0.0 to 1.0)", file=sys.stderr)
        print("Examples:", file=sys.stderr)
        print("  adjust_lightness.py 0xff5f3e47", file=sys.stderr)
        print("  adjust_lightness.py #cbbbcf 120 210 0.8", file=sys.stderr)
        sys.exit(2)
    # Parse arguments
    color = argv[1]
    low = float(argv[2]) if len(argv) > 2 else 150.0
    high = float(argv[3]) if len(argv) > 3 else 200.0
    if high < low:
        print("ERROR: HIGH_THRESH must be greater than or equal to LOW_THRESH", file=sys.stderr)
        sys.exit(1)
    max_strength = float(argv[4]) if len(argv) > 4 else 0.50
    try:
        # Adjust lightness
        out = adjust_lightness(color, low_threshold=low, high_threshold=high, max_strength=max_strength)
        print(out)
    except Exception as e:
        print("ERROR:", e, file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main(sys.argv)
