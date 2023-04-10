# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe"
$AppName = "Visual Studio Code"
$AppExpectedVersion = "1.77.1.0" 

if ((Test-Path -Path $AppExpectedPath) -eq $true)
{
    Write-Output "Installed version of $AppName found"
    $AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion

    if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
        Write-Output "Installed version $AppInstalledVersion is equal or newer than expected version $AppDetectionVersion"
    }
    else {
        Write-Output "Update $AppName within the application itself"
    }
} else {
    Write-Output "Installing $AppName"
    Start-Process -FilePath "VSCodeUserSetup-x64-1.77.1.exe" -ArgumentList " /VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /MERGETASKS=!runcode,!desktopicon" -WindowStyle Hidden -Wait 
}

    
