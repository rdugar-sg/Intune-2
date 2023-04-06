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

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Source = "$PSScriptRoot\"

#Uninstall when exists.
$appExists = Get-CimInstance -Class Win32_Product -Filter "name like 'Dell Command%'" -ErrorAction SilentlyContinue
if ($appExists) {
   Get-CimInstance -Class Win32_Product -Filter "name like 'Dell Command%'" | Invoke-CimMethod -MethodName Uninstall
}