$ErrorActionPreference = "Continue"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$dir = $PSScriptRoot
$out = Join-Path $dir "inspect.log"
$Key = (Get-Content (Join-Path $dir "apikey.txt") -Raw -Encoding UTF8).Trim()
$Headers = @{ Authorization = "Bearer $Key" }
$MatBase = "https://ai-chat-global.youcloud.com/aichat/sessions"

$s = Get-Content (Join-Path $dir "data.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$sid = ($s.entries | Where-Object { $_.session_id } | Select-Object -First 1).session_id
$enc = [uri]::EscapeDataString($sid)
$r = Invoke-WebRequest -Uri "$MatBase/$enc/materials" -Headers $Headers -TimeoutSec 120 -UseBasicParsing
$json = [System.Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
$arr = $json | ConvertFrom-Json

$L = @()
$L += "session: $sid"
$L += "count: " + @($arr).Count
$L += "== FIELDS of item[0] =="
$L += (@($arr)[0].PSObject.Properties | ForEach-Object { $_.Name + " = " + ($_.Value) })
$L += "== RAW item[0..1] =="
$L += (@($arr) | Select-Object -First 2 | ConvertTo-Json -Depth 6)
$L | Set-Content -Path $out -Encoding UTF8
