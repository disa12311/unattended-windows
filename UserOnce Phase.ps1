# ===================================================================
# SCRIPT 2: UserOnce Phase - Hỏi Reboot
# ===================================================================
# Copy script này vào phần "UserOnce" scripts

Add-Type -AssemblyName PresentationFramework

# Kiểm tra xem có cần reboot không
$FlagPath = "C:\Windows\Temp\RebootRequired.flag"

if (Test-Path $FlagPath) {
    # Hiển thị dialog hỏi user
    $Result = [System.Windows.MessageBox]::Show(
        "Windows Update đã cài đặt xong.`n`nMáy tính cần khởi động lại để hoàn tất cập nhật.`n`nBạn có muốn khởi động lại ngay bây giờ?",
        "Khởi động lại máy tính",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question
    )
    
    # Xóa flag file
    Remove-Item -Path $FlagPath -Force -ErrorAction SilentlyContinue
    
    if ($Result -eq [System.Windows.MessageBoxResult]::Yes) {
        Write-Host "Khởi động lại máy tính..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        Restart-Computer -Force
    } else {
        Write-Host "Bỏ qua khởi động lại. Bạn có thể restart thủ công sau." -ForegroundColor Green
        [System.Windows.MessageBox]::Show(
            "Bạn có thể khởi động lại máy tính sau khi hoàn tất các công việc cần thiết.",
            "Thông báo",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        )
    }
} else {
    Write-Host "Không cần khởi động lại" -ForegroundColor Green
}
