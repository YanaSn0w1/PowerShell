# ================== FIXED - NO QUOTING ISSUES + FULL COMPATIBILITY ==================
$scriptFolder = Join-Path $env:USERPROFILE "Videos\Logo"
Write-Host "=== Looking in folder: $scriptFolder" -ForegroundColor Yellow

# Auto-find your ffmpeg
$ffmpegPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1 -ExpandProperty FullName
if (-not $ffmpegPath) {
    $ffmpegPath = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source
}
Write-Host "✅ Using ffmpeg at: $ffmpegPath" -ForegroundColor Cyan

# Auto-detect files
$videos = Get-ChildItem -Path $scriptFolder -File |
          Where-Object { $_.Extension -match '\.(mp4|mov|avi|mkv|webm|flv|wmv)$' } |
          Sort-Object Name
$images = Get-ChildItem -Path $scriptFolder -File |
          Where-Object { $_.Extension -match '\.(png|jpg|jpeg|gif|bmp|webp)$' } |
          Sort-Object Name

if ($videos.Count -eq 0) { Write-Host "`n❌ No video found!" -ForegroundColor Red; pause; exit }
if ($images.Count -eq 0) { Write-Host "`n❌ No logo image found!" -ForegroundColor Red; pause; exit }

$inputVideo = $videos[0].FullName
$inputLogo  = $images[0].FullName
$outputVideo = Join-Path $scriptFolder ($videos[0].BaseName + "_with_moving_logo" + $videos[0].Extension)

Write-Host "`n✅ Video : $($videos[0].Name)" -ForegroundColor Green
Write-Host "✅ Logo  : $($images[0].Name)" -ForegroundColor Green
Write-Host "✅ Output: $(Split-Path $outputVideo -Leaf)" -ForegroundColor Cyan

$confirm = Read-Host "`nUse these files? (Y/N)"
if ($confirm -notlike "Y*") { Write-Host "Cancelled."; pause; exit }

Write-Host "`n🎥 Processing... (this may take 1-3 minutes)" -ForegroundColor Green

# IMPROVED filter + compatibility flags
$filterComplex = "[1:v]scale=iw*0.35:-1[logo];[0:v][logo]overlay=x='((main_w-overlay_w)/2)+((main_w/3)*sin(t*0.6))':y='((main_h-overlay_h)/2)+((main_h/4)*cos(t*0.85))':format=auto,format=yuv420p"

$cmd = "`"$ffmpegPath`" -i `"$inputVideo`" -i `"$inputLogo`" -filter_complex `"$filterComplex`" -c:v libx264 -preset medium -crf 19 -c:a aac -b:a 192k -movflags +faststart -y `"$outputVideo`""

Write-Host "Running command..." -ForegroundColor DarkGray
& cmd.exe /c $cmd

# Check result
if (Test-Path $outputVideo) {
    Write-Host "`n✅ SUCCESS! Moving logo added with full compatibility!" -ForegroundColor Green
    Write-Host "New video: $(Split-Path $outputVideo -Leaf)" -ForegroundColor Cyan
    Write-Host "`nOpen it → you should now see a proper thumbnail in Windows Explorer" -ForegroundColor Cyan
    Write-Host "And it will upload to X without issues 🚀" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Still failed. Please copy the entire output above and send it to me." -ForegroundColor Red
}
pause
