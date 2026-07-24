$ErrorActionPreference = "Continue"
$out = Join-Path $PSScriptRoot "vc.log"
$L = @()
$L += "whoami: " + ((vercel whoami 2>&1) -join ' | ')
$L | Set-Content -Path $out -Encoding UTF8
