
$AppExpectedPath = "C:\blp\Wintrv\wintrv.exe"
$AppName = "Bloomberg Anywhere Terminal"
$AppExpectedVersion = "3114.1.80.0" 

#------------------------------------------------------------------------------

$AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion

if ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    Write-Output "Installation of $AppName not found"
    exit 1 # Application not detected.
}


if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
    Write-Output "Success! The installed version of $AppName $AppInstalledVersion is equal or newer than expected version $AppInstalledVersion."
    exit 0 # Application detected.
}
else {
    Write-Output "Failure! The installed $AppName version $AppInstalledVersion is older than expected version $AppInstalledVersion."
    exit 1 # Application not detected.
}