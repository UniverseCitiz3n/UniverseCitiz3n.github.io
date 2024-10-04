---
title: Compliance Policy Issues - A Deep Dive
categories:
    - Intune
tags:
    - Intune
    - Compliance
    - COPE
excerpt: Learn about the challenges faced while improving compliance policies for COPE devices, and discover a workaround to resolve issues with unexpected settings and inaccurate reports.
comments: true
toc: true
toc_label: Table of contents
---

# Compliance Policy Issues: A Deep Dive 🔍

Recently, I took on the challenge of improving our compliance policies, particularly by breaking them down into distinct configurations for better transparency. This setup aims to make it clear in views and reports which specific policy a device fails to meet. We also tailored email notifications to match each policy individually. However, along the way, some unexpected problems emerged that I want to share.

## The Problem

I observed an issue with compliance policies for COPE (Corporate-Owned, Personally Enabled) devices. Despite clearly defined settings, the reports indicated that policies for devices, particularly under the fully managed, dedicated, and corporate-owned work profile, were reflecting configurations that were never specified during policy creation.

Here's what caught my attention:

- **Devices Status Reporting 'Others'**: 25 devices were shown with a status labeled as 'Others'.
![Compliance Report Status]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image1.png)
- **Password Policy Status 'Not Applicable'**: When I checked compliance information for a test Samsung device, I noticed that the password policy was marked as 'Not applicable'. This aligned with the mysterious 'Others' status for the devices mentioned above.
![Device compliance Report Status]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image2.png)
- **Unexpected Settings in Compliance View**: Upon digging deeper into the password policy on my device, it turned out that in addition to the expected settings, a 'Play Integrity device attestation' setting was being assessed. This was marked as 'Not applicable', leading to the entire policy being considered 'Not applicable' in the previous view.
![Device compliance detail Status]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image3.png)

The most baffling part was the "Per-settings status" in the compliance policy. At the top of this view, there were some empty entries showing 11 compliant devices, and further down, the "Play Integrity" setting showed some devices as compliant and others as 'Not applicable'.

![Per setting]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image4.png)

## Root Cause and Workaround 🛠️

Using PowerShell and Microsoft Graph (check out my post on using Microsoft Edge Dev Tools [here](https://universecitiz3n.tech/powershell/SettingsCatalog-Move/)), I discovered that the compliance policy template for COPE devices had some built-in settings that were fixed by Microsoft, such as:

- `deviceThreatProtectionRequiredSecurityLevel`
- `advancedThreatProtectionRequiredSecurityLevel`
- `passwordRequiredType`
- `deviceThreatProtectionEnabled`
- `securityRequireSafetyNetAttestationBasicIntegrity`
- `securityRequireSafetyNetAttestationCertifiedDevice`

I received confirmation from Microsoft about my discovery, though there's no timeline for when this issue will be resolved. For now, the workaround involves creating compliance policies programmatically from code rather than relying on the default templates.

Below is a PowerShell script I prepared to create a compliance policy for COPE devices. This script helps overcome the built-in limitations by allowing more direct configuration and customization:

```powershell
# Set the authorization header for Graph API
$Headers = @{  
    "Authorization" = "Bearer eyJ0e..."  # Replace with your valid OAuth token
}
$Uri = "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies/"  # Endpoint for device compliance policies

# Define the compliance policy details
$compliancePolicy = [pscustomobject]@{
    displayName              = "DISPLAYNAME"  # Name of the compliance policy
    description              = "DESCRIPTION"  # Description of the compliance policy
    roleScopeTagIds          = @()  # Define role scope tags if any
    "@odata.type"            = "#microsoft.graph.androidDeviceOwnerCompliancePolicy"  # Type of compliance policy
    
    # Define scheduled actions for specific rules
    scheduledActionsForRule  = @(
        [pscustomobject]@{
            ruleName                      = "PasswordRequired"  # Rule to enforce password requirement
            scheduledActionConfigurations = @(
                [pscustomobject]@{
                    actionType                = "block"  # Action to block non-compliant devices
                    gracePeriodHours          = 0  # No grace period
                    notificationTemplateId    = ""  # No notification template assigned
                    notificationMessageCCList = @()  # No additional notifications
                }
            )
        }
    )
    localActions             = @()  # Placeholder for local actions, if any
    
    # Uncomment and configure the following settings as needed:
    # deviceThreatProtectionEnabled                      = $false
    # deviceThreatProtectionRequiredSecurityLevel        = "unavailable"
    # advancedThreatProtectionRequiredSecurityLevel      = "unavailable"
    # securityRequireSafetyNetAttestationBasicIntegrity  = $false
    # securityRequireSafetyNetAttestationCertifiedDevice = $false
    # osMinimumVersion                                   = "11.0"
    # osMaximumVersion                                   = ""
    # minAndroidSecurityPatchLevel                       = "2024-04-01"
    # passwordRequired                                   = $true
    # passwordMinimumLength                              = 6
    # passwordRequiredType                               = "numericComplex"
    # passwordMinutesOfInactivityBeforeLock              = 1
    # passwordExpirationDays                             = 365
    # passwordPreviousPasswordCountToBlock               = 3
    storageRequireEncryption = $true  # Require storage encryption
}

# Convert the compliance policy to JSON
$jsonString = ConvertTo-Json -InputObject $compliancePolicy -Depth 10

# Send the request to create the compliance policy
Invoke-RestMethod -UseBasicParsing -Uri $Uri `
    -Method "POST" `
    -Headers $Headers `
    -ContentType "application/json" `
    -Body $jsonString
```

## Results After Implementing Workaround ✅

- The new compliance policies created from code report the number of devices accurately.
![Fixed compliance Report Status]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image5.png)
![Fixed 2 compliance Report Status]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image6.png)
- The device view now reflects the expected results, showing compliant and non-compliant devices as intended. However, some inconsistencies remain in the "Per-settings status" view, such as empty entries and discrepancies in the status of certain settings, which require further investigation.
![Still not fixed compliance Report Status]({{ site.url }}/assets/images/posts/2024-10-04-Compliance/image7.png)

## Summary 📝

The compliance policy mechanism functions as intended in verifying the specified settings, but the built-in reports provided by Microsoft for COPE policies contain some inaccuracies. For now, manual intervention through custom coding seems to be the best way to overcome these discrepancies.

This experience serves as a reminder: even well-established tools can come with hidden surprises, and sometimes we need to get our hands dirty with PowerShell scripts to make things right. 💪

See you in next! 😉 🧠