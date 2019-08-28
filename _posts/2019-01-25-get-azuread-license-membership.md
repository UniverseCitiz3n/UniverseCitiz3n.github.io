---
title: Get AzureAD license details for all users
categories:
    - Office365
tags:
    - PowerShell
    - AzureAD
    - Office365
    - ActiveDirectory
---

# The Story

So here's the story. Some time ago we wanted to use the possibility to manage AzureAD licenses through Active Directory groups. We do have AzureAD P1 (which is necessary) to do this. The process is dead simple:
- Create proper AD groups on-premises
- Wait for sync (or orce it) to Azure AD
- Go to proper blade (in Azure AD) and assign groups to products
- Add people to on-premises Active Directory
- Get some coffee

![Licenses](/assets/images/posts/get-azuread-license/picture1.png)

Here's the thing though - till now we were using our on-premises automation to assign licenses to people directly using MSOL commands. 

It shouldn't be hard to get all members of Microsoft Flow Free, right? Or Office 365 E3 license right? Right????

# The Problem

In Intune you can easily export all devices into csv and then do whatever you wish with it. When it comes to licenses - you get first 20 people with `Load more` option in GUI. And then you click and click and click to get all 181 users. Then you can hit `ctrl + A` and `ctrl + c` and parse it. 

![Load More](/assets/images/posts/get-azuread-license/picture2.png)

Want to try with PowerShell? Well, it *isn't hard* to get a SINGLE user membership. 

```powershell
$user = Get-AzureADUser -SearchString 'mczerniawski' | Where-Object {$_.UserType -eq 'Member'}
Get-AzureADUserLicenseDetail -ObjectId $user.objectid | Select-Object -ExpandProperty ServicePlans

AppliesTo ProvisioningStatus  ServicePlanId                        ServicePlanName
--------- ------------------  -------------                        ---------------
Company   Success             6c57d4b6-3b23-47a5-9bc9-69f17b4947b3 RMS_S_PREMIUM
Company   Success             bea4c11e-220a-4e6d-8eb8-8ea15d019f90 RMS_S_ENTERPRISE
Company   Success             41781fb2-bc02-4b7c-bd55-b576c07bb09d AAD_PREMIUM
...
Company   Success             76846ad7-7776-4c40-a281-a386362dd1b9 FLOW_O365_P2
Company   Success             c68f8d98-5534-41c8-bf36-22fa496fa792 POWERAPPS_O365_P2
...
Company   Success             2049e525-b859-401b-b2a0-e0a31c4b1fe4 BI_AZURE_P0
``` 

But it ain't that simple to get all users of a single group/license assignment!

> There is no cmdlet for this! 
> -

At least as of now - 25.01.2019

I haven't tried with Mirosoft Graph yet, so I decided to go straight PowerShell.

# The Resolution

My apporach was to:
- get all users from Azure AD
- get their license information
- return some proper object

So I've run this:

```powershell
Import-Module azuread
Connect-AzureAD
$allusers = Get-AzureADUser -All $true
$AllUserDetails = foreach ($user in $allusers){ 
    $licenseDetails = Get-AzureADUserLicenseDetail -ObjectId $user.objectid | Select-Object -ExpandProperty ServicePlans
    $License = foreach ($licenseRow in $licenseDetails) {
        @{
            ServicePlanName = $licenseRow.ServicePlanName
            ProvisioningStatus = $licenseRow.ProvisioningStatus
            AppliesTo = $licenseRow.AppliesTo
            ServicePlanId = $licenseRow.ServicePlanId
        }
    }
    [pscustomObject]@{
        ObjectID = $user.ObjectID
        DisplayName = $user.DisplayName
        UserPrincipalName =$user.UserPrincipalName
        ObjectType = $user.ObjectType
        UserType = $user.UserType
        AccountEnabled =$user.AccountEnabled
        AssignedPlans = $user.AssignedPlans
        LastDirSyncTime = $user.LastDirSyncTime
        AssignedLicense =  $License
    }
}
$AllUserDetails | ConvertTo-Json -Depth 99 | Out-File $ExportPath
```

But it took ages (like 10 minutes and I got suspicious) to execute. So I've added a little bit of verbosity. Also I wanted to have a better naming than `BPOS_S_TODO_2` :smile:

It took a bit of time (as Microsoft is adding/renaming a whole lot) but I managed to get a list of names for each SKU (this is a csv list):

```
SKUID;SKUName
BI_AZURE_P0;Power BI (free)
BI_AZURE_P2;Power BI Pro
WIN10_PRO_ENT_SUB;Windows 10 Enterprise E5
INTUNE_O365;Intune
VISIOONLINE;Visio Online Plan 2
POWERFLOWSFREE;PowerApps and Logic Flows
PROJECTWORKMANAGEMENT;Office 365 Enterprise E3
EXCHANGE_S_ENTERPRISE;Office 365 Enterprise E3
BPOS_S_TODO_2;Office 365 Enterprise E3
FORMS_PLAN_E3;Office 365 Enterprise E3
YAMMER_ENTERPRISE;Office 365 Enterprise E3
MCOSTANDARD;Office 365 Enterprise E3
FLOW_O365_P2;Office 365 Enterprise E3
SWAY;Office 365 Enterprise E3
TEAMS1;Office 365 Enterprise E3
OFFICESUBSCRIPTION;Office 365 Enterprise E3
STREAM_O365_E3;Office 365 Enterprise E3
Deskless;Office 365 Enterprise E3
POWERAPPS_O365_P2;Office 365 Enterprise E3
Microsoft Stream;Microsoft Stream Trial
DYN365_ENTERPRISE_P1;Dynamics 365 Customer Engagement Plan
POWERAPPS_P2_VIRAL;Microsoft PowerApps Plan 2 Trial (d5368ca3-357e-4acb-9c21-8495fb025d1f)
FLOW_P2_VIRAL_REAL;Microsoft PowerApps Plan 2 Trial (d20bfa21-e9ae-43fc-93c2-20783f0840c3)
FLOW_P2_VIRAL;Microsoft Flow Free (50e68c76-46c6-4674-81f9-75456511b170)
DYN365_CDS_VIRAL;Microsoft Flow Free (17ab22cd-a0b3-4536-910a-cb6eb12696c0)
EXCHANGE_S_STANDARD;Exchange Online (Plan 1)
AAD_PREMIUM;Enterprise Mobility + Security E3
ADALLOM_S_DISCOVERY;Enterprise Mobility + Security E3
RMS_S_PREMIUM;Enterprise Mobility + Security E3
MFA_PREMIUM;Enterprise Mobility + Security E3
INTUNE_A;Enterprise Mobility + Security E3
Dynamics_365_Hiring_Free_PLAN;Dynamics 365 for Talent
DYN365_CDS_DYN_APPS;Dynamics 365 for Talent
POWERAPPS_DYN_APPS;Dynamics 365 for Talent
Dynamics_365_for_HCM_Trial;Dynamics 365 for Talent
FLOW_DYN_APPS;Dynamics 365 for Talent
Dynamics_365_Onboarding_Free_PLAN;Dynamics 365 for Talent
DYN365_BUSINESS_Marketing;Dynamics 365 for Marketing
MCOMEETADV;Audio Conferencing
SPZA;AppConnect
AAD_BASIC;Azure Active Directory Basic
POWERVIDEOSFREE;PowerApps and Logic Flows
POWERFLOWSFREE;PowerApps and Logic Flows
POWERAPPSFREE;PowerApps and Logic Flows
PROJECT_PROFESSIONAL;Project Online Professional
SHAREPOINT_PROJECT;Project Online Professional
PROJECT_CLIENT_SUBSCRIPTION;Project Online Professional
```

# Final Round

Now, the final code look somewhat like this:



```powershell
Import-Module azuread
Connect-AzureAD
$currentDate = Get-Date -Format yyyyMMdd_HHmmss
$LicenseSKU = Import-Csv -Path <Path to csv file with SKU>
$JSONExportFileName = 'users_licenses_{0}.json' -f $currentDate
$ExportPath=  Join-Path .\ -ChildPath $JSONExportFileName 
$counter = 1
$allusers = Get-AzureADUser -All $true
$AllUserDetails = foreach ($user in $allusers){ 
    $percentComplete = $counter / $allusers.count * 100
    $Activity = @{
        Activity = "Processing user {$counter} of $($allusers.count)" 
        Status = "Processing user {$($User.DisplayName)}" 
        PercentComplete=  $percentComplete 
        CurrentOperation = 'Getting user license detail from AzureAD'
    }
    Write-Progress  @Activity

    #get license details
    $licenseDetails = Get-AzureADUserLicenseDetail -ObjectId $user.objectid | Select-Object -ExpandProperty ServicePlans
    $License = foreach ($licenseRow in $licenseDetails) {
        @{
            ServicePlanName = $licenseRow.ServicePlanName
            FullServicePlanName = $LicenseSKU | Where-Object {$PSItem.SKUID -eq $licenseRow.ServicePlanName} | Select-Object -ExpandProperty SKUName
            ProvisioningStatus = $licenseRow.ProvisioningStatus
            AppliesTo = $licenseRow.AppliesTo
            ServicePlanId = $licenseRow.ServicePlanId
        }
    }
    [pscustomObject]@{
        ObjectID = $user.ObjectID
        DisplayName = $user.DisplayName
        UserPrincipalName =$user.UserPrincipalName
        ObjectType = $user.ObjectType
        UserType = $user.UserType
        AccountEnabled =$user.AccountEnabled
        AssignedPlans = $user.AssignedPlans
        LastDirSyncTime = $user.LastDirSyncTime
        AssignedLicense =  $License
    }
    $counter++
} 
$AllUserDetails | ConvertTo-Json -Depth 99 | Out-File $ExportPath
```

For my domain (around 5,5k User objects) it takes about 30 minutes to complete. I'm storing the result in JSON for further processing and historical information.

# The Report

Now that I have all users and their licenses I can get GROUPS with MEMBERS! 

```powershell
$result = @{}
foreach ($row in $AllUserDetails) {
    foreach ($al in $row.assignedLicense) {
        if ($al.ServicePlanName) { 
            $sku = $al.ServicePlanName
            if($result.ContainsKey($sku)) {
                $currentUsers = $result[$sku]
                $newValue =  @($currentUsers) + @([pscustomobject]@{
                                                    userPrincipalName = $row.UserPrincipalName
                                                    DisplayName = $row.DisplayName
                                                }
                                                )
                $result[$sku] = $newValue
            }
            else {
                $result[$sku] = [pscustomobject]@{
                    userPrincipalName = $row.UserPrincipalName
                    DisplayName = $row.DisplayName
                }
            }
        }
    }
}
$result 
```

This nasty bit of code does a nasty thing:
- it goes through each row
- if SKU (the all-saying Abbreviation - like `POWERAPPS_P2_VIRAL`) is found for the first time - it's added to a hashtable where key is the SKU and value is an object with userPrincipalName and DisplaName
- if SKU was already found before - new value with userPrincipalName and DisplayName are added to currenty key

# The Holy Grail

NOW, I'm finally able to get what I wanted - all users for given group - and add them to my on-premises Active Directory group!

```powershell
$GroupName='VISIOONLINE'
$users = $result[$GroupName] | Select-Object -ExpandProperty userprincipalname
$ADGroupName = 'Cloud_Visio_Plan2'
foreach ($user in $users) { 
    $usertest = Get-ADuser -Filter {userPrincipalName -eq $user}
    Write-Host "Processing user {$user} - $($usertest.samaccountname)"
    Add-ADGroupMember -Identity $ADGroupName -Members $usertest
}
```

It wasn't that hard right? Right?... :smile:

# The Next Step

The next step is to achieve the same thing with Grap API. MAYBE it will be easier! 
