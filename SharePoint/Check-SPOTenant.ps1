
if (Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable) {
  # TODO: Check if installed by Install_Module.
  #Update-Module -Name Microsoft.Online.SharePoint.PowerShell
} else {
  Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
}

$User = "it@3gcapital.onmicrosoft.com"

# Authentication doesn't exist, calling Get-AuthToken function
if ($null -eq $User -or $User -eq "") {
  $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
  Write-Host
}

$userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
$Tenant = $userUpn.Host
$TenantName = $Tenant.Split('.')[0]

Write-Host "SharePoint Online Management Shell for $TenantName"
Connect-SPOService -Url https://$TenantName-admin.sharepoint.com