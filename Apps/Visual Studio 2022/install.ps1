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

$RootPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Source = "$RootPath\"

Set-ExecutionPolicy -Scope CurrentUser Bypass -Force

Write-Host -ForegroundColor Cyan "Installing Microsoft Visual Studio 2022 Community Edition."
$exitCode = (Start-Process -Wait -NoNewWindow -PassThru -FilePath "$($Source)vs_community.exe" -ArgumentList " --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.Python --add Microsoft.VisualStudio.Workload.NetCrossPlat --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Universal --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Component.Git --includeRecommended --passive --norestart").ExitCode
Write-Host -ForegroundColor Cyan "Installation finished with exit code $exitCode."



#PowerShell -NoProfile -ExecutionPolicy Bypass -Command "%~dp0vs_community.exe --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.Python --add Microsoft.VisualStudio.Workload.NetCrossPlat --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Universal --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Component.Git --includeRecommended --passive --norestart"



#vs_community.exe --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.Python --add Microsoft.VisualStudio.Workload.NetCrossPlat --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Component.Git --includeRecommended --passive --norestart --wait


#vs_community.exe uninstall --quiet

#vs_community.exe --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.Python --add Microsoft.VisualStudio.Workload.NetCrossPlat --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.Office --add Microsoft.VisualStudio.Component.Git --add Microsoft.VisualStudio.ComponentGroup.WindowsAppSDK.Cs --includeRecommended --passive --norestart --wait








