# =====================================================
# ギャル庁 - Favicon PNG 一括生成
# =====================================================
# 黒背景 (#16161e) + ライム色 "ギ" (#b5f03a) の正方形ロゴ
# Google検索結果・Apple端末・Android端末すべてに最適化
#
# 出力:
#   site/static/favicon.ico          (32x32 → ICO)
#   site/static/favicon-32.png
#   site/static/favicon-192.png
#   site/static/favicon-512.png
#   site/static/apple-touch-icon.png (180x180)
# =====================================================

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$staticDir = Join-Path $scriptDir "..\static"

# カラー定義
$bgColor   = [System.Drawing.ColorTranslator]::FromHtml("#16161e")  # ダークインク
$fgColor   = [System.Drawing.ColorTranslator]::FromHtml("#b5f03a")  # ライム

# Japanese-capable font (Yu Gothic UI が Windows 標準)
$fontFamily = "Yu Gothic UI"
try {
    $testFont = New-Object System.Drawing.Font($fontFamily, 10)
    $testFont.Dispose()
} catch {
    Write-Warning "Yu Gothic UI not found, falling back to Meiryo"
    $fontFamily = "Meiryo"
}

function New-FaviconPng {
    param(
        [int]$Size,
        [string]$OutPath,
        [bool]$RoundCorner = $true
    )

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # 背景（角丸 or 直角）
    $bgBrush = New-Object System.Drawing.SolidBrush($bgColor)
    if ($RoundCorner -and $Size -ge 64) {
        $radius = [Math]::Round($Size * 0.20)
        $rect = New-Object System.Drawing.Rectangle(0, 0, $Size, $Size)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
        $path.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
        $path.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
        $path.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
        $path.CloseFigure()
        $g.FillPath($bgBrush, $path)
        $path.Dispose()
    } else {
        $g.FillRectangle($bgBrush, 0, 0, $Size, $Size)
    }
    $bgBrush.Dispose()

    # "ギ" の文字
    # 文字サイズはアイコンの 65% 程度
    $fontSize = [Math]::Round($Size * 0.62)
    $font = New-Object System.Drawing.Font($fontFamily, $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $textBrush = New-Object System.Drawing.SolidBrush($fgColor)

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    # 上下のバランス：「ギ」は縦長なので中心からわずかに上にオフセット
    $rect = New-Object System.Drawing.RectangleF(0, ($Size * -0.02), $Size, $Size)
    $g.DrawString("ギ", $font, $textBrush, $rect, $sf)

    $font.Dispose()
    $textBrush.Dispose()
    $sf.Dispose()
    $g.Dispose()

    # 保存
    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "  Generated: $OutPath ($Size x $Size)" -ForegroundColor Green
}

# 出力先ディレクトリ確認
$faviconsDir = Join-Path $staticDir "images\favicons"
if (-not (Test-Path $faviconsDir)) {
    New-Item -ItemType Directory -Path $faviconsDir -Force | Out-Null
}

Write-Host "=== Generating favicon PNGs ===" -ForegroundColor Cyan

# 各サイズ生成
New-FaviconPng -Size 32  -OutPath (Join-Path $staticDir "favicon-32.png")  -RoundCorner $false
New-FaviconPng -Size 192 -OutPath (Join-Path $staticDir "favicon-192.png") -RoundCorner $true
New-FaviconPng -Size 512 -OutPath (Join-Path $staticDir "favicon-512.png") -RoundCorner $true
New-FaviconPng -Size 180 -OutPath (Join-Path $staticDir "apple-touch-icon.png") -RoundCorner $true

# favicon.ico (Google検索結果用、32x32 ICO形式)
Write-Host "`n=== Generating favicon.ico ===" -ForegroundColor Cyan
$pngPath = Join-Path $staticDir "favicon-32.png"
$icoPath = Join-Path $staticDir "favicon.ico"

# PNG → ICO 変換 (System.Drawing.Iconでバイト操作)
$pngBytes = [System.IO.File]::ReadAllBytes($pngPath)
$pngStream = New-Object System.IO.MemoryStream(,$pngBytes)
$pngImage = [System.Drawing.Image]::FromStream($pngStream)

# ICO ヘッダ + ディレクトリ + PNG データを結合
$icoStream = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter($icoStream)

# ICONDIR
$writer.Write([UInt16]0)      # Reserved (must be 0)
$writer.Write([UInt16]1)      # Type: 1 = icon
$writer.Write([UInt16]1)      # Number of images

# ICONDIRENTRY
$writer.Write([Byte]32)       # Width (0 = 256)
$writer.Write([Byte]32)       # Height
$writer.Write([Byte]0)        # Color count (0 = no palette)
$writer.Write([Byte]0)        # Reserved
$writer.Write([UInt16]1)      # Color planes
$writer.Write([UInt16]32)     # Bits per pixel
$writer.Write([UInt32]$pngBytes.Length)  # Size of image data
$writer.Write([UInt32]22)     # Offset (6 + 16 = 22)

# Image data (PNG inside ICO, supported by Vista+)
$writer.Write($pngBytes)

[System.IO.File]::WriteAllBytes($icoPath, $icoStream.ToArray())
$writer.Dispose()
$icoStream.Dispose()
$pngStream.Dispose()
$pngImage.Dispose()
Write-Host "  Generated: $icoPath" -ForegroundColor Green

Write-Host "`n=== Done! ===" -ForegroundColor Cyan
Get-ChildItem -Path $staticDir -Filter "favicon*" | Format-Table Name, Length -AutoSize
Get-ChildItem -Path $staticDir -Filter "apple*" | Format-Table Name, Length -AutoSize
