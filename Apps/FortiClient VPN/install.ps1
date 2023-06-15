# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "${env:ProgramFiles}\Fortinet\FortiClient\FortiClient.exe"
$AppName = "FortiClient VPN"
$AppExpectedVersion = "7.0.8.0427"

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
        Write-Output "Uninstalling older $AppName version $AppInstalledVersion for a newer version $AppExpectedVersion."
        
	  Get-Process FortiTray -ea 0 | Stop-Process -Force -ErrorAction SilentlyContinue
	  Get-Process FortiSettings -ea 0 | Stop-Process -Force -ErrorAction SilentlyContinue
        Get-Process FortiSSLVPNDaemon -ea 0 | Stop-Process -Force -ErrorAction SilentlyContinue

        $InstalledApp = Get-Package -Name $AppName -RequiredVersion $AppInstalledVersion | Uninstall-Package -Force

        Write-Output "Installing $AppName"
    	  Start-Process "msiexec.exe" -ArgumentList "/i FortiClientVPN.msi REBOOT=ReallySuppress /qn /L*v C:\FortiClientVPN-Install.log" -NoNewWindow -Wait
	  Start-Sleep 5

        $PackageName = "FortiClientVPN"
        $ConfigPW = "3GForti2023"
        Start-Process "C:\Program Files\Fortinet\FortiClient\FCConfig.exe" -ArgumentList "-m vpn -f FortiClientVPN.conf -o importvpn -p $ConfigPW" -NoNewWindow -Wait
    }
} 
else 
{
    Write-Output "Installing $AppName"
    Start-Process "msiexec.exe" -ArgumentList "/i FortiClientVPN.msi REBOOT=ReallySuppress /qn /L*v C:\FortiClientVPN-Install.log" -NoNewWindow -Wait
    Start-Sleep 5

    $PackageName = "FortiClientVPN"
    $ConfigPW = "3GForti2023"
    Start-Process "C:\Program Files\Fortinet\FortiClient\FCConfig.exe" -ArgumentList "-m vpn -f FortiClientVPN.conf -o importvpn -p $ConfigPW" -NoNewWindow -Wait
}
