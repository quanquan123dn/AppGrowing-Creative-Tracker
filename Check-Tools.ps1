$ErrorActionPreference = "Continue"
$out = Join-Path $PSScriptRoot "tools.log"
$L = @()
$L += "git: "     + ((git --version 2>&1)     -join ' ')
$L += "gh: "      + ((gh --version 2>&1 | Select-Object -First 1) -join ' ')
$L += "ghauth: "  + ((gh auth status 2>&1)    -join ' || ')
$L += "vercel: "  + ((vercel --version 2>&1)  -join ' ')
$L += "email: "   + ((git config user.email 2>&1) -join ' ')
$L += "name: "    + ((git config user.name 2>&1)  -join ' ')
$L | Set-Content -Path $out -Encoding UTF8
