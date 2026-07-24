# Theo dõi Creative đối thủ — Epic Stickman: Idle RPG War

Tự động lấy creative quảng cáo của các game đối thủ (thể loại *stickman idle RPG*) từ **AppGrowing Global** cho **4 network** (Facebook/Meta, TikTok/Pangle, Unity/AppLovin/IronSource, YouTube/AdMob), rồi dựng thành **một dashboard HTML** cập nhật mỗi ngày.

## Trạng thái hiện tại
- ✅ Đã chạy thành công: 4 network × 40 creative nổi bật/network (ưu tiên cái AI nhấn mạnh).
- ✅ Đã đặt **lịch tự động chạy 08:00 mỗi ngày** (Windows Task Scheduler, tên task: `AppGrowing Creative Tracker`).
- ✅ API key lưu ở `apikey.txt` (script tự đọc, không cần thiết lập gì thêm).
- 📊 Mở **`dashboard.html`** bằng trình duyệt để xem.

## Cách hoạt động
Mỗi ngày task chạy `Update-Dashboard.ps1`:
1. Gọi API AppGrowing (AI-chat) cho 4 network, hỏi creative mới nhất của đối thủ.
2. Chọn tối đa **40 creative/network**, ưu tiên cái được AI nhấn mạnh, tải video/ảnh về `media/`.
3. Cập nhật `data.json` (tích luỹ theo ngày) và dựng lại `dashboard.html`.

Dashboard có bộ lọc theo **network**, theo **ngày**, và ô **tìm kiếm** trong nội dung phân tích.

## Chạy thủ công (khi cần cập nhật ngay)
Mở **Windows PowerShell** rồi dán:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Desktop\Claude projects\AppGrowing-Creative-Tracker\Update-Dashboard.ps1"
```
> Lưu ý: máy này chặn chạy file `.bat` và "Run with PowerShell" mặc định, nên dùng lệnh trên (có `-ExecutionPolicy Bypass`). Một lần chạy đầy đủ mất ~15–20 phút (API phân tích chậm + tải video).

## Các file
| File | Vai trò |
|------|---------|
| `Update-Dashboard.ps1` | Script chính: gọi API, tải creative, cập nhật dashboard |
| `dashboard.html` | Dashboard xem hằng ngày (tự sinh) |
| `dashboard.template.html` | Khung giao diện (đừng sửa `/*__DATA__*/`) |
| `data.json` | Kho dữ liệu tích luỹ theo ngày (tự sinh) |
| `media/` | Creative đã tải, theo `ngày/network` |
| `apikey.txt` | API key AppGrowing |
| `Register-DailyTask.ps1` | Đăng ký lại lịch (đổi giờ: `-Time "HH:mm"`) |
| `Rebuild-Dashboard.ps1` | Dựng lại dashboard từ data.json có sẵn (không gọi API) |
| `run.log` | Log lần chạy gần nhất (để chẩn đoán) |

## Tuỳ chỉnh
- **Số creative/network**: sửa `$MaxPerNetwork = 40` trong `Update-Dashboard.ps1`.
- **Game gốc / câu hỏi phân tích**: sửa `-AnchorGame` hoặc biến `$prompt`.
- **Đổi giờ chạy**: chạy `Register-DailyTask.ps1 -Time "07:30"` (PowerShell as Admin nếu cần).
- **Gỡ lịch**: `Unregister-ScheduledTask -TaskName 'AppGrowing Creative Tracker' -Confirm:$false`

## Ghi chú
- Nếu một network trả về "hệ thống bận / lỗi tạm thời", đó là lỗi phía API cho lượt đó — lần chạy sau thường tự ổn.
- Creative tải về là file cục bộ nên dashboard xem được offline; link "Chi tiết" mở trang gốc trên AppGrowing.
