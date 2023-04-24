# Run script as 32-bit process on 64-bit clients -> No
# Enforce script signature check and run script silently -> No


$AppExpectedPath = "${env:ProgramFiles}\Dell\CommandUpdate\dcu-cli.exe"
$AppExpectedPath2 = "${env:ProgramFiles(x86)}\Dell\CommandUpdate\dcu-cli.exe"
$AppExpectedVersion = "4.8.0.0" 

#------------------------------------------------------------------------------


if ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    if ((Test-Path -Path $AppExpectedPath2) -eq $false)
    {
        Write-Host "Installation Failed!"
        exit 1 # Application not detected.
    }
    else
    {
        $AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath2).FileVersion
    }
}
else
{
    $AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion
}


if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
    Write-Host "Success! Installed version $AppInstalledVersion is equal or newer than expected version $AppExpectedVersion."
    exit 0 # Application detected.
}
else {
    Write-Host "Failure! Installed version $AppInstalledVersion is older than expected version $AppExpectedVersion."
    exit 1 # Application not detected.
}
