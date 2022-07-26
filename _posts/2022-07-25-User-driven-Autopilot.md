---
title: Truly user-driven Windows Autopilot
categories:

    - Intune

tags:

    - Powershell
    - Windows Autopilot
    - Azure Automation
    - Microsoft Graph
    - Intune

excerpt: Brilliant but kind of risky alternative to group tags 🪄🚀

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Hi there!

A colleague of mine came to me with question 'Can we somehow make the Windows Autopilot dependent on the user account that starts it?'.
The reason behind that was to try ditching Windows Autopilot device group tags and latency of Azure AD dynamic groups.

Immediately an idea came to my head 💡!

# Configuration profiles assignment

Windows Autopilot has two deployment scenarios:

* Azure AD join if devices don't need to join an on-premises Active Directory domain.
* Hybrid Azure AD join for devices that need to join both Azure AD and your on-premises Active Directory domain.

While AAD join is quick and easy, HAAD join is more complex and beside deployment profile device requires domain join profile assigned.

With the use of **group tags** IT Admins (or vendors depend if device hash was uploaded in factory) can predetermine configuration for the device before even deployment starts.

[Using group tags to import devices into Intune with Autopilot](https://techcommunity.microsoft.com/t5/intune-customer-success/support-tip-using-group-tags-to-import-devices-into-intune-with/ba-p/815336)

Speaking of domain join profile

![AP8]({{ site.url }}/assets/images/posts/2022-07-25/userap8.png)

There is not much but what if your company has multiple domains?

Well you can't type in more than one into the profile and if you create multiple profiles the first one to come will be used.
That is why group tags will help with assigning only that which should be used.
But again this needs to determined before Autopilot deployment even starts.

Idea is to join device to the same domain as the user that started deployment.
How about assigning domain join profile to the user?! 🤔

![AP9]({{ site.url }}/assets/images/posts/2022-07-25/userap9.png)

![Cartman](https://c.tenor.com/p5Qmh_2RT9YAAAAC/your-tactics-dont-work-on-me-eric-cartman.gif)

What if there was another way...

# PowerShell + Graph API

![HAADJ](https://oofhours.files.wordpress.com/2020/06/image-24.png)

Source - [oofhours](https://oofhours.files.wordpress.com/2020/06/image-24.png)

Based on that flowchart and my experience after device is enrolled to Intune configuration policies are applied and domain join profile with them.
If the latter is missing device waits up to 25-30 minutes until failing entire process.
That gives us time to run **PowerShell** runbook which will assign groups based on the user that started Autopilot!

For this to happen you need **Azure Automation** instance and service principal with the following set of permissions

![AP15]({{ site.url }}/assets/images/posts/2022-07-25/userap15.png)

>NOTE: Service Princial doesn't have to have right to manage group membership. It just needs to be owner of the groups that it will change 😎

For more info on how to create azure automation and how to use service principal visit my previous post -  [here](https://universecitiz3n.tech/powershell/Graph-Bitlocker/#prerequisites)

To easily find only newly enrolled devices to Intune you can make a Graph call to `deviceManagement/managedDevices` with filter `enrolleddatetime`

![AP13]({{ site.url }}/assets/images/posts/2022-07-25/userap13.png)

```powershell
$DateTimeNow = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
$DateTimeNowM10 = (Get-Date).addhours(-2).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
$Resource = "deviceManagement/managedDevices?`$filter=(Notes%20eq%20%27bc3e5c73-e224-4e63-9b2b-0c36784b7e80%27)%20and%20((enrolleddatetime%20lt%20$DateTimeNow)%20and%20(enrolleddatetime%20gt%20$DateTimeNowM10)%20and%20((deviceType%20eq%20%27desktop%27)%20or%20(deviceType%20eq%20%27windowsRT%27)))&`$top=25&`$skipToken=Skip=%270%27&`$select=deviceName,managementAgent,ownerType,complianceState,deviceType,userId,userPrincipalName,osVersion,lastSyncDateTime,userPrincipalName,id,deviceRegistrationState,managementState,exchangeAccessState,exchangeAccessStateReason,deviceActionResults,deviceEnrollmentType"
Write-Output "Time: $DateTimeNow"
$APICallParams = @{
    Method  = 'GET'
    Headers = $AuthorizationToken
    Uri     = "$GraphUrl/$GraphVersion/$Resource"
}

Write-Output 'Checking for Windows Autopilot new devices...'
$WindowsAutopilotEnrolledDevices = (Invoke-RestMethod @APICallParams).value
```

That way you will also get `userPrincipalName` of the user that started deployment!

To make assignment of the configuration profiles based on the user I came up with a design to have two groups:

![AP19]({{ site.url }}/assets/images/posts/2022-07-25/userap19.png)

One for the users and another with resembling name for the devices where devices group is assigned to the domain join profile in Intune

![AP20]({{ site.url }}/assets/images/posts/2022-07-25/userap20.png)

With just another API call we get user membership

```powershell
$APICallParams = @{
    Method  = 'GET'
    Headers = $AuthorizationToken
    Uri     = "$GraphUrl/$GraphVersion/users/$($Device.userid)/memberOf"
}
$UserGroups = (Invoke-RestMethod @APICallParams).value
$DeviceGroupsFromUserGroups = $UserGroups.Where({ $PSItem.displayName -like '*-Users_AzA' })
```

Later on user group names are transformed to device groups and to proceed further we need `group object ID`

```powershell
$DeviceGroup = "$($DeviceGroup.displayName.split('-')[0])-Computers"
$RequestSplat = @{
    Headers = $AuthorizationToken + @{'ConsistencyLevel' = 'eventual' }
    Uri     = "$GraphUrl/$GraphVersion/groups?`$filter=displayname eq '$DeviceGroup'"
}
$AADGroupObject = (Invoke-RestMethod @RequestSplat).value
```

To assign `Azure AD group` to the `Azure AD device object` you also need `device object id` which should not be confused with `device id`

![AP12]({{ site.url }}/assets/images/posts/2022-07-25/userap12.png)

![AP21]({{ site.url }}/assets/images/posts/2022-07-25/userap21.png)

```powershell
#Get Intune device details
$APICallParams = @{
    Method  = 'GET'
    Headers = $AuthorizationToken
    Uri     = "$GraphUrl/$GraphVersion/deviceManagement/manageddevices('$($Device.id)')"
}
$IntuneDeviceDetails = Invoke-RestMethod @APICallParams

#Get AAD object from Intune object
$RequestSplat = @{
    Headers = $AuthorizationToken + @{'ConsistencyLevel' = 'eventual' }
    Uri     = "$GraphUrl/$GraphVersion/devices?`$filter=deviceId eq '$($IntuneDeviceDetails.azureADDeviceId)' or id eq '$($IntuneDeviceDetails.azureADDeviceId)'"
}
$AADDeviceObject = (Invoke-RestMethod @RequestSplat).value
```

That was the last piece of our puzzle.
Now you can proceed with adding Autopilot device to `Azure AD group` that will apply domain join profile policy

```powershell
$APICallParams = @{
    Uri     = "$GraphUrl/$GraphVersion/groups/$($AADGroupObject.id)/members/`$ref"
    Body    = @{
        '@odata.id' = "$GraphUrl/$GraphVersion/devices/$($AADDeviceObject.id)"
    } | ConvertTo-Json
    Method  = 'POST'
    Headers = $AuthorizationToken + @{'Content-Type' = 'application/json' }
}
Invoke-RestMethod @APICallParams
```

![AP17]({{ site.url }}/assets/images/posts/2022-07-25/userap17.png)

The whole script looks as follows:

``` powershell
Set-Item Env:\SupressAzurePowerShellBreakingChangeWarnings 'true'
$Global:ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Autopilot_UserGroups_Connection = Get-AutomationPSCredential -Name 'CREDENTIAL_NAME'

$Token = Get-MsalToken -ClientId $Autopilot_UserGroups_Connection.UserName -ClientSecret $Autopilot_UserGroups_Connection.Password -TenantId 'YOUR TENANT ID'
$AuthorizationToken = @{Authorization = "Bearer $($Token.AccessToken)" }

$GraphUrl = 'https://graph.microsoft.com'
$GraphVersion = 'beta'
$DateTimeNow = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
$DateTimeNowM10 = (Get-Date).addhours(-2).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
$Resource = "deviceManagement/managedDevices?`$filter=(Notes%20eq%20%27bc3e5c73-e224-4e63-9b2b-0c36784b7e80%27)%20and%20((enrolleddatetime%20lt%20$DateTimeNow)%20and%20(enrolleddatetime%20gt%20$DateTimeNowM10)%20and%20((deviceType%20eq%20%27desktop%27)%20or%20(deviceType%20eq%20%27windowsRT%27)))&`$top=25&`$skipToken=Skip=%270%27&`$select=deviceName,managementAgent,ownerType,complianceState,deviceType,userId,userPrincipalName,osVersion,lastSyncDateTime,userPrincipalName,id,deviceRegistrationState,managementState,exchangeAccessState,exchangeAccessStateReason,deviceActionResults,deviceEnrollmentType"
Write-Output "Time: $DateTimeNow"
$APICallParams = @{
    Method  = 'GET'
    Headers = $AuthorizationToken
    Uri     = "$GraphUrl/$GraphVersion/$Resource"
}

Write-Output 'Checking for Windows Autopilot new devices...'
try {
    $WindowsAutopilotEnrolledDevices = (Invoke-RestMethod @APICallParams).value
    $WindowsAutopilotDevicesCount = $($($WindowsAutopilotEnrolledDevices | Measure-Object).Count)
    if ($WindowsAutopilotDevicesCount -eq 0) {
        Write-Warning 'No new Autopilot devices found'
        Write-Warning 'Terminating script'
    } else {
        Write-Output "$WindowsAutopilotDevicesCount found"
        foreach ($Device in $WindowsAutopilotEnrolledDevices) {
            Write-Output "Processing $($Device.DeviceName)"

            #Get AAD User details
            if ($null -eq $Device.userid -or $Device.userId -eq '') {
                Write-Warning 'Device user is null!!'
                Write-Warning 'Skipping Device'
                Continue
            } else {
                $APICallParams = @{
                    Method  = 'GET'
                    Headers = $AuthorizationToken
                    Uri     = "$GraphUrl/$GraphVersion/users/$($Device.userid)/memberOf"
                }
                $UserGroups = (Invoke-RestMethod @APICallParams).value
                $DeviceGroupsFromUserGroups = $UserGroups.Where({ $PSItem.displayName -like '*-Users_AzA' })
            }
            if ($null -eq $DeviceGroupsFromUserGroups) {
                Write-Warning "$($Device.userDisplayName) has no Users_AzA groups!"
                Write-Warning 'Skipping Device'
                Continue
            }
   
            foreach ($DeviceGroup in $DeviceGroupsFromUserGroups) {
                #Get device group ID
                $DeviceGroup = "$($DeviceGroup.displayName.split('-')[0])-Computers"
                $RequestSplat = @{
                    Headers = $AuthorizationToken + @{'ConsistencyLevel' = 'eventual' }
                    Uri     = "$GraphUrl/$GraphVersion/groups?`$filter=displayname eq '$DeviceGroup'"
                }
                $AADGroupObject = (Invoke-RestMethod @RequestSplat).value

                #Get AAD group members
                $APICallParams = @{
                    Method  = 'GET'
                    Headers = $AuthorizationToken
                    Uri     = "$GraphUrl/$GraphVersion/groups/$($AADGroupObject.id)/members"
                }
                $GroupMembers = (Invoke-RestMethod @APICallParams).value
            
                #Get Intune device details
                $APICallParams = @{
                    Method  = 'GET'
                    Headers = $AuthorizationToken
                    Uri     = "$GraphUrl/$GraphVersion/deviceManagement/manageddevices('$($Device.id)')"
                }
                $IntuneDeviceDetails = Invoke-RestMethod @APICallParams
            
                #Get AAD object from Intune object
                $RequestSplat = @{
                    Headers = $AuthorizationToken + @{'ConsistencyLevel' = 'eventual' }
                    Uri     = "$GraphUrl/$GraphVersion/devices?`$filter=deviceId eq '$($IntuneDeviceDetails.azureADDeviceId)' or id eq '$($IntuneDeviceDetails.azureADDeviceId)'"
                }
                $AADDeviceObject = (Invoke-RestMethod @RequestSplat).value
            
                if ($GroupMembers.id -notcontains $AADDeviceObject.id) {
                
                    $APICallParams = @{
                        Uri     = "$GraphUrl/$GraphVersion/groups/$($AADGroupObject.id)/members/`$ref"
                        Body    = @{
                            '@odata.id' = "$GraphUrl/$GraphVersion/devices/$($AADDeviceObject.id)"
                        } | ConvertTo-Json
                        Method  = 'POST'
                        Headers = $AuthorizationToken + @{'Content-Type' = 'application/json' }
                    }
                    Invoke-RestMethod @APICallParams
                    Write-Output "Device - $($AADDeviceObject.displayName) added as a member"
                } else {
                    Write-Warning "Device - $($AADDeviceObject.displayName) already a member"
                }
            }
        }
    }
} catch {
    Write-Error "
        ScriptLineNumber $($_.InvocationInfo.ScriptLineNumber)
        OffsetInLine $($_.InvocationInfo.OffsetInLine)"
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Error "Response content: $responseBody"
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
}
```

![AP3]({{ site.url }}/assets/images/posts/2022-07-25/userap3.png)

# Autopilot in action

User unboxes device, connects it to the Internet and deployment profile is downloaded.
After authenticating with work account device is enrolled into Intune.

![AP1]({{ site.url }}/assets/images/posts/2022-07-25/userap1.png)

Then configuration profiles are applied and device object is created in Intune.

![AP11]({{ site.url }}/assets/images/posts/2022-07-25/userap11.png)

Device will wait around 25-30 minutes for domain join profile.

![AP2]({{ site.url }}/assets/images/posts/2022-07-25/userap2.png)

When profile arrives and ODJ request is raised then device is renamed.

![AP16]({{ site.url }}/assets/images/posts/2022-07-25/userap16.png)

Deployment will continue after reboot

![AP5]({{ site.url }}/assets/images/posts/2022-07-25/userap5.png)

Then the rest of configurations are applied

![AP7]({{ site.url }}/assets/images/posts/2022-07-25/userap7.png)

After ESP user can sign-in using domain credentials

![AP18]({{ site.url }}/assets/images/posts/2022-07-25/userap18.png)

And that is it!

# Summary

Described process is a little bit risky due to possible latency of runbook schedule, Azure group membership sync, device sync with Intune, etc.

But unless there will be some other way to archive the result of building devices based on the user account it seems like using **PowerShell** and **Graph** is the easiest and coolest option.

See you in next! 😉 🧠
