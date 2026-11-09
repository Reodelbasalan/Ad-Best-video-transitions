#!/usr/bin/env bash
# Join videos/photos with a transition between each one.
# Usage: ./scripts/transition.sh [options] -o OUT.mp4 clip1 clip2 [clip3 ...]
#
# Options:
#   -t NAME     transition name or preset (default: fade). "random" = different every cut.
#               Run ./scripts/list.sh to see all names.
#   -d SECONDS  transition length (default: 0.6, presets have their own)
#   -r WxH      output size (default: 1920x1080; TikTok/Reels: 1080x1920)
#   -f FPS      frames per second (default: 30)
#   -p SECONDS  how long each photo shows (default: 3)
#   -m FILE     background music (loops if short, fades out at the end)
#   -v VOLUME   music volume 0.0-1.0 (default: 0.5)
#   -o FILE     output file (required)
set -euo pipefail

TRANS="fade"; DUR=""; RES="1920x1080"; FPS="30"; OUT=""; PHOTO="3"; MUSIC=""; MVOL="0.5"
die() { echo "❌ $*" >&2; exit 1; }
usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
while getopts "t:d:r:f:o:p:m:v:h" o; do
  case $o in
    t) TRANS=$OPTARG;; d) DUR=$OPTARG;; r) RES=$OPTARG;; f) FPS=$OPTARG;; o) OUT=$OPTARG;;
    p) PHOTO=$OPTARG;; m) MUSIC=$OPTARG;; v) MVOL=$OPTARG;; *) usage;;
  esac
done
shift $((OPTIND-1))
[[ -z "$OUT" || $# -lt 2 ]] && usage

command -v ffmpeg >/dev/null && command -v ffprobe >/dev/null || die "Walang FFmpeg. I-install muna: https://ffmpeg.org/download.html"
[[ "$RES" =~ ^[0-9]+x[0-9]+$ ]] || die "Mali ang -r '$RES'. Halimbawa: 1920x1080"
for c in "$@"; do [[ -f "$c" ]] || die "Hindi makita ang file: $c"; done
[[ -z "$MUSIC" || -f "$MUSIC" ]] || die "Hindi makita ang music file: $MUSIC"

XFADES=$(ffmpeg -hide_banner -h filter=xfade 2>/dev/null | grep -oE "^\s+[a-z0-9]+\s+-?[0-9]+\s" | awk '$1!="custom"{print $1}')

# Friendly presets (editor-style names -> ffmpeg xfade + default duration)
resolve() {
  case "$1" in
    flash)      echo "fadewhite ${DUR:-0.3}";;
    dip)        echo "fadeblack ${DUR:-0.8}";;
    whip|swipe) echo "smoothleft ${DUR:-0.35}";;
    zoom)       echo "zoomin ${DUR:-0.5}";;
    glitch)     echo "pixelize ${DUR:-0.4}";;
    iris)       echo "circleopen ${DUR:-0.6}";;
    blur)       echo "hblur ${DUR:-0.6}";;
    *) grep -qx "$1" <<<"$XFADES" || die "Walang transition na '$1'. Tingnan: ./scripts/list.sh"
       echo "$1 ${DUR:-0.6}";;
  esac
}
POOL=(flash whip zoom glitch iris blur fade slideleft slideup circlecrop radial squeezeh diagtl coverleft revealright dissolve)

W=${RES%x*}; H=${RES#*x}
is_image() { [[ "${1,,}" =~ \.(jpe?g|png|webp|bmp|gif|tiff?)$ ]]; }
has_audio() { [[ -n $(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$1" 2>/dev/null) ]]; }
dur_of() {
  if is_image "$1"; then echo "$PHOTO"; return; fi
  local d; d=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$1" 2>/dev/null || true)
  [[ "$d" =~ ^[0-9.]+$ ]] || die "Hindi mabasa ang haba ng video: $1"
  echo "$d"
}

inputs=(); fc=""; durs=(); i=0
for c in "$@"; do
  d=$(dur_of "$c"); durs+=("$d")
  if is_image "$c"; then inputs+=(-loop 1 -framerate "$FPS" -t "$d" -i "$c"); else inputs+=(-i "$c"); fi
  # same size/fps/format for every clip (required by xfade); keeps aspect ratio with black bars
  fc+="[$i:v]scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=${FPS},format=yuv420p,trim=duration=${d},setpts=PTS-STARTPTS,settb=AVTB[v$i];"
  # every clip gets an audio track (silence if it has none) so audio is never lost
  if ! is_image "$c" && has_audio "$c"; then
    fc+="[$i:a]aformat=sample_rates=48000:channel_layouts=stereo,apad,atrim=duration=${d},asetpts=PTS-STARTPTS[a$i];"
  else
    fc+="anullsrc=r=48000:cl=stereo,atrim=duration=${d}[a$i];"
  fi
  i=$((i+1))
done

n=$#; offset=0; vprev="v0"; aprev="a0"; used=()
for ((k=1; k<n; k++)); do
  name=$TRANS; [[ "$TRANS" == "random" ]] && name=${POOL[RANDOM % ${#POOL[@]}]}
  read -r xf td < <(resolve "$name")
  # transition can't be longer than 45% of either neighbouring clip
  td=$(awk -v t="$td" -v a="${durs[k-1]}" -v b="${durs[k]}" 'BEGIN{m=(a<b?a:b)*0.45; printf "%.3f", (t<m?t:m)}')
  offset=$(awk -v o="$offset" -v d="${durs[k-1]}" -v t="$td" 'BEGIN{printf "%.3f", o + d - t}')
  fc+="[$vprev][v$k]xfade=transition=${xf}:duration=${td}:offset=${offset}[vx$k];"
  fc+="[$aprev][a$k]acrossfade=d=${td}:c1=tri:c2=tri[ax$k];"
  vprev="vx$k"; aprev="ax$k"; used+=("$name")
  offset=$(awk -v o="$offset" -v t="$td" 'BEGIN{printf "%.3f", o + t}')
  durs[k]=$(awk -v d="${durs[k]}" -v t="$td" 'BEGIN{printf "%.3f", d - t}')
done
total=$(awk -v o="$offset" -v d="${durs[n-1]}" 'BEGIN{printf "%.3f", o + d}')

if [[ -n "$MUSIC" ]]; then
  inputs+=(-stream_loop -1 -i "$MUSIC")
  fo=$(awk -v t="$total" 'BEGIN{s=t-1.5; printf "%.3f", (s>0?s:0)}')
  fc+="[$n:a]aformat=sample_rates=48000:channel_layouts=stereo,atrim=duration=${total},volume=${MVOL},afade=t=in:d=0.5,afade=t=out:st=${fo}:d=1.5[mus];"
  fc+="[$aprev][mus]amix=inputs=2:duration=first:normalize=0[amix];"
  aprev="amix"
fi
fc=${fc%;}

mkdir -p "$(dirname "$OUT")"
ffmpeg -y -hide_banner -loglevel error "${inputs[@]}" -filter_complex "$fc" \
  -map "[$vprev]" -map "[$aprev]" -c:a aac -b:a 192k \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -movflags +faststart -t "$total" "$OUT" \
  || die "Nag-fail ang FFmpeg. Subukan ulit o i-check ang clips."
echo "✅ Done: $OUT  (${total}s · ${used[*]})"
