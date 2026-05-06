# [PayPal-Donations](https://www.paypal.com/donate/?hosted_button_id=9LWWH273HEVC4 "Donate to YanaHeat") ⬅️ [Edit X](https://github.com/YanaSn0w1/PowerShell/blob/main/Edit%20X.ps1 "Edit X") ⬅️

# X-Ready Video Processor

**Turn raw Instagram videos into polished, monetization-friendly X/Twitter content** — with bouncing logo, subtle organic edits, TTS voiceover, and subtitles.

This one-click PowerShell script was built specifically for creators like @YanaHeat who repurpose short videos and want X to treat them as **original content** for full revenue sharing.

## Features

- ✅ Animated **bouncing logo** (smooth sin/cos movement)
- ✅ Subtle random edits (micro-zoom, gentle pan, camera shake, light vignette, film grain, color tweaks)
- ✅ Windows TTS voiceover ("YanaHeat daily vibes" by default)
- ✅ Timed subtitles at the bottom (full URLs now supported)
- ✅ Forces perfect X format (`yuv420p` + faststart) — no more "no supported format" errors or traffic cone icon
- ✅ Outputs a clean `_X_READY.mp4` file ready to upload straight from the X app

## Requirements

- Windows 10 or 11
- PowerShell (built-in)
- FFmpeg (the script auto-detects it via WinGet or PATH)
- One video file (`.mp4`) + one logo file (`.png`) in the working folder

## How to Use (Super Simple)

1. Create this folder:  
   `C:\Users\jeffr\Videos\Logo`

2. Put your video and logo inside it.

3. Save the script as **`X_Ready.ps1`** in the same folder.

4. Double-click the `.ps1` file **or** open PowerShell in that folder and run:
   ```powershell
   .\X_Ready.ps1
