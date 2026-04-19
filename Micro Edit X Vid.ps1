# === CONFIG ===
$inputFolder = Join-Path $HOME "Videos\process"   # ← this is now short & clean
$outputFolder = Join-Path $inputFolder "processed"

New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null

Get-ChildItem -Path $inputFolder -Filter "*.mp4" | ForEach-Object {
    $inputFile = $_.FullName
    $outputFile = Join-Path $outputFolder $_.Name

    # Randomized micro-edits
    $randZoom   = 1.02 + (Get-Random -Minimum 0 -Maximum 31)/1000
    $randBright = (Get-Random -Minimum -3 -Maximum 4)/100

    Write-Host "Processing $($_.Name) ..." -ForegroundColor Cyan

    # Clean filter chain (no rotation, subtle color tweak)
    $vf = "scale=iw*$($randZoom):ih*$($randZoom):flags=lanczos,eq=brightness=$($randBright):contrast=1.05:saturation=1.12,noise=alls=5:allf=t+u,scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=1"

    & ffmpeg -i "$inputFile" -vf "$vf" `
        -c:v libx264 -crf 19 -preset medium `
        -c:a aac -b:a 128k `
        -movflags +faststart `
        "$outputFile" -y
}

Write-Host "✅ All done! Processed files are in: $outputFolder" -ForegroundColor Green
