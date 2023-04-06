# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

# Check for existing installation and determine version.
$AppExpectedPath = "${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe"
$AppExpectedVersion = "4.8.0.0" 

$AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion

if ((Test-Path -Path $AppExpectedPath) -eq $true)
{
    if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
        Write-Host "Installed version $AppInstalledVersion is equal or newer than expected version $AppDetectionVersion."
        exit 0 # Application detected.
    }
} else {

    #Uninstall when exists.
    $appExists = Get-CimInstance -Class Win32_Product -Filter "name like 'Dell Command%'" -ErrorAction SilentlyContinue
    if ($appExists) {
        Get-CimInstance -Class Win32_Product -Filter "name like 'Dell Command%'" | Invoke-CimMethod -MethodName Uninstall
    }

    $appExists = Get-CimInstance -Class Win32_Product -Filter "name like 'Dell Command%'" -ErrorAction SilentlyContinue
    if (-not $appExists) {
    Start-Process -FilePath "DCU_Setup_4_8_0.exe" -ArgumentList " /S /v/qn" -Wait
    Start-Sleep(360)
    Start-Process -FilePath "${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList " /configure -scheduleAuto -scheduleAction=DownloadInstallAndNotify -scheduledReboot=60 -autoSuspendBitLocker=enable -silent" -Wait
    }
}