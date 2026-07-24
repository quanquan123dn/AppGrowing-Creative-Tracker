param([string]$OutDir = $PSScriptRoot)
$ErrorActionPreference = "Continue"
Set-Location $OutDir
$log = Join-Path $OutDir "git.log"
"== git init ==" | Set-Content $log -Encoding UTF8
(git init 2>&1)  | Add-Content $log -Encoding UTF8
(git branch -M main 2>&1) | Add-Content $log -Encoding UTF8
(git add -A 2>&1) | Add-Content $log -Encoding UTF8
(git commit -m "AppGrowing competitor creative tracker - Epic Stickman Idle RPG War" 2>&1) | Add-Content $log -Encoding UTF8
"== tracked files ==" | Add-Content $log -Encoding UTF8
(git ls-files 2>&1) | Add-Content $log -Encoding UTF8
"== last commit ==" | Add-Content $log -Encoding UTF8
(git log --oneline -1 2>&1) | Add-Content $log -Encoding UTF8
