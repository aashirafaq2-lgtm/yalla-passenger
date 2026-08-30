Add-Type -AssemblyName System.Drawing
function Resize-Image {
    param([string]$in, [string]$out, [int]$sz)
    $img = [System.Drawing.Image]::FromFile($in)
    $bmp = New-Object System.Drawing.Bitmap($sz, $sz)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $sz, $sz)
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $img.Dispose()
}

$src = 'assets\icon\app_icon.png'
$dest = 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force }

$sizes = @{
    '20x20@1x' = 20; '20x20@2x' = 40; '20x20@3x' = 60
    '29x29@1x' = 29; '29x29@2x' = 58; '29x29@3x' = 87
    '40x40@1x' = 40; '40x40@2x' = 80; '40x40@3x' = 120
    '50x50@1x' = 50; '50x50@2x' = 100
    '57x57@1x' = 57; '57x57@2x' = 114
    '60x60@2x' = 120; '60x60@3x' = 180
    '72x72@1x' = 72; '72x72@2x' = 144
    '76x76@1x' = 76; '76x76@2x' = 152
    '83.5x83.5@2x' = 167
    '1024x1024@1x' = 1024
}

foreach ($kv in $sizes.GetEnumerator()) {
    Resize-Image $src "$dest\Icon-App-$($kv.Name).png" $kv.Value
}
