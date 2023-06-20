# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio 19\Common7\IDE\Ssms.exe"
$AppName = "Microsoft SQL Server Management Studio"
$AppExpectedVersion = "2023.160.20209.0"

if ((Test-Path -Path $AppExpectedPath) -eq $true)
{
    Write-Output "Installed version of $AppName found"
    $AppInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AppExpectedPath).FileVersionRaw

    if ([System.Version]$AppInstalledVersion -ge [System.Version]$AppExpectedVersion) 
    {
        Write-Output "Installed version $AppInstalledVersion is equal or newer than expected version $AppExpectedVersion."
        exit 0 # Application detected.
    }
    else
    {
        Write-Output "Installed version $AppInstalledVersion is older than expected version $AppExpectedVersion."

        Write-Output "Installing $AppName"
        Start-Process -FilePath "SSMS-Setup-ENU.exe" -ArgumentList " /Install /Quiet SSMSInstallRoot=`"${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio 19`"" -NoNewWindow -Wait
	}    
} 
else 
{
    Write-Output "Installing $AppName"
    Start-Process -FilePath "SSMS-Setup-ENU.exe" -ArgumentList " /Install /Quiet SSMSInstallRoot=`"${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio 19`"" -NoNewWindow -Wait
}