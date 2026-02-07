#!/bin/bash
set -euo pipefail

OUT="$HOME/.config/background-blur"
CACHE="$HOME/.cache/background.hash"

# Get background path
SCHEMA=org.gnome.desktop.background
KEY=picture-uri

THEME="org.gnome.desktop.interface color-scheme"

gsettings get $THEME | grep -q dark && \
  KEY=picture-uri-dark

URI=$(gsettings get $SCHEMA $KEY)
URI=${URI//\'/}
URI=${URI#file://}

# Check for existence
[[ -f "$URI" && -s "$URI" ]] || exit 0

NEW_HASH=$(sha256sum "$URI" | cut -d' ' -f1)
OLD_HASH=$(cat "$CACHE" 2>/dev/null || true)

if [ "$NEW_HASH" == "$OLD_HASH" ]; then
  # Nothing changed → do nothing
  [[ -f "$OUT" ]] && exit 0

else
  # Save new hash
  echo "$NEW_HASH" > "$CACHE"
fi

# Blur the image
magick "$URI" \
  -blur 0x16 \
  -resize 1920x1080\> \
  -brightness-contrast -15x-20 \
  "$OUT"
