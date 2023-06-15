# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "${env:ProgramFiles(x86)}\Foxit Software\Foxit PDF Editor\FoxitPDFEditor.exe"
$AppName = "Foxit PDF Editor"
$AppExpectedVersion = "12.1.2.15332"

if ((Test-Path -Path $AppExpectedPath) -eq $true)
{
    Write-Output "Installed version of $AppName found"
    $AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersion

    if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppExpectedVersion) 
    {
        Write-Output "Installed version $AppInstalledVersion is equal or newer than expected version $AppExpectedVersion."
        exit 0 # Application detected.
    }
    else
    {
        Write-Output "Installed version $AppInstalledVersion is older than expected version $AppExpectedVersion."
        Write-Output "Uninstalling older $AppName version $AppInstalledVersion"

        Get-Process FoxitPDFEditor -ea 0 | Stop-Process -Force -ErrorAction SilentlyContinue

        
        $InstalledApp = Get-Package -Name $AppName
        $UninstallSSID = "{$InstalledApp.TagId}"

        Start-Process "MsiExec.exe" -ArgumentList "/uninstall $UninstallSSID /qn /norestart" -NoNewWindow -Wait -ErrorAction SilentlyContinue

        Write-Output "Installing $AppName"
        Start-Process "MsiExec.exe" -ArgumentList "/i FoxitPDFEditor1212.msi TRANSFORMS=FoxitPDFEditor1212_FCT.mst /qn" -NoNewWindow -Wait
    }
} 
else 
{
    Write-Output "Installing $AppName"
    Start-Process "MsiExec.exe" -ArgumentList "/i FoxitPDFEditor1212.msi TRANSFORMS=FoxitPDFEditor1212_FCT.mst /qn" -NoNewWindow -Wait
}