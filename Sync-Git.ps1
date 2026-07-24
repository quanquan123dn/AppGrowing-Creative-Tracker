param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Continue"
Set-Location $OutDir
$log = Join-Path $OutDir "sync.log"
"== add/commit/push ==" | Set-Content $log -Encoding UTF8
(git add -A 2>&1) | Add-Content $log -Encoding UTF8
(git commit -m "Sua prompt chi lay doi thu + daily auto deploy/sync" 2>&1) | Add-Content $log -Encoding UTF8
(git push 2>&1) | Add-Content $log -Encoding UTF8
