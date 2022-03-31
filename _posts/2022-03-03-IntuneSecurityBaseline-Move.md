---
title: How to easily move MDM Security Baseline profile
categories:

    - Intune

tags:

    - Intune
    - Powershell
    - MicrosoftEdge

excerpt: This is a game changer for me 😲

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Hey! My previous post was about moving `Settings Catalog` profile between MEM tenants - [How to easily move Settings Catalog profile
](https://universecitiz3n.tech/powershell/SettingsCatalog-Move/)

If you found it useful and it helped you save a lot of time this one you will love too 🥰

# Microsoft Security Baselines

What are MDM Security Baselines? 🔐

Security baselines are groups of pre-configured Windows (or Edge or Office) settings that help you apply and enforce granular security settings that are recommended by the relevant security teams. You can also customize each baseline you deploy to enforce only those settings and values you require. When you create a security baseline profile in Intune, you're creating a template that consists of multiple device configuration profiles.

This feature applies to:

* Windows 10 version 1809 and later
* Windows 11

You deploy security baselines to groups of users or devices in Intune, and the settings apply to devices that run Windows 10/11. For example, the MDM Security Baseline automatically enables BitLocker for removable drives, automatically requires a password to unlock a device, automatically disables basic authentication, and more. When a default value doesn't work for your environment, customize the baseline to apply the settings you need.

[Read more](https://docs.microsoft.com/en-us/mem/intune/protect/security-baselines)

To create a new baseline for your organization go to MEM portal

![MDM1]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/1.png)

Choose baseline area (let's stick with Win 10)

![MDM2]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/2.png)

![MDM3]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/3.png)

Enter profile name, description and continue.

For presentation purposes I've changed one setting and the rest is left as Microsoft recommends.

![MDM4]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/4.png)

Assign profile

![MDM5]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/5.png)

In summary you will see only the list of settings that are changed. So if you take baseline 'as is' then no setting will be listed in summary.

![MDM6]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/6.png)

![MDM7]({{ site.url }}/assets/images/posts/2022-03-03-MDMSec/7.png)

# Read profile settings

As I described in previous post, `Settings Catalog` profile details are stored in body of request whenever you edit or create it.

[Check here](https://universecitiz3n.tech/powershell/SettingsCatalog-Move/#move-settings-catalog-profile)

MDM Security baseline MS Graph requests works a little bit different. Thanks to almighty 💪 Edge DevTools I was able to figure it out!

First of all you need to get all settings categories from security baseline template.

```powershell
$Categories = Invoke-RestMethod -UseBasicParsing -Uri 'https://graph.microsoft.com/beta/deviceManagement/templates/034ccd46-190c-4afc-adf1-ad7cc11262eb/categories'
  -WebSession $session `
  -Headers $Header 
```

With this now you will be able to read values for each setting in discovered categories.
You need:

* Intent ID - MDM Security baseline profile GUID
* Category ID - GUID of category from code above

Using this simple loop you will read entire baseline profile which later can be used as an input for create/update request.

```powershell
# YOUR PROFILE GUID
$Intent = '1c2097b1-409b-4a95-8654-cb1bdd8ca7c5'

$Settings = foreach ($Setting in $Categories.value) {
    $SettingInstanceValues = Invoke-RestMethod -UseBasicParsing -Uri "https://graph.microsoft.com/beta/deviceManagement/intents/$Intent/categories/$($Setting.id)/settings?`$expand=Microsoft.Graph.DeviceManagementComplexSettingInstance/Value" `
        -WebSession $session `
        -Headers $Header

    foreach ($SettingValue in $SettingInstanceValues.value) {
        $SettingValue
    }
}
```

Now we have values for every single setting within Windows 10 MDM Security Baseline! 😎🎉

# Move MDM Security Baseline profile

When creating or updating MDM Security Baseline profile in `Body` of request you need to specify list of settings and values you wish to set.

First step we've got covered - read security baseline profile (from test tenant 😉)

Second step create production profile:

```powershell
#Create a new profile
$SettingsJSON = $Settings | ConvertTo-Json -Depth 99
$ProfileName = 'Global_Win10'

$Create = Invoke-RestMethod -UseBasicParsing -Uri 'https://graph.microsoft.com/beta/deviceManagement/templates/034ccd46-190c-4afc-adf1-ad7cc11262eb/createInstance' `
 -Method 'POST' `
 -WebSession $session `
 -Headers $Header `
 -ContentType 'application/json' `
 -Body "{`"displayName`":`"$ProfileName`",`"description`":`"`",`"settingsDelta`":$SettingsJSON,`"roleScopeTagIds`":[`"0`"]}"

```

or update existing:

```powershell
#Update profile
$SettingsJSON = $Settings | ConvertTo-Json -Depth 99
$IntentID = '1c2097b1-409b-4a95-8654-cb1bdd8ca7c5'

$ApplySettings = Invoke-RestMethod -UseBasicParsing -Uri "https://graph.microsoft.com/beta/deviceManagement/intents/$IntentID/updateSettings" `
  -Method 'POST' `
  -WebSession $session `
  -Headers $Header `
  -ContentType 'application/json' `
  -Body "{`"settings`":$SettingsJSON}"
```

And that's it!! 🪄🤝😁

# Summary

With this and previous post I feel more and more confidence that Infrastructure as Code in regards of Intune configurations is project that I should look into.

See you in next! 😉 🧠
