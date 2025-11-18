# ===================================================================
# SCRIPT 1: System Phase - Cài đặt Updates với kiểm tra lặp lại
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
    
    # Vòng lặp kiểm tra và cài đặt updates
    $MaxIterations = 3
    $Iteration = 0
    
    do {
        $Iteration++
        Write-Host "`n==================== Vòng lặp $Iteration/$MaxIterations ====================" -ForegroundColor Cyan
        
        # Quét updates có sẵn
        Write-Host "Đang quét updates..." -ForegroundColor Yellow
        $Updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot
        
        if ($Updates.Count -eq 0) {
            Write-Host "Không có updates nào cần cài đặt" -ForegroundColor Green
            break
        }
        
        Write-Host "Tìm thấy $($Updates.Count) updates. Đang cài đặt..." -ForegroundColor Yellow
        
        # Cài đặt updates
        Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose
        
        Write-Host "Hoàn tất vòng lặp $Iteration" -ForegroundColor Green
        Start-Sleep -Seconds 5
        
    } while ($Iteration -lt $MaxIterations)
    
    # Kiểm tra xem có cần reboot không
    $RebootRequired = (Get-WURebootStatus -Silent)
    if ($RebootRequired) {
        Write-Host "`nCần reboot để hoàn tất cập nhật" -ForegroundColor Yellow
        Set-Content -Path "C:\Windows\Temp\RebootRequired.flag" -Value "1"
    } else {
        Write-Host "`nKhông cần reboot" -ForegroundColor Green
    }
    
    Write-Host "`nHoàn tất toàn bộ quá trình cập nhật Windows!" -ForegroundColor Green
    
} catch {
    Write-Host "Lỗi: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    Stop-Transcript
}
