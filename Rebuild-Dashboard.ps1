<#
  Rebuild-Dashboard.ps1
  Dọn entry rác trong data.json và dựng lại dashboard.html TỪ dữ liệu đã có (không gọi API).
#>
param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$dataFile = Join-Path $OutDir "data.json"
$tpl      = Join-Path $OutDir "dashboard.template.html"
$out      = Join-Path $OutDir "dashboard.html"

$s = Get-Content $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json
# chỉ giữ entry hợp lệ (có date + network)
$s.entries = @($s.entries | Where-Object { $_.date -and $_.network })

($s | ConvertTo-Json -Depth 8) | Set-Content -Path $dataFile -Encoding UTF8
$inject = "const DATA = " + ($s | ConvertTo-Json -Depth 8) + ";"
(Get-Content $tpl -Raw -Encoding UTF8).Replace("/*__DATA__*/", $inject) | Set-Content -Path $out -Encoding UTF8

Write-Host "Da don $($s.entries.Count) entry hop le. Dashboard: $out"
