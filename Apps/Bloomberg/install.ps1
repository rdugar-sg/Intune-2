function Get-AppVersion {

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
    
        $Major=$(Get-ChildItem $Path | %{$_.VersionInfo} | Select *).FileVersionRaw.Major
        $Minor= $(Get-ChildItem $Path | %{$_.VersionInfo} | Select *).FileVersionRaw.Minor
        $Build= $(Get-ChildItem $Path | %{$_.VersionInfo} | Select *).FileVersionRaw.Build
        $Revision= $(Get-ChildItem $Path | %{$_.VersionInfo} | Select *).FileVersionRaw.Revision

        return "$Major.$Minor.$Build.$Revision"
    }
    catch {
        Write-Warning -Message "Unable to retrieve version information."
        return "0.0.0.0"
    }
}


# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "C:\blp\Wintrv\wintrv.exe"
$AppName = "Bloomberg Anywhere Terminal"
$AppExpectedVersion = "3114.1.80.1"

if ((Test-Path -Path $AppExpectedPath) -eq $true) {
    Write-Output "Installed version of $AppName found"

    $AppInstalledVersion = GetAppVersion -Path $AppExpectedPath

    if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppDetectionVersion) {
        Write-Output "Installed version $AppInstalledVersion is equal or newer than expected version $AppDetectionVersion"
    }
    else {
        Write-Output "Update $AppName within the application itself"
    }
} else {

    Write-Output "Terminating Office 365 apps prior to installation."

    # Terminating Office applications prior to installation.
    Stop-Process -Name "Outlook" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "Word" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "Excel" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "PowerPnt" -Force -ErrorAction SilentlyContinue

     Write-Output "Installing $AppName"

     Start-Process -FilePath "sotr114_5_80.exe" -ArgumentList ' /s CONN_TYPE=Internet ' -Wait
     
     # Remove desktop icon.
     if ((Test-Path -Path "C:\Users\Public\Desktop\Bloomberg.lnk") -eq $true) {
         Remove-Item -Path "C:\Users\Public\Desktop\Bloomberg.lnk" -Force -ErrorAction SilentlyContinue
     }
}
