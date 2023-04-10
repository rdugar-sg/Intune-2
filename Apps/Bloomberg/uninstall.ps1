# Restart Process using PowerShell 64-bit 
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   Try {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   Catch {
      Throw "Failed to start $PSCOMMANDPATH"
   }
   Exit
}

$AppName = "Bloomberg Terminal*"

$LocalKey       = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
$MachineKey     = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
$MachineKey6432 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
[array]$Keys = Get-ItemProperty -Path @($MachineKey6432, $MachineKey, $LocalKey) -ErrorAction SilentlyContinue

[array]$MatchingKeys = $Keys | Select-Object DisplayName, DisplayVersion, UninstallString, PSChildName | Where-Object { $_.DisplayName -like $AppName }

if ($MatchingKeys.Length -lt 1) {

    Write-Output "Application is not found"

} else {

    foreach ($Key in $MatchingKeys) {

        Write-Output "uninstalling $($Key.DisplayName)"
        Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($Key.PSChildName) /qn" -Wait
    }
}
