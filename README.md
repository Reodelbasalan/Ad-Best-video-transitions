# 🎬 Best Video Transitions (Free!)

Libre at open-source na **video transitions**. Walang watermark, walang bayad.

Dalawang paraan ang pwede mong gamitin:

| | 🌐 Web App (`index.html`) | 💻 FFmpeg Scripts (`scripts/`) |
|---|---|---|
| Install | Wala, browser lang | Kailangan ng FFmpeg |
| Gamit | Click-click lang | Terminal commands |
| Transitions | 29 (flash, whip, zoom, glitch, shake, light leak…) | 58 + 7 presets |
| Extras | Photos, trim, music, whoosh SFX, preview | Pinakamataas na quality |
| Output | MP4 (Chrome/Edge) o WebM | MP4 (H.264) |

---

## 🌐 Web App: walang install

1. I-download ang repo, tapos i-double-click ang **`index.html`** (pinakamaganda sa Chrome o Edge).
2. **Add videos / photos**, puwede ring i-drag.
3. Pumili ng transition para sa lahat, o iba-iba bawat cut. May 🎲 **Random** din.
4. Pumili ng size: YouTube 16:9, TikTok/Reels 9:16, IG 1:1 o 4:5.
5. **▶ Preview** muna, tapos **⬇ Export video** → **💾 Download**.

Features:
- 29 transitions: Flash, Whip pan, Zoom in/out, Spin, Glitch, Shake, Light leak, Cross zoom, Pixelize, Blur, Iris, Card flip, Bounce, Blinds, Slides, Wipes, at iba pa.
- Trim ng bawat video (from/to seconds).
- Photos with slow Ken Burns zoom.
- Background music na may volume control at auto fade-out.
- Whoosh / bass-hit sound effect sa bawat transition (built-in, walang file na kailangan).
- Audio crossfade sa bawat transition.
- Blur background para sa portrait clips sa landscape video (at baliktad).
- **Private**: walang ina-upload. Sa computer/phone mo lang lahat.

> ⚠️ Huwag i-minimize ang tab habang nag-e-export; real-time ang recording (ang 1-minute video ay mga 1 minute i-export).

### Gawing libreng website (GitHub Pages)

Sa GitHub repo mo: **Settings → Pages → Branch: `main` / root → Save**.
Pagkalipas ng ilang minuto, live na sa `https://USERNAME.github.io/best-video-transitions/`, at magagamit kahit sa phone.

---

## 💻 FFmpeg Scripts

58 transitions + 7 easy presets: **flash, whip, zoom, glitch, dip, iris, blur**.

### ⚡ Quick start

1. Install FFmpeg:
   - Windows: `winget install ffmpeg`
   - Mac: `brew install ffmpeg`
   - Linux: `sudo apt install ffmpeg`
2. Pagdugtungin ang clips mo with a transition:

```bash
./scripts/transition.sh -t flash -o final.mp4 clip1.mp4 clip2.mp4 clip3.mp4
```

Done na! 🔥 Kahit iba-iba ang size (portrait/landscape) or FPS ng clips, auto-fix na yan. Kasama rin ang audio crossfade.

### ⭐ Best transitions (top picks)

| Preset | Itsura | Bagay sa |
|---|---|---|
| `flash` | White flash | Beat drops, TikTok/Reels edits |
| `whip` | Mabilis na slide (whip pan) | Travel vlogs, fast edits |
| `zoom` | Zoom in | Hype intros, reveals |
| `glitch` | Pixel glitch | Gaming, tech videos |
| `dip` | Fade to black | Cinematic, scene changes |
| `iris` | Circle open | Retro / cartoon vibe |
| `blur` | Horizontal blur | Smooth music videos |
| `fade` | Classic crossfade | Kahit ano (default) |

Iba pang magaganda: `circlecrop`, `radial`, `slideleft`, `squeezeh`, `diagtl`, `hlwind`, `coverleft`, `revealright`, `dissolve`.

Para makita lahat:

```bash
./scripts/list.sh
```

### 🎛️ Options

| Flag | Default | Meaning |
|---|---|---|
| `-t` | `fade` | Transition name or preset |
| `-d` | `0.6` | Haba ng transition (seconds) |
| `-r` | `1920x1080` | Resolution (`1080x1920` para sa TikTok/Reels) |
| `-f` | `30` | FPS |
| `-p` | `3` | Ilang seconds ang bawat photo |
| `-m` | — | Background music (auto loop + fade out) |
| `-v` | `0.5` | Music volume (0.0–1.0) |
| `-o` | (required) | Output file |

Puwede ang `-t random` para iba-iba ang transition bawat cut. Puwede ring ihalo ang videos at photos (jpg/png/webp).

Example — vertical TikTok video, 1-second zoom:

```bash
./scripts/transition.sh -t zoom -d 1 -r 1080x1920 -o tiktok.mp4 a.mp4 b.mp4
```

### 👀 Preview lahat ng transitions

```bash
./scripts/preview-all.sh                 # test colors
./scripts/preview-all.sh mine1.mp4 mine2.mp4   # gamit ang sarili mong clips
```

Makikita sa `output/previews/` — isang video bawat transition, para makapili ka ng favorite mo.

### 🪟 Windows users

Gamitin ang **Git Bash** (kasama sa [Git for Windows](https://git-scm.com/download/win)) para ma-run ang `.sh` scripts.

## 📁 Files

```
index.html               ← Web app (buksan lang sa browser)
scripts/transition.sh    ← Pagdugtungin ang clips with transitions
scripts/preview-all.sh   ← Gumawa ng preview ng lahat ng 58 transitions
scripts/list.sh          ← Ipakita lahat ng transition names
```

## License

MIT — free gamitin kahit saan, pati sa commercial videos.
