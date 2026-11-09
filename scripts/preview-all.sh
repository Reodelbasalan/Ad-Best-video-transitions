#!/usr/bin/env bash
# Make a short preview video of EVERY transition so you can pick your favorite.
# Usage: ./scripts/preview-all.sh [clipA.mp4 clipB.mp4]   (uses test colors if none given)
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p output/previews samples
A=${1:-samples/a.mp4}; B=${2:-samples/b.mp4}
if [[ ! -f $A || ! -f $B ]]; then
  ffmpeg -y -loglevel error -f lavfi -i "testsrc2=s=640x360:r=30:d=2" samples/a.mp4
  ffmpeg -y -loglevel error -f lavfi -i "smptebars=s=640x360:r=30:d=2" samples/b.mp4
  A=samples/a.mp4; B=samples/b.mp4
fi
for t in $(ffmpeg -hide_banner -h filter=xfade 2>/dev/null | grep -oE "^\s+[a-z0-9]+\s+-?[0-9]+\s" | awk '$1!="custom"{print $1}'); do
  ./scripts/transition.sh -t "$t" -d 1 -r 640x360 -o "output/previews/$t.mp4" "$A" "$B" >/dev/null && echo "  $t"
done
echo "✅ Previews saved in output/previews/"
