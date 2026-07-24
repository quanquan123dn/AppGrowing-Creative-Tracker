<#
  Refresh-Web.ps1 - làm mới GIAO DIỆN (không gọi lại API phân tích):
  1) Dựng lại dashboard.html local từ template mới
  2) Dựng lại web/index.html (lấy link CDN tươi)
  3) Deploy Vercel + push GitHub
#>
param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Continue"
$dir = $OutDir
& (Join-Path $dir "Rebuild-Dashboard.ps1")   -OutDir $dir
& (Join-Path $dir "Build-WebDashboard.ps1")   -OutDir $dir
& (Join-Path $dir "Deploy-Vercel.ps1")        -OutDir $dir
& (Join-Path $dir "Sync-Git.ps1")             -OutDir $dir
