
function Get-AuthToken {
  [cmdletbinding()]
  param
  (
      [Parameter(Mandatory=$true)]
      $User
  )
  
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
  
  [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
  $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$Tenant"
  
  try {
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
    $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$redirectUri,$platformParameters,$userId).Result
    if ($authResult.AccessToken) {
      $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'="Bearer " + $authResult.AccessToken
        'ExpiresOn'=$authResult.ExpiresOn
      }
      return $authHeader
    } else {
      Write-Host
      Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
      Write-Host
      break
    }
  }
  catch {
    write-host $_.Exception.Message -f Red
    write-host $_.Exception.ItemName -f Red
    write-host
    break
  }
}

########################################################################################################

Function Export-JSONData() {
  param (
    $JSON,
    $ExportPath
  )
  
  try {
    if ($JSON -eq "" -or $JSON -eq $null) {
      write-host "No JSON specified, please specify valid JSON..." -f Red
    } elseif (!$ExportPath) {
      write-host "No export path parameter set, please provide a path to export the file" -f Red
    } elseif (!(Test-Path $ExportPath)) {
      write-host "$ExportPath doesn't exist, can't export JSON Data" -f Red
    } else {
      $JSON1 = ConvertTo-Json $JSON -Depth 5
      $JSON_Convert = $JSON1 | ConvertFrom-Json
      $displayName = $JSON_Convert.displayName
      $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"
      #$FileName_JSON = "$DisplayName" + "_" + $(get-date -f dd-MM-yyyy-H-mm-ss) + ".json"
      $FileName_JSON = "$DisplayName" + ".json"
      write-host "Export Path:" "$ExportPath"
      $JSON1 | Set-Content -LiteralPath "$ExportPath\$FileName_JSON"
      write-host "JSON created in $ExportPath\$FileName_JSON..." -f cyan
    }
  }
  catch {
    $_.Exception
  }
}

########################################################################################################

Function Get-DeviceConfigurationPolicy() {
  [cmdletbinding()]
  $graphApiVersion = "Beta"
  $DCP_resource = "deviceManagement/deviceConfigurations"
  try {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}

########################################################################################################

Function Get-SettingsCatalogPolicy() {
  [cmdletbinding()]
  param
  (
   [parameter(Mandatory=$false)]
   [ValidateSet("windows10","macOS")]
   [ValidateNotNullOrEmpty()]
   [string]$Platform
  )
  
  $graphApiVersion = "beta"
  if ($Platform) {
    $Resource = "deviceManagement/configurationPolicies?`$filter=platforms has '$Platform' and technologies has 'mdm'"
  } else {
    $Resource = "deviceManagement/configurationPolicies?`$filter=technologies has 'mdm'"
  }
  
  try {
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}

########################################################################################################

Function Get-SettingsCatalogPolicySettings(){
  [cmdletbinding()]
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      $policyid
  )
  
  $graphApiVersion = "beta"
  $Resource = "deviceManagement/configurationPolicies('$policyid')/settings?`$expand=settingDefinitions"
  
  try {
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    $Response = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get)
    $AllResponses = $Response.value
    $ResponseNextLink = $Response."@odata.nextLink"
    while ($ResponseNextLink -ne $null) {
      $Response = (Invoke-RestMethod -Uri $ResponseNextLink -Headers $authToken -Method Get)
      $ResponseNextLink = $Response."@odata.nextLink"
      $AllResponses += $Response.value
    }
    return $AllResponses
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}

########################################################################################################

Function Get-DeviceCompliancePolicy() {
  [cmdletbinding()]
  param
  (
      [switch]$Android,
      [switch]$iOS,
      [switch]$Win10
  )
  
  $graphApiVersion = "Beta"
  $Resource = "deviceManagement/deviceCompliancePolicies"
      
  try {
    $Count_Params = 0
  
    if ($Android.IsPresent) { $Count_Params++ }
    if ($iOS.IsPresent) { $Count_Params++ }
    if ($Win10.IsPresent) { $Count_Params++ }

    if ($Count_Params -gt 1) {
      write-host "Multiple parameters set, specify a single parameter -Android -iOS or -Win10 against the function" -f Red
    }
    elseif ($Android) {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
      (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("android") }
    }
    elseif ($iOS) {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
      (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("ios") }
    }
    elseif ($Win10) {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
      (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("windows10CompliancePolicy") }
    }
    else {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
      (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    }
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}

########################################################################################################

Function Get-ManagedAppPolicy() {
  [cmdletbinding()]
  param
  (
      $Name
  )
  
  $graphApiVersion = "Beta"
  $Resource = "deviceAppManagement/managedAppPolicies"
  
  try {
    if ($Name) {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
      (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") }
    }
    else {
      $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
      (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("ManagedAppProtection") -or ($_.'@odata.type').contains("InformationProtectionPolicy") }
      }
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}
  
########################################################################################################
  
Function Get-ManagedAppProtection() {
  [cmdletbinding()]
  param (
    [Parameter(Mandatory=$true)]
    $id,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Android","iOS","WIP_WE","WIP_MDM")]
    $OS    
  )
  
  $graphApiVersion = "Beta"
  
  try {
    if ($id -eq "" -or $id -eq $null) {
      write-host "No Managed App Policy id specified, please provide a policy id..." -f Red
      break
    }
    else {
      if ($OS -eq "" -or $OS -eq $null) {
        write-host "No OS parameter specified, please provide an OS. Supported value are Android,iOS,WIP_WE,WIP_MDM..." -f Red
        Write-Host
        break
      } 
      elseif ($OS -eq "Android") {
        $Resource = "deviceAppManagement/androidManagedAppProtections('$id')/?`$expand=apps"
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
      }
      elseif ($OS -eq "iOS") {
        $Resource = "deviceAppManagement/iosManagedAppProtections('$id')/?`$expand=apps"
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
      }
      elseif ($OS -eq "WIP_WE") {
        $Resource = "deviceAppManagement/windowsInformationProtectionPolicies('$id')?`$expand=protectedAppLockerFiles,exemptAppLockerFiles,assignments"
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
      }
      elseif ($OS -eq "WIP_MDM") {
        $Resource = "deviceAppManagement/mdmWindowsInformationProtectionPolicies('$id')?`$expand=protectedAppLockerFiles,exemptAppLockerFiles,assignments"
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
      }
    }
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}
  
########################################################################################################

Function Get-ManagedAppAppConfigPolicy(){

  $graphApiVersion = "Beta"
  $Resource = "deviceAppManagement/targetedManagedAppConfigurations?`$expand=apps"
      
  try {
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value 
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}
  
########################################################################################################
  
Function Get-ManagedDeviceAppConfigPolicy() {

  $graphApiVersion = "Beta"
  $Resource = "deviceAppManagement/mobileAppConfigurations"
  
  try {
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value 
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}
  
########################################################################################################
  
  Function Get-AppBundleID() {
  param (
    $GUID
  )
  
  $graphApiVersion = "Beta"
  $Resource = "deviceAppManagement/mobileApps?`$filter=id eq '$GUID'"
  
  try {
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break
  }
}
  
########################################################################################################
  

########################################################################################################

Function CheckExportPath ()
{
  [cmdletbinding()]
  param
  (
   [parameter(Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [string]$Path
  )

  # If the directory path doesn't exist prompt user to create the directory
  $ExportPath = $Path.replace('"','')

  if (!(Test-Path "$ExportPath")) {
    Write-Host
    Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow

    $Confirm = read-host
    if ($Confirm -eq "y" -or $Confirm -eq "Y") {
      new-item -ItemType Directory -Path "$ExportPath" | Out-Null
      Write-Host
    } else {
      Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
      Write-Host
      break
    }
  }
}

########################################################################################################

write-host "Authenticating to Microsoft Graph..." -ForegroundColor Cyan

# Checking if authToken exists before running authentication
if ($global:authToken) {
  $DateTime = (Get-Date).ToUniversalTime()
  $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes
  if ($TokenExpires -le 0) {
    write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
    write-host
    
    if ($User -eq $null -or $User -eq "") {
      $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
      Write-Host
    }

    $global:authToken = Get-AuthToken -User $User
  }
}

# Authentication doesn't exist, calling Get-AuthToken function
else {
  if ($User -eq $null -or $User -eq "") {
    $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
    Write-Host
  }

  # Getting the authorization token
  $global:authToken = Get-AuthToken -User $User
}

########################################################################################################


#-------------------------------------------------------------------------------------------------------
$DeviceConfigurationExportPath = "C:\Users\patri\OneDrive\Repo\Intune\Policy\Configuration"
CheckExportPath -Path $DeviceConfigurationExportPath

$SettingsCatalogExportPath = "C:\Users\patri\OneDrive\Repo\Intune\Policy\Configuration\Settings Catalog"
CheckExportPath -Path $SettingsCatalogExportPath

$CompliancePolicyExportPath = "C:\Users\patri\OneDrive\Repo\Intune\Policy\Compliance"
CheckExportPath -Path $CompliancePolicyExportPath

$ManagedAppProtectionExportPath = "C:\Users\patri\OneDrive\Repo\Intune\Policy\App\App Protection"
CheckExportPath -Path $ManagedAppProtectionExportPath

$ManagedAppConfigurationExportPath = "C:\Users\patri\OneDrive\Repo\Intune\Policy\App\App Configuration"
CheckExportPath -Path $ManagedAppConfigurationExportPath


#-------------------------------------------------------------------------------------------------------

Write-Host "Starting Device Configuration Policy Export..." -ForegroundColor Cyan

# Filtering out iOS and Windows Software Update Policies
$DCPs = Get-DeviceConfigurationPolicy | Where-Object { ($_.'@odata.type' -ne "#microsoft.graph.iosUpdateConfiguration") -and ($_.'@odata.type' -ne "#microsoft.graph.windowsUpdateForBusinessConfiguration") }
foreach($DCP in $DCPs) {
  write-host "Device Configuration Policy:"$DCP.displayName -f Yellow
  Export-JSONData -JSON $DCP -ExportPath "$DeviceConfigurationExportPath"
  Write-Host
}

#-------------------------------------------------------------------------------------------------------

Write-Host "Starting Device Configuration Policy (Settings Catalog) Export..." -ForegroundColor Cyan

$Policies = Get-SettingsCatalogPolicy
if ($Policies) {
  foreach ($policy in $Policies) {
    Write-Host $policy.name -ForegroundColor Yellow

    $AllSettingsInstances = @()
    $policyid = $policy.id
    $Policy_Technologies = $policy.technologies
    $Policy_Platforms = $Policy.platforms
    $Policy_Name = $Policy.name
    $Policy_Description = $policy.description

    $PolicyBody = New-Object -TypeName PSObject

    Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'name' -Value "$Policy_Name"
    Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'description' -Value "$Policy_Description"
    Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'platforms' -Value "$Policy_Platforms"
    Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'technologies' -Value "$Policy_Technologies"

    # Checking if policy has a templateId associated
    if ($policy.templateReference.templateId) {

        Write-Host "Found template reference" -f Cyan
        $templateId = $policy.templateReference.templateId

        $PolicyTemplateReference = New-Object -TypeName PSObject

        Add-Member -InputObject $PolicyTemplateReference -MemberType 'NoteProperty' -Name 'templateId' -Value $templateId
        Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'templateReference' -Value $PolicyTemplateReference
    }

    $SettingInstances = Get-SettingsCatalogPolicySettings -policyid $policyid
    $Instances = $SettingInstances.settingInstance
    foreach ($object in $Instances) {
      $Instance = New-Object -TypeName PSObject
      Add-Member -InputObject $Instance -MemberType 'NoteProperty' -Name 'settingInstance' -Value $object
      $AllSettingsInstances += $Instance
    }

    Add-Member -InputObject $PolicyBody -MemberType 'NoteProperty' -Name 'settings' -Value @($AllSettingsInstances)

    Export-JSONData -JSON $PolicyBody -ExportPath "$SettingsCatalogExportPath"
    Write-Host
  }
}

#-------------------------------------------------------------------------------------------------------

Write-Host "Starting Device Compliance Policy Export..." -ForegroundColor Cyan

$CPs = Get-DeviceCompliancePolicy
foreach ($CP in $CPs) {
  write-host "Device Compliance Policy:"$CP.displayName -f Yellow
  Export-JSONData -JSON $CP -ExportPath "$CompliancePolicyExportPath"
  Write-Host
}

#-------------------------------------------------------------------------------------------------------

Write-Host "Starting App Protection Policy Export..." -ForegroundColor Cyan

$ManagedAppPolicies = Get-ManagedAppPolicy | ? { ($_.'@odata.type').contains("ManagedAppProtection") }
if ($ManagedAppPolicies) {
  foreach ($ManagedAppPolicy in $ManagedAppPolicies) {
    write-host "Managed App Policy:"$ManagedAppPolicy.displayName -f Yellow
    if ($ManagedAppPolicy.'@odata.type' -eq "#microsoft.graph.androidManagedAppProtection") {
      $AppProtectionPolicy = Get-ManagedAppProtection -id $ManagedAppPolicy.id -OS "Android"
      $AppProtectionPolicy | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value "#microsoft.graph.androidManagedAppProtection"
      Export-JSONData -JSON $AppProtectionPolicy -ExportPath "$ManagedAppProtectionExportPath"
    }
    elseif ($ManagedAppPolicy.'@odata.type' -eq "#microsoft.graph.iosManagedAppProtection") {
      $AppProtectionPolicy = Get-ManagedAppProtection -id $ManagedAppPolicy.id -OS "iOS"
      $AppProtectionPolicy | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value "#microsoft.graph.iosManagedAppProtection"
      Export-JSONData -JSON $AppProtectionPolicy -ExportPath "$ManagedAppProtectionExportPath"
    }
  }
}

#-------------------------------------------------------------------------------------------------------

Write-Host "Starting App Configuration Policy Export..." -ForegroundColor Cyan

$managedAppAppConfigPolicies = Get-ManagedAppAppConfigPolicy
foreach ($policy in $managedAppAppConfigPolicies) {
  write-host "(Managed App) App Configuration Policy:"$policy.displayName -f Yellow
  Export-JSONData -JSON $policy -ExportPath "$ManagedAppConfigurationExportPath"
  Write-Host
}

$managedDeviceAppConfigPolicies = Get-ManagedDeviceAppConfigPolicy
foreach ($policy in $managedDeviceAppConfigPolicies) {
  write-host "(Managed Device) App Configuration  Policy:"$policy.displayName -f Yellow
    
  #If this is an Managed Device App Config for iOS, lookup the bundleID to support importing to a different tenant
  if ($policy.'@odata.type' -eq "#microsoft.graph.iosMobileAppConfiguration") {
    $bundleID = Get-AppBundleID -GUID $policy.targetedMobileApps
    Export-JSONData -JSON $policy -ExportPath "$ManagedAppConfigurationExportPath" -bundleID $bundleID.bundleID
    Write-Host
  }
  else {
    Export-JSONData -JSON $policy -ExportPath "$ManagedAppConfigurationExportPath"
    Write-Host
  }
}

#-------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------

Write-Host
