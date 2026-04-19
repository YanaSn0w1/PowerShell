# [PayPal-Donations](https://www.paypal.com/donate/?hosted_button_id=9LWWH273HEVC4 "Donate to YanaHeat") ⬅️
# [Micro Edit X Vid](https://github.com/YanaSn0w1/PowerShell/blob/main/Micro%20Edit%20X%20Vid.ps1 "Micro Edit X Vid") ⬅️

Here’s the exact minimal README you wanted (copy-paste this straight into your README.md):markdown

# X Video Processor (Threads → X)

### 1. Install FFmpeg (one time)
Run this in PowerShell:
```powershell
winget install ffmpeg

2. Create the folderCreate this folder:
~/Videos/process
(just Videos/process inside your user folder)3. Run the scriptOption A – Paste every time
Open PowerShell, go to the folder, then paste the whole script below and press Enter.Option B – One-time .ps1 file (recommended)  Save the script below as process_for_x.ps1 inside the process folder  
From now on just run:powershell

cd ~/Videos/process
.\process_for_x.ps1

The Scriptpowershell

# === X Video Processor - Threads to X Bypass ===
$inputFolder = Join-Path $HOME "Videos\process"
$outputFolder = Join-Path $inputFolder "processed"

New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null

Get-ChildItem -Path $inputFolder -Filter "*.mp4" | ForEach-Object {
    $inputFile = $_.FullName
    $outputFile = Join-Path $outputFolder $_.Name

    $randZoom   = 1.02 + (Get-Random -Minimum 0 -Maximum 31)/1000
    $randBright = (Get-Random -Minimum -3 -Maximum 4)/100

    Write-Host "Processing $($_.Name) ..." -ForegroundColor Cyan

    $vf = "scale=iw*$($randZoom):ih*$($randZoom):flags=lanczos,eq=brightness=$($randBright):contrast=1.05:saturation=1.12,noise=alls=5:allf=t+u,scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=1"

    & ffmpeg -i "$inputFile" -vf "$vf" `
        -c:v libx264 -crf 19 -preset medium `
        -c:a aac -b:a 128k `
        -movflags +faststart `
        "$outputFile" -y
}

Write-Host "✅ All done! Processed files are in: $outputFolder" -ForegroundColor Green

Drop your videos in process, run the script, and upload the ones from the processed folder to X.
That's it.

Save it and you're done. No extra bullshit.

