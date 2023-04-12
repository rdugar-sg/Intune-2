# Restart Process using PowerShell 64-bit 
if ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
   try { &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH }
   catch { throw "Failed to start $PSCOMMANDPATH" }
   exit 0
}

$AppExpectedPath = "${env:PROGRAMFILES}\Enfusion\Enfusion.exe"
$AppName = "Enfusion"

if ((Test-Path -Path $AppExpectedPath) -eq $true)
{
    Write-Output "Installed version of $AppName found"
    Write-Output "Update $AppName within the application itself"

} else {

    Write-Output "Installing $AppName"
    Start-Process -FilePath "Enfusion_windows-x64-full.exe" -ArgumentList " -q" -Wait

    # Create shortcut in user's start menu.
    $SourceFilePath = "${env:PROGRAMFILES}\Enfusion\Enfusion.exe"
    $ShortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Enfusion.lnk"

    if ((Test-Path -Path $ShortcutPath) -eq $false) {

        $WSciptObj = New-Object -ComObject ("WScript.Shell")
        $Shortcut = $WSciptObj.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $SourceFilePath
        $Shortcut.Save()

    }
}

    