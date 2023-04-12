
$AppExpectedPath = "${env:PROGRAMFILES}\Enfusion\Enfusion.exe"
$AppName = "Enfusion"

#------------------------------------------------------------------------------

if ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    Write-Output "Failure! Installation of $AppName not found"
    exit 1 # Application not detected.
}
else {
    Write-Output "Success! Installation of $AppName found"
    exit 0 # Application detected.
}
