
$AppExpectedPath = "${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe"
$AppExpectedVersion = "4.8.0.0" 

#------------------------------------------------------------------------------

$AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion

if ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    Write-Host "Installation Failed!"
    exit 1 # Application not detected.
}


if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
    Write-Host "Success! Installed version $AppInstalledVersion is equal or newer than expected version $AppDetectionVersion."
    exit 0 # Application detected.
}
else {
    Write-Host "Failure! Installed version $AppInstalledVersion is older than expected version $AppDetectionVersion."
    exit 1 # Application not detected.
}