param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Continue"
$web = Join-Path $OutDir "web"
Set-Location $web
# Deploy thư mục web/ lên production, không hỏi (dùng mặc định)
vercel deploy --prod --yes 2>&1 | Out-File -FilePath (Join-Path $OutDir "deploy.log") -Encoding UTF8
