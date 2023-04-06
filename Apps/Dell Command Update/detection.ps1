
$AppExpectedPath = "${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe"
$AppName = "Dell Command Update"
$AppExpectedVersion = "4.8.0.0" 

#------------------------------------------------------------------------------

$AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion

f ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    Write-Output "Installation of $AppName failed"
    exit 1 # Application not detected.
}


if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
    Write-Output "Success! The installed version of $AppName $AppInstalledVersion is equal or newer than expected version $AppInstalledVersion"
    exit 0 # Application detected.
}
else {
    Write-Output "Failure! The installed $AppName version $AppInstalledVersion is older than expected version $AppInstalledVersion"
    exit 1 # Application not detected.
}
