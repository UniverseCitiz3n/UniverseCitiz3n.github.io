---
title: The power of Three! Intune + Powershell + MicrosoftGraph
categories:

    - Intune

tags:

    - Intune
    - Powershell
    - Microsoft Graph

excerpt: Easy way to break and fix things in a matter of seconds! ⚠️

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Today I'd like to show you how I've was able to force reboot 197 devices to fix Windows Updates issue with just a few lines of code<br>

![image0]({{ site.url }}/assets/images/posts/2020-01-31.gif)

# The issue

Some users don't have a habit to restart device from time to time... In our environment that behavior led to problem with installing Quality updates on endpoints. December 2019 Feature update requires **one reboot** after downloading to start installing. Without that **one reboot** Quality updates just stacked and it all lead to major security risks! Yes, Intune allows you to set **Deadline for updates** but it is connected with applying update process.

![image2]({{ site.url }}/assets/images/posts/2020-01-31_2.jpg)

To check how big this issue could be you can go to [Windows 10 update rings](https://devicemanagement.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/DevicesMenu/windows10UpdateRings) and then select desired update ring. Your eyes probably see something like:

![image1]({{ site.url }}/assets/images/posts/2020-01-31_1.jpg)

**❗❗ Look carefully because this view only shows update profile assignment status ❗❗** not real status of updates per device. To see that you need to click on **End user update status**🕵🏼

![image3]({{ site.url }}/assets/images/posts/2020-01-31_3.jpg)

There you can see detailed status for each device. And the options are:<br>

| Status              | Value | Description|
| upToDate            | 0     | There are no pending updates, no pending reboot updates and no failed updates.|
| pendingInstallation | 1     | There are updates that’s pending installation which includes updates that are not approved. There are no Pending reboot updates, no failed updates.|
| pendingReboot       | 2     | There are updates that requires reboot. There are not failed updates.|
| failed              | 3     | There are updates failed to install on the device.|

# Time to fix it! 🔱

Solution for described scenario is plain simple reboot which should allow Windows Update service to push installation forward. You can nicely **ask** user to perform reboot but it might have effectiveness around a few or a dozen percentage. To fix it immediately you will need:

* [PowerShell SDK for Microsoft Intune Graph API](https://www.powershellgallery.com/packages/Microsoft.Graph.Intune/6.1907.1.0)
* Account with Global Administrator Rights or proper configuration of Powershell MSGraph in your tenant
* Powershell console

After you install Microsoft Graph module you need to connect to service and from there you will be able to grab list of devices with their update statuses and perform reboot. I recommend to get familiar with documentation [here](https://docs.microsoft.com/en-us/graph/api/resources/intune-devices-manageddevice?view=graph-rest-beta) and Graph Explorer [here](https://developer.microsoft.com/en-us/graph/graph-explorer) it will come in handy in your journey with MicrosoftGraph 🌌.

Time to make some mess!

``` powershell

#Connecting to GraphAPI
Connect-MSGraph

#Get list of Windows devices
$MSGraphComputers = (Get-DeviceManagement_ManagedDevices).value | Where { $PSItem.operatingSystem -eq 'Windows'}

#Get list of Windows10 Update rings
$WindowsUpdateRings = Get-DeviceManagement_DeviceConfigurations | Where { $PSItem.'@odata.type' -like '*windowsupdate*' }  | ogv -PassThru

#Get list of update states
$DeviceUpdateStates = foreach($Ring in $WindowsUpdateRings){
    (Invoke-MSGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Ring.id)/microsoft.graph.windowsUpdateForBusinessConfiguration/deviceUpdateStates").Value
}

#Force reboot devices
$DeviceUpdateStates | Where { $PSItem.'Update Status' -eq 'Failed' } | Invoke-DeviceManagement_ManagedDevices_RebootNow

```

Device will be restarted within 10 minutes with first notification:

![image4]({{ site.url }}/assets/images/posts/2020-01-31_4.jpg)

and 2 minutes before:

![image5]({{ site.url }}/assets/images/posts/2020-01-31_5.jpg)

Yeah it is in language set in Windows

# Summary

Even though Intune itself does not allow to perform bulk actions it can be easily done with a little bit of Powershell magic✨

See you in next! 😉 🧠
