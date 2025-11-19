Write-Host "Starting Windows Update..." -ForegroundColor Green

$LogPath = "C:\Windows\Temp\WindowsUpdate.log"
Start-Transcript -Path $LogPath -Append

try {
    Write-Host "Installing NuGet provider..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "Configuring PSGallery..." -ForegroundColor Yellow
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    
    Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Yellow
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck -Confirm:$false -ErrorAction Stop
    
    Write-Host "Importing PSWindowsUpdate module..." -ForegroundColor Yellow
    Import-Module PSWindowsUpdate -Force
    
    Write-Host "Starting Windows Update service..." -ForegroundColor Yellow
    Set-Service -Name wuauserv -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    
    $MaxIterations = 3
    $Iteration = 0
    $TotalUpdatesInstalled = 0
    
    do {
        $Iteration++
        Write-Host "`n========== Iteration $Iteration/$MaxIterations ==========" -ForegroundColor Cyan
        
        Write-Host "Scanning for updates..." -ForegroundColor Yellow
        $Updates = @(Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -ErrorAction SilentlyContinue)
        
        if ($Updates.Count -eq 0) {
            Write-Host "No updates found in this iteration" -ForegroundColor Green
            break
        }
        
        Write-Host "Found $($Updates.Count) update(s). Installing..." -ForegroundColor Yellow
        $TotalUpdatesInstalled += $Updates.Count
        
        Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue | Out-Null
        
        Write-Host "Completed iteration $Iteration" -ForegroundColor Green
        
        if ($Iteration -lt $MaxIterations) {
            Write-Host "Waiting before next scan..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        }
        
    } while ($Iteration -lt $MaxIterations)
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Windows Update completed successfully!" -ForegroundColor Green
    Write-Host "Total updates installed: $TotalUpdatesInstalled" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    try {
        if (-not (Get-Module -ListAvailable -Name BurntToast)) {
            Install-Module -Name BurntToast -Force -SkipPublisherCheck -Confirm:$false -ErrorAction Stop
        }
        Import-Module BurntToast -Force
        
        New-BurntToastNotification -Text "Windows Update Completed", "Successfully installed $TotalUpdatesInstalled update(s)." -AppLogo "C:\Windows\System32\@WindowsUpdateToastIcon.png"
        
    } catch {
        Write-Host "Could not display notification" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`nError occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
} finally {
    Stop-Transcript
}

Start-Sleep -Seconds 5
