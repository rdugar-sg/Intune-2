# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Unins000.exe"
$AppName = "Visual Studio Code"
if ((Test-Path -Path $AppExpectedPath) -eq $true) {
    Write-Output "Uninstalling $AppName"
    Stop-Process -Name "Code" -Force -ErrorAction SilentlyContinue
    Start-Process -FilePath "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Unins000.exe" -ArgumentList " /VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS" -Wait
} else {
    Write-Output "$AppName not detected on this device"
}
