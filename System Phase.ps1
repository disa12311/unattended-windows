# ===================================================================
# SCRIPT 1: System Phase - Cài đặt Updates (Không Auto Reboot)
# ===================================================================
# Copy script này vào phần "System" scripts

Write-Host "Bắt đầu cập nhật Windows..." -ForegroundColor Green

# Tạo log file
$LogPath = "C:\Windows\Temp\WindowsUpdate.log"
Start-Transcript -Path $LogPath -Append

try {
    # Cài đặt PSWindowsUpdate module nếu chưa có
    Write-Host "Kiểm tra PSWindowsUpdate module..." -ForegroundColor Yellow
    
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Cài đặt PSWindowsUpdate module..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    }
    
    # Import module
    Import-Module PSWindowsUpdate
    
    # Bật Windows Update service
    Write-Host "Bật Windows Update service..." -ForegroundColor Yellow
    Set-Service -Name wuauserv -StartupType Manual
    Start-Service -Name wuauserv
    
    # Quét và cài đặt tất cả updates (KHÔNG tự động reboot)
    Write-Host "Đang quét updates..." -ForegroundColor Yellow
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose
    
    # Lưu trạng thái reboot cần thiết
    $RebootRequired = (Get-WURebootStatus -Silent)
    if ($RebootRequired) {
        Write-Host "Cần reboot để hoàn tất cập nhật" -ForegroundColor Yellow
        Set-Content -Path "C:\Windows\Temp\RebootRequired.flag" -Value "1"
    }
    
    Write-Host "Hoàn tất cập nhật Windows!" -ForegroundColor Green
    
} catch {
    Write-Host "Lỗi: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    Stop-Transcript
}
