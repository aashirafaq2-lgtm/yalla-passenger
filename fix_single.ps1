Add-Type -AssemblyName System.Drawing
$path = "c:\Users\Administrator\Desktop\Yalla\Yalla Passanger\iq_massar_flutter\assets\icon\app_icon.png"
$outPath = "c:\Users\Administrator\Desktop\Yalla\Yalla Passanger\iq_massar_flutter\assets\icon\app_icon_no_alpha.png"
$img = [System.Drawing.Image]::FromFile($path)
$bmp = New-Object System.Drawing.Bitmap($img.Width, $img.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$g.DrawImage($img, 0, 0, $img.Width, $img.Height)
$g.Dispose()
$img.Dispose()
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Success"
