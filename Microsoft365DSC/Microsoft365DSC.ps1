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

if (Get-Module -Name Microsoft365DSC -ListAvailable) {
  #Update-Module Microsoft365DSC -Force
  #Update-M365DSCDependencies
} else {
  Install-Module Microsoft365DSC -Force
  Update-M365DSCDependencies
}


# Getting client credential
$Credential = Get-Credential

$RootPath = "C:\Users\PLuijpers\source\repos\Intune\Microsoft365DSC"

$ComponentName = "AADAdministrativeUnit"
$ExportPath = $RootPath + "\AzureAD\" + $ComponentName
CheckExportPath -Path $ExportPath

Export-M365DSCConfiguration -Components $ComponentName -Path "$ExportPath\$ComponentName" -FileName "$ComponentName.ps1" -Credential $Credential -Mode Full



##, "AADApplication", "AADAttributeSet", "AADAuthenticationContextClassReference", "AADAuthenticationMethodPolicy", "AADAuthenticationMethodPolicyAuthenticator", "AADAuthenticationMethodPolicyEmail", "AADAuthenticationMethodPolicyFido2", "AADAuthenticationMethodPolicySms", "AADAuthenticationMethodPolicySoftware", "AADAuthenticationMethodPolicyTemporary", "AADAuthenticationMethodPolicyVoice", "AADAuthenticationMethodPolicyX509", "AADAuthenticationStrengthPolicy", "AADAuthorizationPolicy", "AADConditionalAccessPolicy", "AADCrossTenantAccessPolicy", "AADCrossTenantAccessPolicyConfigurationDefault", "AADCrossTenantAccessPolicyConfigurationPartner", "AADEntitlementManagementAccessPackage", "AADEntitlementManagementAccessPackageAssignmentPolicy", "AADEntitlementManagementAccessPackageCatalog", "AADEntitlementManagementAccessPackageCatalogResource", "AADEntitlementManagementConnectedOrganization", "AADExternalIdentityPolicy", "AADGroup", "AADGroupLifecyclePolicy", "AADGroupsNamingPolicy", "AADGroupsSettings", "AADNamedLocationPolicy", "AADRoleDefinition", "AADRoleEligibilityScheduleRequest", "AADRoleSetting", "AADSecurityDefaults", "AADSocialIdentityProvider", "AADTenantDetails", "AADTokenLifetimePolicy", "PPTenantIsolationSettings", "PPTenantSettings", "SCAuditConfigurationPolicy", "SCAutoSensitivityLabelPolicy", "SCAutoSensitivityLabelRule", "SCCaseHoldPolicy", "SCCaseHoldRule", "SCComplianceCase", "SCComplianceSearch", "SCComplianceSearchAction", "SCComplianceTag", "SCDeviceConditionalAccessPolicy", "SCDeviceConfigurationPolicy", "SCDLPCompliancePolicy", "SCDLPComplianceRule", "SCFilePlanPropertyAuthority", "SCFilePlanPropertyCategory", "SCFilePlanPropertyCitation", "SCFilePlanPropertyDepartment", "SCFilePlanPropertyReferenceId", "SCFilePlanPropertySubCategory", "SCLabelPolicy", "SCProtectionAlert", "SCRetentionCompliancePolicy", "SCRetentionComplianceRule", "SCRetentionEventType", "SCSecurityFilter", "SCSensitivityLabel", "SCSupervisoryReviewPolicy", "SCSupervisoryReviewRule", "SPOAccessControlSettings", "SPOApp", "SPOBrowserIdleSignout", "SPOHomeSite", "SPOHubSite", "SPOOrgAssetsLibrary", "SPOSearchManagedProperty", "SPOSearchResultSource", "SPOSharingSettings", "SPOSiteDesign", "SPOSiteDesignRights", "SPOSiteScript", "SPOStorageEntity", "SPOTenantCdnEnabled", "SPOTenantCdnPolicy", "SPOTenantSettings", "SPOTheme", "TeamsAppPermissionPolicy", "TeamsAppSetupPolicy", "TeamsAudioConferencingPolicy", "TeamsCallHoldPolicy", "TeamsCallingPolicy", "TeamsCallParkPolicy", "TeamsCallQueue", "TeamsChannel", "TeamsChannelsPolicy", "TeamsClientConfiguration", "TeamsComplianceRecordingPolicy", "TeamsCortanaPolicy", "TeamsDialInConferencingTenantSettings", "TeamsEmergencyCallingPolicy", "TeamsEmergencyCallRoutingPolicy", "TeamsEnhancedEncryptionPolicy", "TeamsEventsPolicy", "TeamsFederationConfiguration", "TeamsFeedbackPolicy", "TeamsFilesPolicy", "TeamsGroupPolicyAssignment", "TeamsGuestCallingConfiguration", "TeamsGuestMeetingConfiguration", "TeamsGuestMessagingConfiguration", "TeamsIPPhonePolicy", "TeamsMeetingBroadcastConfiguration", "TeamsMeetingBroadcastPolicy", "TeamsMeetingConfiguration", "TeamsMeetingPolicy", "TeamsMessagingPolicy", "TeamsMobilityPolicy", "TeamsNetworkRoamingPolicy", "TeamsOnlineVoicemailPolicy", "TeamsOnlineVoicemailUserSettings", "TeamsOnlineVoiceUser", "TeamsOrgWideAppSettings", "TeamsPstnUsage", "TeamsShiftsPolicy", "TeamsTemplatesPolicy", "TeamsTenantDialPlan", "TeamsTenantNetworkRegion", "TeamsTenantNetworkSite", "TeamsTenantNetworkSubnet", "TeamsTenantTrustedIPAddress", "TeamsTranslationRule", "TeamsUnassignedNumberTreatment", "TeamsUpdateManagementPolicy", "TeamsUpgradeConfiguration", "TeamsUpgradePolicy", "TeamsUserCallingSettings", "TeamsUserPolicyAssignment", "TeamsVdiPolicy", "TeamsVoiceRoute", "TeamsVoiceRoutingPolicy", "TeamsWorkloadPolicy") -Credential $Credential