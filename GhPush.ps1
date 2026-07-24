param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Continue"
Set-Location $OutDir
$log = Join-Path $OutDir "ghpush.log"
$gh = "C:\Program Files\GitHub CLI\gh.exe"
"== repo create + push ==" | Set-Content $log -Encoding UTF8
(& $gh repo create AppGrowing-Creative-Tracker --public --source $OutDir --remote origin --push 2>&1) | Add-Content $log -Encoding UTF8
"== remote -v ==" | Add-Content $log -Encoding UTF8
(git remote -v 2>&1) | Add-Content $log -Encoding UTF8
"== repo url ==" | Add-Content $log -Encoding UTF8
(& $gh repo view --json url -q .url 2>&1) | Add-Content $log -Encoding UTF8
