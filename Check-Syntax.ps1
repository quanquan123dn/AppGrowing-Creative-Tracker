$out = Join-Path $PSScriptRoot "syntax.log"
$p = Join-Path $PSScriptRoot "Update-Dashboard.ps1"
$errs = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$null, [ref]$errs)
$res = @()
if ($errs) {
  foreach ($e in $errs) {
    $res += ("Line {0} Col {1}: {2}" -f $e.Extent.StartLineNumber, $e.Extent.StartColumnNumber, $e.Message)
    $res += ("   >> " + $e.Extent.Text)
  }
} else { $res += "OK" }
$res | Set-Content -Path $out -Encoding UTF8
