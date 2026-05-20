# Normalize
Get-ChildItem $HOME\Downloads\*.mp4 | ForEach-Object {
    ffmpeg -i $_.FullName -c:v libx264 -preset fast -crf 18 -fps_mode cfr -af "aresample=async=1" -c:a aac -ar 48000 "$HOME\Downloads\fixed_$($_.Name)"
}

# Combine (sorted by filename)
$files = Get-ChildItem $HOME\Downloads\fixed_*.mp4 | Sort Name
$listFile = "$env:TEMP\concat_list.txt"
$files | ForEach-Object { "file '$($_.FullName)'" } | Out-File -Encoding ASCII $listFile

ffmpeg -f concat -safe 0 -i $listFile -map 0:v:0 -map 0:a:0 -map_metadata -1 -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 128k $HOME\Downloads\combined_output.mp4
Remove-Item $listFile
