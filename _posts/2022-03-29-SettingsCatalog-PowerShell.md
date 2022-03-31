---
title: Export, Fix, Import - Settings Catalog
categories:

    - Intune

tags:

    - Powershell
    - Intune

excerpt: At first it looked easy but then...

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Hi there!

In this post I'd like to share how to read **Settings Catalog** profile with Powershell, convert it to digestible JSON format that will allow you to import it back to your tenant or every other!

# Export

At this moment the only option to export any Intune configuration is to use **Microsoft Graph**.
Additionally **Settings Catalog** profiles can be duplicated 🪄.

But why if you would like to create local copy of profiles or move them to another tenant?

I've already done post on fast and easy way to move Settings Catalog using Microsoft Edge and Powershell.
[Read more...](https://universecitiz3n.tech/powershell/SettingsCatalog-Move/)

Fristly we need id's of profiles so let's get that

```powershell
$params = @{
    #Microsoft Intune Powershell
    ClientId = 'd1ddf0e4-d672-4dae-b554-9d5bdfd93547'
    TenantId = 'YOURTENANTNAME.onmicrosoft.com'
    DeviceCode = $true
}
$authHeaders = @{Authorization = (Get-MsalToken @params).CreateAuthorizationHeader()}

$restParam = @{
    Method      = 'Get'
    Uri         = 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies'
    Headers     = $authHeaders
    ContentType = 'Application/json'
}

$configPolicies = Invoke-RestMethod @restParam
$configPolicies.value

```

That's easy and painless 😊

![PS1]({{ site.url }}/assets/images/posts/2022-03-29/1.png)

Now that we have that list we can iterate through it to get details of every policy.

```powershell
$configPoliciesDetails = foreach ($Policy in $configPolicies.value) {
    $restParam = @{
        Method      = 'Get'
        Uri         = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('$($Policy.id)')/settings?`$expand=settingDefinitions&top=1000"
        Headers     = $authHeaders
        ContentType = 'Application/json'
    }
    Invoke-RestMethod @restParam
}
```

![PS2]({{ site.url }}/assets/images/posts/2022-03-29/2.png)

To make our policies useable down the pipeline we need to rebuild it into compatible JSON form (～￣▽￣)～

# Fix

To make it work you need to create JSON object that follow strick format.

Thankfuly throught Powershell that's easy!

```powershell
$configPoliciesFormatted = foreach ($Policy in $configPolicies.value) {
    $restParam = @{
        Method      = 'Get'
        Uri         = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('$($Policy.id)')/settings?`$expand=settingDefinitions&top=1000"
        Headers     = $authHeaders
        ContentType = 'Application/json'
    }
    $PolicyDetails = Invoke-RestMethod @restParam

    [PSCustomObject]@{
        name            = $configPolicies.value.name
        description     = $configPolicies.value.description
        platforms       = $configPolicies.value.platforms
        technologies    = $configPolicies.value.technologies
        roleScopeTagIds = @($configPolicies.value.roleScopeTagIds)
        settings        = @(@{'settingInstance' = $configPoliciesDetails.value.settinginstance })
    }
}

$PolicyJSON = $configPoliciesFormatted | ConvertTo-Json -Depth 99
```

Now we have exported profile ready to be imported.
Below you can find example how it should look like:

```json
{
    "name": "MDMWinOverGPO",
    "description": "",
    "platforms": "windows10",
    "technologies": "mdm",
    "roleScopeTagIds": [
        "0"
    ],
    "settings": [
        {
            "settingInstance": {
                "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
                "settingDefinitionId": "device_vendor_msft_policy_config_controlpolicyconflict_mdmwinsovergp",
                "settingInstanceTemplateReference": null,
                "choiceSettingValue": {
                    "settingValueTemplateReference": null,
                    "value": "device_vendor_msft_policy_config_controlpolicyconflict_mdmwinsovergp_1",
                    "children": []
                }
            }
        }
    ]
}
```

# Import

Depending on your need you will be passing JSON body straight from Powershell session cache or from file and that's totally up to you.

To create new **Settings Catalog** policy just grab your profile body and pass it to `POST` request

```powershell

$restParam = @{
    Method      = 'Post'
    Uri         = 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies'
    Headers     = $authHeaders
    ContentType = 'Application/json'
    Body        = $PolicyJSON
}

$NewConfigPolicy = Invoke-RestMethod @restParam

```

# Summary

I've provided RAW materials for you to build your functions over those.
Everyone has their unique set of needs so I hope that this post will jump start your journey with Settings Catalog and PowerShell!

See you in next! 😉 🧠
