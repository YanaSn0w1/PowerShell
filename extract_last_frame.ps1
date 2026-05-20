ffmpeg -sseof -1 -i (Get-ChildItem $HOME\Downloads\*.mp4 | Sort LastWriteTime -Descending | Select -First 1).FullName -update 1 -q:v 2 $HOME\Downloads\last_frame.png
