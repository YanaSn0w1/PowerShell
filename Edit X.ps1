# ================== v4 - Multi-Image Logos + Emoji Captions + TTS + X Compatible ==================
$scriptFolder = Join-Path $env:USERPROFILE "Videos\Logo"
Write-Host "=== Processing folder: $scriptFolder" -ForegroundColor Yellow

$ffmpegPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
if (-not $ffmpegPath) { $ffmpegPath = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source }

$videos = Get-ChildItem -Path $scriptFolder -File | Where-Object { $_.Extension -match '\.(mp4|mov|avi|mkv|webm|flv|wmv)$' } | Sort-Object Name
$images = Get-ChildItem -Path $scriptFolder -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|gif|bmp|webp)$' } | Sort-Object Name

if ($videos.Count -eq 0 -or $images.Count -eq 0) { Write-Host "❌ Missing video or logo!" -ForegroundColor Red; pause; exit }

$inputVideo = $videos[0].FullName
$tempFile   = Join-Path $scriptFolder ($videos[0].BaseName + "_temp.mp4")
$outputVideo = Join-Path $scriptFolder ($videos[0].BaseName + "_X_READY" + $videos[0].Extension)

Write-Host "✅ Video: $($videos[0].Name)" -ForegroundColor Green
Write-Host "✅ Logos: $($images.Count) image(s) found" -ForegroundColor Green

$confirm = Read-Host "Process? (Y/N)"
if ($confirm -notlike "Y*") { exit }

# ================== SETTINGS (BRIGHTNESS + LOGOS) ==================
$logoSize      = 0.45
$logoOpacity   = 0.28
$brightMin     = 0.0
$brightMax     = 0.0
$vignetteMin   = 0.001
$vignetteMax   = 0.002

$ttsText       = "Hey guys... Follow my Subscriber @JackWaves01 ... Lets Cook ... 🔥 emoji"
$ttsVolume     = 2.5

# Per-caption font sizes so long lines don't shoot off the screen
$captions = @(
    @{text="Hey guys... Follow my Subscriber"; start=0.5; end=3.2; fontsize=46},
    @{text="@JackWaves01";                      start=3.6; end=6.1; fontsize=78},
    @{text="Lets Cook 🔥";                   start=6.5; end=10;  fontsize=64}
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

# ================== VIDEO DURATION (FOR LOGO SEGMENTS) ==================
$durationLine = & "$ffmpegPath" -i "$inputVideo" 2>&1 | Select-String "Duration"
$match = [regex]::Match($durationLine.ToString(), "Duration:\s*(\d{2}:\d{2}:\d{2}\.\d+)")
$duration = [TimeSpan]::Parse($match.Groups[1].Value)
$videoSeconds = $duration.TotalSeconds
$segment = $videoSeconds / $images.Count

# ================== PASS 1: Video + Multi-Logos + Subtitles ==================
Write-Host "Pass 1: Adding edits + rotating logos + subtitles..." -ForegroundColor Cyan

$vf  = "scale='trunc(iw*1.07/2)*2':'trunc(ih*1.07/2)*2':flags=lanczos"
$vf += ",crop=iw*0.96:ih*0.96:(iw-iw*0.96)/2+((iw*0.04)*sin(t*0.8)):(ih-ih*0.96)/2+((ih*0.04)*cos(t*1.1))"
$vf += ",rotate='0.018*sin(t*2.2)':ow=iw:oh=ih"
$vf += ",vignette=0.012:angle=PI/3"
$vf += ",eq=brightness=0.085:contrast=1.06:saturation=1.11"
$vf += ",noise=alls=18,setsar=1,format=yuv420p[base]"

# Multi-image logos (each logo gets its own time slice)
$chain = "base"
$idx   = 0

foreach ($img in $images) {
    $start = [math]::Round($segment * $idx, 3)
    $end   = [math]::Round($segment * ($idx + 1), 3)

    # scale + alpha for this logo
    $vf += ";[$($idx+1):v]scale=iw*$($logoSize):-1,format=rgba,colorchannelmixer=aa=$($logoOpacity),boxblur=1.2:1[logo$idx]"

    # overlay this logo on the current chain
    $vf += ";[$chain][logo$idx]overlay=" +
           "x='((main_w-overlay_w)/2)+((main_w/3.5)*sin(t*0.75))':" +
           "y='((main_h-overlay_h)/2)+((main_h/3.8)*cos(t*1.1))':" +
           "enable='between(t,$start,$end)':format=auto[v$idx]"

    $chain = "v$idx"
    $idx++
}

$current = $chain
$index   = 1

foreach ($cap in $captions) {
    $safeText = $cap.text -replace "'", "\\'" -replace ":", "\\:"
    $draw = "drawtext=fontfile=C\\:/Windows/Fonts/seguiemj.ttf:text='$safeText':" +
            "fontcolor=white:fontsize=$($cap.fontsize):borderw=8:bordercolor=black:" +
            "box=1:boxcolor=black@0.75:" +
            "x=(w-text_w)/2:y=h-text_h-140:" +
            "enable='between(t,$($cap.start),$($cap.end))'"
    $next = "v$index"
    $vf  += ";[$current]$draw[$next]"
    $current = $next
    $index++
}

# Build image inputs
$imageInputs = @()
foreach ($img in $images) {
    $imageInputs += "-i"
    $imageInputs += $img.FullName
}

& "$ffmpegPath" -i "$inputVideo" @imageInputs -filter_complex "$vf" -map "[$current]" -map 0:a -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -c:a copy -movflags +faststart -y "$tempFile"

if (-not (Test-Path $tempFile)) { Write-Host "❌ Pass 1 failed" -ForegroundColor Red; pause; exit }

# ================== PASS 2: Add TTS ==================
Write-Host "Pass 2: Adding TTS voiceover..." -ForegroundColor Cyan

& "$ffmpegPath" -i "$tempFile" -i "$ttsWav" -filter_complex "[1:a]volume=$ttsVolume,adelay=0|0[tts];[0:a][tts]amix=inputs=2:duration=first:dropout_transition=2[aout]" -map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 192k -movflags +faststart -y "$outputVideo"

# Cleanup
Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
Remove-Item $ttsWav -Force -ErrorAction SilentlyContinue

if (Test-Path $outputVideo) {
    Write-Host "`n✅ SUCCESS! File ready for X (now much brighter, multi-logo):" -ForegroundColor Green
    Write-Host $outputVideo -ForegroundColor Cyan
    Write-Host "Multi logos + TTS added + perfect for X upload" -ForegroundColor Yellow
    Write-Host "Upload from the X app 🚀" -ForegroundColor Cyan
} else {
    Write-Host "❌ Final pass failed - copy the entire red error above" -ForegroundColor Red
}
pause
