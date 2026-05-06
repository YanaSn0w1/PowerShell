# ================== v3.4 FINAL - Visible Logo + TTS + X Compatible ==================
$scriptFolder = Join-Path $env:USERPROFILE "Videos\Logo"
Write-Host "=== Processing folder: $scriptFolder" -ForegroundColor Yellow

$ffmpegPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
if (-not $ffmpegPath) { $ffmpegPath = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source }

$videos = Get-ChildItem -Path $scriptFolder -File | Where-Object { $_.Extension -match '\.(mp4|mov|avi|mkv|webm|flv|wmv)$' } | Sort-Object Name
$images = Get-ChildItem -Path $scriptFolder -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|gif|bmp|webp)$' } | Sort-Object Name

if ($videos.Count -eq 0 -or $images.Count -eq 0) { Write-Host "❌ Missing video or logo!" -ForegroundColor Red; pause; exit }

$inputVideo = $videos[0].FullName
$inputLogo  = $images[0].FullName
$tempFile   = Join-Path $scriptFolder ($videos[0].BaseName + "_temp.mp4")
$outputVideo = Join-Path $scriptFolder ($videos[0].BaseName + "_X_READY" + $videos[0].Extension)

Write-Host "✅ Video: $($videos[0].Name)" -ForegroundColor Green
Write-Host "✅ Logo : $($images[0].Name)" -ForegroundColor Green

$confirm = Read-Host "Process? (Y/N)"
if ($confirm -notlike "Y*") { exit }

# ================== SETTINGS ==================
$logoSize      = 0.45
$logoOpacity   = 0.28
$brightMin     = 0.0
$brightMax     = 2.0
$vignetteMin   = 0.02
$vignetteMax   = 0.05
$ttsText       = "Follow my X/Twitter @YanaHeat"
$ttsVolume     = 2.5

$captions = @(
    @{text="Follow";     start=0.5; end=3.2},
    @{text="my X/Twitter";        start=3.6; end=6.1},
    @{text="@YanaHeat";        start=6.5; end=10}
)

# ================== TTS ==================
Write-Host "Generating TTS..." -ForegroundColor Cyan
$ttsWav = Join-Path $scriptFolder "temp_tts.wav"
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Volume = 90
$synth.SetOutputToWaveFile($ttsWav)
$synth.Speak($ttsText)
$synth.SetOutputToDefaultAudioDevice()

# ================== PASS 1: Video + Logo + Subtitles ==================
Write-Host "Pass 1: Adding edits + bouncing logo + subtitles..." -ForegroundColor Cyan

$vf = "scale='trunc(iw*1.07/2)*2':'trunc(ih*1.07/2)*2':flags=lanczos"
$vf += ",crop=iw*0.96:ih*0.96:(iw-iw*0.96)/2+((iw*0.04)*sin(t*0.8)):(ih-ih*0.96)/2+((ih*0.04)*cos(t*1.1))"
$vf += ",rotate='0.018*sin(t*2.2)':ow=iw:oh=ih"
$vf += ",vignette=0.04:angle=PI/3"
$vf += ",eq=brightness=0:contrast=1.11:saturation=1.13"
$vf += ",noise=alls=18,setsar=1,format=yuv420p[base]"
$vf += ";[1:v]scale=iw*$($logoSize):-1,format=rgba,colorchannelmixer=aa=$($logoOpacity),boxblur=1.2:1[logo]"
$vf += ";[base][logo]overlay=x='((main_w-overlay_w)/2)+((main_w/3.5)*sin(t*0.75))':y='((main_h-overlay_h)/2)+((main_h/3.8)*cos(t*1.1))':format=auto[v0]"

$current = "v0"
$index = 1
foreach ($cap in $captions) {
    $safeText = $cap.text -replace "'", "\\'" -replace ":", "\\:"
    $draw = "drawtext=fontfile=C\\:/Windows/Fonts/arial.ttf:text='$safeText':fontcolor=white:fontsize=52:borderw=7:bordercolor=black:box=1:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-130:enable='between(t,$($cap.start),$($cap.end))'"
    $next = "v$index"
    $vf += ";[$current]$draw[$next]"
    $current = $next
    $index++
}

& "$ffmpegPath" -i "$inputVideo" -i "$inputLogo" -filter_complex "$vf" -map "[$current]" -map 0:a -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -c:a copy -movflags +faststart -y "$tempFile"

if (-not (Test-Path $tempFile)) { Write-Host "❌ Pass 1 failed" -ForegroundColor Red; pause; exit }

# ================== PASS 2: Add TTS ==================
Write-Host "Pass 2: Adding TTS voiceover..." -ForegroundColor Cyan

& "$ffmpegPath" -i "$tempFile" -i "$ttsWav" -filter_complex "[1:a]volume=$ttsVolume,adelay=0|0[tts];[0:a][tts]amix=inputs=2:duration=first:dropout_transition=2[aout]" -map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 192k -movflags +faststart -y "$outputVideo"

# Cleanup
Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
Remove-Item $ttsWav -Force -ErrorAction SilentlyContinue

if (Test-Path $outputVideo) {
    Write-Host "`n✅ SUCCESS! File ready for X:" -ForegroundColor Green
    Write-Host $outputVideo -ForegroundColor Cyan
    Write-Host "Logo visible + TTS added + perfect for X upload" -ForegroundColor Yellow
    Write-Host "Upload from the X app 🚀" -ForegroundColor Cyan
} else {
    Write-Host "❌ Final pass failed - copy the entire red error above" -ForegroundColor Red
}
pause
