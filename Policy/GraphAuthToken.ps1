$User = "it@3gcapital.onmicrosoft.com"

# Authentication doesn't exist, calling Get-AuthToken function
if ($null -eq $User -or $User -eq "") {
  $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
  Write-Host
}


$userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
$tenant = $userUpn.Host

Write-Host "Checking for AzureAD module..."

$AadModule = Get-Module -Name "AzureAD" -ListAvailable

if ($AadModule -eq $null) {
    Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
    $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
}

if ($AadModule -eq $null) {
    write-host
    write-host "AzureAD Powershell module not installed..." -f Red
    write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
    write-host "Script can't continue..." -f Red
    write-host
    exit
}

if ($AadModule.count -gt 1) {
  $Latest_Version = ($AadModule | select version | Sort-Object)[-1]
  $aadModule = $AadModule | ? { $_.version -eq $Latest_Version.version }
  if ($AadModule.count -gt 1) {
    $aadModule = $AadModule | select -Unique
  }
  $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
  $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
}
else {
  $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
  $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
}
