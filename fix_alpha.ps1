Add-Type -AssemblyName System.Drawing
$iconDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"
$files = Get-ChildItem -Path $iconDir -Filter "*.png"
foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
    $img = [System.Drawing.Image]::FromStream($ms)
    $bmp = New-Object System.Drawing.Bitmap($img.Width, $img.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::White)
    $g.DrawImage($img, 0, 0, $img.Width, $img.Height)
    $g.Dispose()
    $img.Dispose()
    $ms.Dispose()
    $bmp.Save($file.FullName, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}
