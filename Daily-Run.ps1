<#
  Daily-Run.ps1 - chạy hằng ngày (Task Scheduler):
  1) Cập nhật dữ liệu creative + dashboard local
  2) Dựng bản web (link CDN tươi)
  3) Deploy lên Vercel (production)
#>
param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Continue"
$dir = $OutDir

& (Join-Path $dir "Update-Dashboard.ps1")   -OutDir $dir
& (Join-Path $dir "Build-WebDashboard.ps1")  -OutDir $dir
& (Join-Path $dir "Deploy-Vercel.ps1")       -OutDir $dir

# Đồng bộ GitHub (data.json + web/index.html; media/ đã bị .gitignore loại)
Set-Location $dir
git add -A 2>&1 | Out-Null
git commit -m ("Daily update " + (Get-Date -Format 'yyyy-MM-dd HH:mm')) 2>&1 | Out-Null
git push 2>&1 | Out-Null
