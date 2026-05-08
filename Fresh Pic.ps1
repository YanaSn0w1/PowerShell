foreach ($i in "Pictures\Fresh\*.jpg", "Pictures\Fresh\*.png") {
    foreach ($file in Get-ChildItem $i) {
        ffmpeg -i $file.FullName -vf "eq=brightness=0.025:contrast=1.025:saturation=1.08" -q:v 2 "Pictures\Fresh\fresh_$($file.BaseName).jpg"
    }
}
