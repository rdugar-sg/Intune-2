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

$procExists = Get-Process -Name 'FoxitPDFEditor' -ErrorAction SilentlyContinue
if ($procExists) {
   Write-Host -ForegroundColor Yellow "Terminating Foxit PDF Editor process."
   Stop-Process -Name 'FoxitPDFEditor' -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------------
# Uninstall application.
# --------------------------------------------------------
$Apps = @()
$Apps += Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" # 32 Bit
$Apps += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"             # 64 Bit

$SelectedApps = $Apps|Where {$_.DisplayName -like "Foxit PDF Editor*"}
foreach ($App in $SelectedApps) {
   if ($App.BundleProviderKey -eq $null) { continue }

   Write-Host -ForegroundColor Yellow "Uninstalling $($App.DisplayName) - $($App.BundleVersion)"
   $exitCode = (Start-Process -Wait -NoNewWindow -FilePath "$($App.BundleCachePath)" -ArgumentList "/uninstall /clean /quiet" ).ExitCode
   Write-Host -ForegroundColor Cyan "Uninstall finished with exit code $exitCode."
}