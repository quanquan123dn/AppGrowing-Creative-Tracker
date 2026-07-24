$ErrorActionPreference = "Continue"
$log = Join-Path $PSScriptRoot "gh-fix.log"
"== npm uninstall -g gh ==" | Set-Content $log -Encoding UTF8
(npm uninstall -g gh 2>&1) | Add-Content $log -Encoding UTF8
"== Get-Command gh sources ==" | Add-Content $log -Encoding UTF8
(Get-Command gh -All -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source) | Add-Content $log -Encoding UTF8
"== gh --version ==" | Add-Content $log -Encoding UTF8
(& "C:\Program Files\GitHub CLI\gh.exe" --version 2>&1) | Add-Content $log -Encoding UTF8
"== gh auth status ==" | Add-Content $log -Encoding UTF8
(& "C:\Program Files\GitHub CLI\gh.exe" auth status 2>&1) | Add-Content $log -Encoding UTF8
