$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

$IP="192.168.72.21"
$DriverName="TOSHIBA Universal Printer 2"
$PrinterName = "TOSHIBA e-STUDIO5516AC"

# Remove the Printer.
Remove-Printer -Name $PrinterName
Start.Sleep(360)

# Remove the Printer Port.
Remove-PrinterPort -Name $IP
Start.Sleep(360)

# Remove the Printer Driver.
Remove-PrinterDriver -Name $DriverName
Start.Sleep(360)
