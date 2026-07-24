<#
  Update-Dashboard.ps1
  Theo dõi creative đối thủ của "Epic Stickman: Idle RPG War" qua AppGrowing Global (skill aggclaw)
  - Gọi API AI-chat cho 4 network, tải creative, cập nhật dashboard.html
  - Chạy được trên Windows PowerShell 5.1+ / PowerShell 7
  Yêu cầu: đặt biến môi trường YOUCLOUD_API_KEY trước khi chạy.
#>

[CmdletBinding()]
param(
  [string]$OutDir = $PSScriptRoot,
  [string]$AnchorGame = "Epic Stickman: Idle RPG War"
)

$ErrorActionPreference = "Stop"
# Ghi toàn bộ output ra run.log để chẩn đoán (console có thể bị ẩn)
try { Start-Transcript -Path (Join-Path $OutDir "run.log") -Force -ErrorAction SilentlyContinue | Out-Null } catch {}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
Write-Host "== Bat dau chay $(Get-Date -Format o) =="
Write-Host "OutDir = $OutDir"
trap { Write-Host "FATAL ERROR: $($_ | Out-String)"; try { Stop-Transcript | Out-Null } catch {}; exit 1 }

# ----- API key -----
$Key = $env:YOUCLOUD_API_KEY
if ([string]::IsNullOrWhiteSpace($Key)) {
  # Dự phòng: đọc từ file apikey.txt cùng thư mục
  $keyFile = Join-Path $OutDir "apikey.txt"
  if (Test-Path $keyFile) { $Key = (Get-Content $keyFile -Raw -Encoding UTF8).Trim() }
}
if ([string]::IsNullOrWhiteSpace($Key)) {
  Write-Host "Chưa đặt YOUCLOUD_API_KEY." -ForegroundColor Red
  Write-Host 'Lấy key ở AppGrowing Global -> Profile -> Enterprise Info, rồi chạy:' -ForegroundColor Yellow
  Write-Host '  setx YOUCLOUD_API_KEY "sk-..."   (mở lại cửa sổ PowerShell sau khi chạy)' -ForegroundColor Yellow
  exit 1
}

$ClawUrl   = "https://ai-chat-global.youcloud.com/aichat/claw"
$MatBase   = "https://ai-chat-global.youcloud.com/aichat/sessions"
$Headers   = @{ Authorization = "Bearer $Key" }
$today     = (Get-Date).ToString("yyyy-MM-dd")

# ----- Các network cần theo dõi -----
$Networks = @(
  @{ id="meta";    label="Facebook / Meta";               hint="Facebook, Instagram, Meta Audience Network, Messenger" },
  @{ id="tiktok";  label="TikTok / Pangle";               hint="TikTok và Pangle" },
  @{ id="unity";   label="Unity / AppLovin / IronSource"; hint="Unity Ads, AppLovin, ironSource, Mintegral, Vungle" },
  @{ id="youtube"; label="YouTube / AdMob";               hint="YouTube và Google AdMob" }
)

$mediaRoot = Join-Path $OutDir "media"
New-Item -ItemType Directory -Force -Path $mediaRoot | Out-Null

function Get-MediaType($url) {
  $u = ($url -split '\?')[0].ToLower()
  if ($u -match '\.(mp4|mov|webm|m4v)$') { return @{ type="video"; ext=($u -replace '.*\.','') } }
  if ($u -match '\.(jpg|jpeg|png|gif|webp)$') { return @{ type="image"; ext=($u -replace '.*\.','') } }
  return @{ type="video"; ext="mp4" }  # mặc định
}

function Invoke-Claw($PromptText, $mode) {
  # LƯU Ý: không đặt tên tham số là $input ($input là biến tự động của PowerShell)
  $payload = @{ input = $PromptText; chat_mode = $mode } | ConvertTo-Json -Compress
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
  $resp = Invoke-WebRequest -Uri $ClawUrl -Method Post -Headers $Headers `
          -ContentType "application/json; charset=utf-8" -Body $bytes -TimeoutSec 600 -UseBasicParsing
  $json = [System.Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray())
  return ($json | ConvertFrom-Json)
}

function Get-Materials($sessionId) {
  $enc = [uri]::EscapeDataString($sessionId)
  $resp = Invoke-WebRequest -Uri "$MatBase/$enc/materials" -Headers $Headers -TimeoutSec 120 -UseBasicParsing
  $json = [System.Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray())
  return ($json | ConvertFrom-Json)
}

$entries = @()

foreach ($n in $Networks) {
  Write-Host "==> Network: $($n.label)" -ForegroundColor Cyan
  $prompt = @"
Phân tích quảng cáo (ad creative) MỚI NHẤT của các GAME ĐỐI THỦ CẠNH TRANH với "$AnchorGame" (cùng thể loại stickman idle RPG) đang chạy trên $($n.hint).
CỰC KỲ QUAN TRỌNG: TUYỆT ĐỐI KHÔNG lấy, KHÔNG liệt kê, KHÔNG phân tích quảng cáo của chính "$AnchorGame". Chỉ lấy creative của các game KHÁC (của nhà phát hành khác) cùng thể loại. Nếu một creative thuộc về "$AnchorGame" thì bỏ qua.
Yêu cầu:
- Liệt kê tên từng game đối thủ (khác "$AnchorGame") kèm nhà phát hành, và các creative nổi bật của họ trên network này.
- Với mỗi creative: nêu hook 3 giây đầu, hình thức (video/playable/in-feed...), và điểm đáng học hỏi.
- Kết luận ngắn về xu hướng creative đang thắng trên network này.
Trả lời bằng tiếng Việt CÓ DẤU đầy đủ, trình bày rõ ràng theo từng đối thủ.

Ở CUỐI câu trả lời, xuất THÊM một khối JSON là MẢNG các đối thủ trên network này. Đặt khối đó GIỮA hai dòng đánh dấu riêng biệt: một dòng chỉ ghi ===JSON=== ở trên, và một dòng chỉ ghi ===ENDJSON=== ở dưới. Mỗi phần tử của mảng gồm ĐÚNG các khóa: game, publisher, creatives (số nguyên ước lượng), hook (hook 3s chủ đạo), format (định dạng chính), region (khu vực nhắm tới), why (vì sao hiệu quả, ngắn gọn). CHỈ gồm game đối thủ, KHÔNG gồm "$AnchorGame".
"@
  try {
    $res = Invoke-Claw -PromptText $prompt -mode 7
    $analysis  = [string]$res.output
    $sessionId = [string]$res.session_id
    $mats = @()

    # Tách khối JSON đối thủ (nếu có) khỏi phần phân tích
    $competitors = @()
    $mjson = [regex]::Match($analysis, '(?s)===JSON===\s*(.*?)\s*===ENDJSON===')
    if ($mjson.Success) {
      try { $competitors = @($mjson.Groups[1].Value | ConvertFrom-Json) } catch { $competitors = @() }
      $analysis = ($analysis -replace '(?s)===JSON===.*?===ENDJSON===', '').Trim()
    }

    if ($sessionId) {
      try {
        $rawMats = Get-Materials $sessionId
        # Giới hạn: ưu tiên creative được AI nhấn mạnh, tối đa 40/network (cho job hằng ngày)
        $MaxPerNetwork = 40
        $rawMats = @($rawMats | Sort-Object @{ Expression = { if ($_.is_mentioned) { 0 } else { 1 } } } | Select-Object -First $MaxPerNetwork)
        Write-Host "    Chọn $($rawMats.Count) creative để tải (ưu tiên AI nhấn mạnh)." -ForegroundColor DarkCyan
        $dir = Join-Path (Join-Path $mediaRoot $today) $n.id
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $i = 0
        foreach ($m in $rawMats) {
          $i++
          $info = Get-MediaType $m.download_url
          $rel  = "media/$today/$($n.id)/$($m.id).$($info.ext)"
          $abs  = Join-Path $OutDir $rel
          $ok = $false
          for ($try=0; $try -lt 2 -and -not $ok; $try++) {
            try {
              Invoke-WebRequest -Uri $m.download_url -OutFile $abs -TimeoutSec 180 -UseBasicParsing
              $ok = $true
            } catch {
              # link CDN có thể hết hạn (403) -> lấy lại materials rồi thử lại
              Start-Sleep -Milliseconds 400
              try { $rawMats = Get-Materials $sessionId; $m = $rawMats | Where-Object { $_.id -eq $m.id } | Select-Object -First 1 } catch {}
            }
          }
          $mats += [pscustomobject]@{
            id           = $m.id
            detail_url   = $m.detail_url
            is_mentioned = [bool]$m.is_mentioned
            media        = $(if ($ok) { $rel } else { $null })
            type         = $info.type
          }
          if ($i % 3 -eq 0) { Start-Sleep -Milliseconds 200 }  # nhẹ tay với CDN
        }
        Write-Host "    Tải $($mats.Count) creative." -ForegroundColor Green
      } catch {
        Write-Host "    Không lấy được materials: $($_.Exception.Message)" -ForegroundColor Yellow
      }
    }

    $entries += [pscustomobject]@{
      date         = $today
      network      = $n.id
      networkLabel = $n.label
      analysis     = $analysis
      session_id   = $sessionId
      materials    = $mats
      competitors  = $competitors
    }
  } catch {
    Write-Host "    LỖI network $($n.id): $($_.Exception.Message)" -ForegroundColor Red
    $entries += [pscustomobject]@{
      date=$today; network=$n.id; networkLabel=$n.label
      analysis="⚠️ Lỗi khi gọi API hôm nay: $($_.Exception.Message)"; session_id=""; materials=@(); competitors=@()
    }
  }
}

# ----- Gộp vào data.json (thay thế bản ghi cùng ngày + cùng network) -----
$dataFile = Join-Path $OutDir "data.json"
$all = @()
if (Test-Path $dataFile) {
  try {
    $prev = Get-Content $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($prev.entries) { $all = @($prev.entries) }
  } catch { $all = @() }
}
# Chỉ giữ entry hợp lệ (có date + network); loại bản ghi trùng ngày+network hôm nay
$all = @($all | Where-Object { $_.date -and $_.network -and -not ($_.date -eq $today -and ($Networks.id -contains $_.network)) })
$all += $entries

# ----- TL;DR tổng hợp cả 4 network -----
Write-Host "==> TL;DR" -ForegroundColor Cyan
$tldr = @()
try {
  $tldrPrompt = "Du lieu context: game goc la $AnchorGame. Dua tren xu huong quang cao cua cac game DOI THU (KHONG phai game goc) the loai stickman idle RPG tren Facebook/Meta, TikTok/Pangle, Unity/AppLovin/IronSource va YouTube/AdMob trong 30 ngay qua, neu 3-5 xu huong CREATIVE noi bat nhat ma doi creative nen hoc. Moi y mot dong bat dau bang '- '. Tra loi tieng Viet CO DAU day du, ngan gon."
  $tres = Invoke-Claw -PromptText $tldrPrompt -mode 9
  $ttxt = [string]$tres.output
  $tldr = @($ttxt -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^[-*•]' } | ForEach-Object { ($_ -replace '^[-*•]\s*', '').Trim() })
  if ($tldr.Count -eq 0 -and -not [string]::IsNullOrWhiteSpace($ttxt)) { $tldr = @($ttxt.Trim()) }
  Write-Host "    TL;DR: $($tldr.Count) ý"
} catch {
  Write-Host "    Lỗi TL;DR: $($_.Exception.Message)" -ForegroundColor Yellow
}

$store = [pscustomobject]@{
  anchor    = $AnchorGame
  generated = (Get-Date).ToString("s")
  tldr      = @($tldr)
  networks  = @($Networks | ForEach-Object { [pscustomobject]@{ id=$_.id; label=$_.label } })
  entries   = @($all)
}
($store | ConvertTo-Json -Depth 8) | Set-Content -Path $dataFile -Encoding UTF8

# ----- Render dashboard.html từ template -----
$tpl = Join-Path $OutDir "dashboard.template.html"
$out = Join-Path $OutDir "dashboard.html"
$dataJson = ($store | ConvertTo-Json -Depth 8)
$inject = "const DATA = $dataJson;"
(Get-Content $tpl -Raw -Encoding UTF8).Replace("/*__DATA__*/", $inject) | Set-Content -Path $out -Encoding UTF8

Write-Host ""
Write-Host "Xong. Mở dashboard: $out" -ForegroundColor Green
try { Stop-Transcript | Out-Null } catch {}
