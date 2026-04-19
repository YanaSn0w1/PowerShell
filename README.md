## Circumvent the -90% reach on videos if not original.
### 1 Makes tiny random changes (different for every single file so X can't pattern-match):

- Slight random zoom (1.02× to 1.05×) → stretches the image by 2–5% so the exact pixel grid no longer matches the original Threads file.
- Tiny random rotation (–0.012° to +0.013°) → just enough to break the frame alignment without looking tilted.
- Micro brightness tweak (–3% to +4%) → subtle overall lighting shift.
- Slight contrast + saturation boost → makes the colors pop a tiny bit more.
- Very light noise (5% grain) → adds invisible random pixels that destroy perceptual hashing (the main thing X uses to detect reposts).

### 2 Forces even dimensions at the end (the fix we added) so FFmpeg doesn’t throw the “width not divisible by 2” error.

### 3 Re-encodes the video cleanly:

- Same resolution as the original (or very close).

- High quality (CRF 19 = visually lossless for most people).

- Medium speed preset (good balance between quality and file size).

- Audio stays untouched except re-packaged as AAC.

# [PayPal-Donations](https://www.paypal.com/donate/?hosted_button_id=9LWWH273HEVC4 "Donate to YanaHeat") ⬅️
# [Micro Edit X Vid](https://github.com/YanaSn0w1/PowerShell/blob/main/Micro%20Edit%20X%20Vid.ps1 "Micro Edit X Vid") ⬅️

### 1. Install FFmpeg.
Run this in PowerShell:
```powershell
winget install ffmpeg
```

### 2. Create this folder: ~/Videos/process
Put the videos in this folder then double click Micro Edit X Vid.ps1

### 3. Run the script
Option A – Double click .ps1 file (recommended)

Enable file extensions to save as .ps1. File Explorer → View → Show → check **File name extensions**

Create new text file in the process folder, name it Micro Edit X Vid.ps1

Option B – Paste every time 

Open PowerShell,  paste the whole script and press Enter.
