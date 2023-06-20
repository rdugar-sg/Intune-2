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

$AppName = "Microsoft SQL Server Management Studio"
$ProcessName = "ssms"


Write-Console -ForegroundColor Yellow "Terminating $AppName"
Get-Process $ProcessName -ea 0 | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Console -ForegroundColor Yellow "Uninstalling $AppName"
Get-Package -Provider Programs -IncludeWindowsInstaller -Name $AppName | Uninstall-Package -Force -ErrorAction SilentlyContinue

##Start-Process "MsiExec.exe" -ArgumentList "/x installer.msi /quiet /norestart" -NoNewWindow -Wait