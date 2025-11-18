# ===================================================================
# SCRIPT 2: UserOnce Phase - Hỏi Reboot (Tiếng Anh)
# ===================================================================
# Copy script này vào phần "UserOnce" scripts

Add-Type -AssemblyName PresentationFramework

# Hiển thị dialog hỏi user về reboot
$Result = [System.Windows.MessageBox]::Show(
    "Windows Update has been completed.`n`nYour computer needs to restart to finish applying updates.`n`nDo you want to restart now?",
    "Restart Computer",
    [System.Windows.MessageBoxButton]::YesNo,
    [System.Windows.MessageBoxImage]::Question
)

if ($Result -eq 'Yes') {
    Write-Host "Restarting computer..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    Restart-Computer -Force
} else {
    Write-Host "Restart skipped. You can restart manually later." -ForegroundColor Green
    [System.Windows.MessageBox]::Show(
        "You can restart your computer later when you're ready.",
        "Information",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
}
