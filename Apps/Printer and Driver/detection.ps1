$PrinterName = "TOSHIBA e-STUDIO5516AC"
$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\"

if ((Test-Path -Path "$RegistryPath$PrinterName") -eq $false)
{
    Write-Output "Installation of $PrinterName not found"
    exit 1 # Application not detected.
}

Write-Output "Success! $PrinterName is installed."
exit 0 # Application detected.