Add-Type -AssemblyName System.Drawing
$iconDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"
$outDir = "ios\Runner\Assets.xcassets\TempIcons"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$files = Get-ChildItem -Path $iconDir -Filter "*.png"
foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
    $img = [System.Drawing.Image]::FromStream($ms)
    
    $bmp = New-Object System.Drawing.Bitmap($img.Width, $img.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    
    $g.Clear([System.Drawing.Color]::White)
    $g.DrawImage($img, 0, 0, $img.Width, $img.Height)
    
    $outPath = Join-Path $outDir $file.Name
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmp.Dispose()
    $img.Dispose()
    $ms.Dispose()
}

Copy-Item -Path "$outDir\*" -Destination $iconDir -Force
Remove-Item $outDir -Recurse -Force
Write-Host "Success"
