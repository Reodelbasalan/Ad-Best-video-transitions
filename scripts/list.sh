#!/usr/bin/env bash
# List every transition you can use with transition.sh
echo "⭐ Presets: flash dip whip zoom glitch iris blur   🎲 random"
echo "🎬 All ffmpeg transitions:"
ffmpeg -hide_banner -h filter=xfade 2>/dev/null | grep -oE "^\s+[a-z0-9]+\s+-?[0-9]+\s" | awk '$1!="custom"{print "  "$1}' | paste -sd" " | fold -s -w 90
