$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

$IP="192.168.72.21"
$DriverName="TOSHIBA Universal Printer 2"
$PrinterName = "TOSHIBA e-STUDIO5516AC"

# Staging the Drivers.
C:\Windows\SysNative\pnputil.exe /add-driver "$psscriptroot\Toshiba\eSf6u.inf" /install

# Installing the Drivers.
Add-PrinterDriver -Name $DriverName

# Install Printerport if port does not exist.
if (-not $portExists) {
    Add-PrinterPort -Name $IP -PrinterHostAddress $IP
}

# Install Printer if driver exist.
$printDriverExists = Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue
if ($printDriverExists) {
    Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $IP    
} else {
    Write-Warning "Toshiba Printer Driver not installed."
}

Start.Sleep(360)
