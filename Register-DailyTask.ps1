<#
  Register-DailyTask.ps1
  Đăng ký Windows Task Scheduler chạy Update-Dashboard.ps1 mỗi ngày.
  Chạy PowerShell "as Administrator" rồi:  .\Register-DailyTask.ps1 -Time "08:00"
#>
param(
  [string]$Time = "08:00",                       # giờ chạy hằng ngày (HH:mm)
  [string]$TaskName = "AppGrowing Creative Tracker"
)

$script = Join-Path $PSScriptRoot "Update-Dashboard.ps1"
if (-not (Test-Path $script)) { Write-Error "Không thấy Update-Dashboard.ps1"; exit 1 }

$action  = New-ScheduledTaskAction -Execute "powershell.exe" `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" `
  -WorkingDirectory $PSScriptRoot
$trigger = New-ScheduledTaskTrigger -Daily -At $Time
$set     = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Hours 2)
$princ   = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
  -Settings $set -Principal $princ -Force | Out-Null

Write-Host "Đã đăng ký task '$TaskName' chạy mỗi ngày lúc $Time." -ForegroundColor Green
Write-Host "LƯU Ý: YOUCLOUD_API_KEY phải được đặt ở cấp User/System (dùng setx) để task thấy được key." -ForegroundColor Yellow
Write-Host "Gỡ task:  Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor DarkGray
