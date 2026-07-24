$ErrorActionPreference = "Continue"
$log = Join-Path $PSScriptRoot "gh-install.log"
"== winget install GitHub.cli ==" | Set-Content $log -Encoding UTF8
(winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements 2>&1) | Add-Content $log -Encoding UTF8
("exit code: " + $LASTEXITCODE) | Add-Content $log -Encoding UTF8
