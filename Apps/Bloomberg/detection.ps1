[CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    try {
        if ((Test-Path -Path $Path) -ne $true) {
            return "0.0.0.0"
        }
    
        $Major=$(Get-ChildItem $Path | %{$_.VersionInfo} | Select-Object *).FileVersionRaw.Major
        $Minor= $(Get-ChildItem $Path | %{$_.VersionInfo} | Select-Object *).FileVersionRaw.Minor
        $Build= $(Get-ChildItem $Path | %{$_.VersionInfo} | Select-Object *).FileVersionRaw.Build
        $Revision= $(Get-ChildItem $Path | %{$_.VersionInfo} | Select-Object *).FileVersionRaw.Revision

        return "$Major.$Minor.$Build.$Revision"
    }
    catch {
        Write-Warning -Message "Unable to retrieve version information."
        return "0.0.0.0"
    }
}

$AppExpectedPath = "C:\blp\Wintrv\wintrv.exe"
$AppName = "Bloomberg Anywhere Terminal"
$AppExpectedVersion = "3114.1.80.0" 

#------------------------------------------------------------------------------

if ((Test-Path -Path $AppExpectedPath) -eq $false)
{
    Write-Output "Installation of $AppName not found"
    exit 1 # Application not detected.
}

$AppInstalledVersion = GetAppVersion -Path $AppExpectedPath

if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppExpectedVersion) {
    Write-Output "Success! The installed version of $AppName $AppInstalledVersion is equal or newer than expected version $AppExpectedVersion."
    exit 0 # Application detected.
}
else {
    Write-Output "Failure! The installed $AppName version $AppInstalledVersion is older than expected version $AppExpectedVersion."
    exit 1 # Application not detected.
}