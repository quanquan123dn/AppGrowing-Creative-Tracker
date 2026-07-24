<#
  Build-WebDashboard.ps1
  Dựng bản web (web/index.html) dùng LINK CDN video (không cần file local).
  Lấy lại download_url tươi từ materials endpoint theo session_id đã lưu.
#>
param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
Start-Transcript -Path (Join-Path $OutDir "web-build.log") -Force -ErrorAction SilentlyContinue | Out-Null

$Key = $env:YOUCLOUD_API_KEY
if ([string]::IsNullOrWhiteSpace($Key)) {
  $kf = Join-Path $OutDir "apikey.txt"; if (Test-Path $kf) { $Key = (Get-Content $kf -Raw -Encoding UTF8).Trim() }
}
$Headers = @{ Authorization = "Bearer $Key" }
$MatBase = "https://ai-chat-global.youcloud.com/aichat/sessions"

function Get-Materials($sid) {
  $enc = [uri]::EscapeDataString($sid)
  $r = Invoke-WebRequest -Uri "$MatBase/$enc/materials" -Headers $Headers -TimeoutSec 120 -UseBasicParsing
  return ([System.Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray()) | ConvertFrom-Json)
}

$s = Get-Content (Join-Path $OutDir "data.json") -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($e in $s.entries) {
  if (-not $e.session_id) { continue }
  try {
    $fresh = Get-Materials $e.session_id
    $map = @{}
    foreach ($m in $fresh) { if ($m.id -and $m.download_url) { $map[[string]$m.id] = [string]$m.download_url } }
    foreach ($m in $e.materials) {
      $u = $map[[string]$m.id]
      $m.media = $u   # dùng link CDN thay cho đường dẫn local
    }
    Write-Host "  $($e.networkLabel): $($fresh.Count) URL"
  } catch {
    Write-Host "  Loi $($e.network): $($_.Exception.Message)"
  }
}

$webDir = Join-Path $OutDir "web"
New-Item -ItemType Directory -Force -Path $webDir | Out-Null
$json = $s | ConvertTo-Json -Depth 8
$inject = "const DATA = $json;"
(Get-Content (Join-Path $OutDir "dashboard.template.html") -Raw -Encoding UTF8).Replace("/*__DATA__*/", $inject) |
  Set-Content -Path (Join-Path $webDir "index.html") -Encoding UTF8

Write-Host "OK -> $webDir\index.html"
try { Stop-Transcript | Out-Null } catch {}
