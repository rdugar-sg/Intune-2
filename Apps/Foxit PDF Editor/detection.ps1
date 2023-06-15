$AppExpectedPath = "${env:ProgramFiles(x86)}\Foxit Software\Foxit PDF Editor\FoxitPDFEditor.exe"
$AppName = "Foxit PDF Editor"
$AppExpectedVersion = "12.1.2.15332"

#------------------------------------------------------------------------------

if ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    Write-Output "Installation of $AppName not found"
    exit 1 # Application not detected.
}

$AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion


if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppExpectedVersion) {
    Write-Output "Success! The installed version of $AppName $AppInstalledVersion is equal or newer than expected version $AppExpectedVersion."
    exit 0 # Application detected.
}
else {
    Write-Output "Failure! The installed $AppName version $AppInstalledVersion is older than texpected version $AppExpectedVersion."
    exit 1 # Application not detected.
}