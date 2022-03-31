---
title: Verify Azure AD Bitlocker Keys with Microsoft Graph
categories:

    - Powershell

tags:

    - Intune
    - AzureAD
    - Powershell
    - Microsoft Graph
    - Encryption
    - Workstations
    - Runbook

excerpt: Find out how to use Microsoft Graph API to assess bitlocker recovery keys in Azure AD

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Device encryption help you protect your data from leak when device was stolen or missing 🚓
`Bitlocker` encryption method uses 48 digit sequence code as an recovery key.
In case something happens and you don't have this recovery key stored somewhere safe (eg. AzureAD), data on disk is lost forever...⚰️  
Better safe than sorry!

# Backup Bitlocker recovery key

You can store recovery key in local `Active Directory` or `Azure Active Directory`.
Sending key to AD requires line of sight with domain controller where for AAD Internet connection is enough.
Let's stick with AAD 💪

To perform backup you will need open `PowerShell` as an administrator and execute

```powershell
$BitLocker = Get-BitLockerVolume -MountPoint $env:SystemDrive
$RecoveryProtector = $BitLocker.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }

BackupToAAD-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $RecoveryProtector.KeyProtectorID
```

It will send System drive recovery key to AAD!
What if there are other encrypted fixed drives?
A little more scripting is necessary

```powershell
#Logs folder
$OperatingFolder = 'C:\Program Files (x86)\Microsoft\Temp'
#Interate through all fixed drives and create object representations
try {
    $GetDeviceVolumes = Get-Volume | Where-Object { $PSItem.DriveType -eq 'Fixed' } | Select-Object DriveLetter | Where-Object { $PSItem.DriveLetter -ne $null }
    $RecoveryPasswordsArray = @()
    foreach ($Volume in $GetDeviceVolumes.DriveLetter) {
        New-Variable "GetRecoveryPasswordsFor$Volume" -Force | Out-Null
        Set-Variable -Name $("GetRecoveryPasswordsFor$Volume") -Value $((Get-BitLockerVolume -MountPoint $volume`: -ErrorAction Stop).Keyprotector | Where-Object {
                $PSItem.KeyProtectorType -eq 'RecoveryPassword'
            })
        $RecoveryPasswordsArray += Get-Variable "GetRecoveryPasswordsFor$Volume"
    }
} catch {
    $_ | Out-File $OperatingFolder\bitlockerbackup.error
}
#for every found drive perform backup
foreach ($Keys in $RecoveryPasswordsArray) {
    if ($null -eq $Keys.Value) {
        Continue
    } else {
        $KeysCount = ($Keys.Value | Measure-Object).Count
        try {
            if ($KeysCount -gt 1) {
                foreach ($Password in $Keys.Value.GetEnumerator()) {
                    BackupToAAD-BitLockerKeyProtector -MountPoint "$($Keys.Name[-1])`:" -KeyProtectorId $Password.KeyProtectorId -ErrorAction Stop | Out-Null
                    Write-Output 'Key sent'
                    'Key sent' | Out-File $OperatingFolder\bitlockerbackup.ok
                }
            } else {
                BackupToAAD-BitLockerKeyProtector -MountPoint "$($Keys.Name[-1])`:" -KeyProtectorId $Keys.Value.KeyProtectorId -ErrorAction Stop | Out-Null
                Write-Output 'Key sent'
                'Key sent' | Out-File $OperatingFolder\bitlockerbackup.ok
            }
        } catch {
            Write-Output 'Error during backup'
            $_ | Out-File $OperatingFolder\bitlockerbackup.error
            Exit 1
        }
    }
}
```

Recovery keys are stored in device blade in AAD also in MEM portal

![img1]({{ site.url }}/assets/images/posts/2021-02-08/img1.png)

![img2]({{ site.url }}/assets/images/posts/2021-02-08/img2.png)

Additionally you can search for key by providing its ID here

![img3]({{ site.url }}/assets/images/posts/2021-02-08/img3.png)

# Graph API

## Prerequisites

In november 2020 Microsoft provided beta API to `list` all keys and `get` key details using `Microsoft Graph`.
Well...at last!😑
Click [here](https://docs.microsoft.com/en-us/graph/api/resources/bitlockerrecoverykey?view=graph-rest-beta) to jump to documentation.

I'm interested in listing all recovery keys in AAD.
To be able to do that you need specific set of permissions

![img4]({{ site.url }}/assets/images/posts/2021-02-08/img4.png)

As you can see these are `Delegated` permissions so you will need combination of `user role` and `cloud app` 🤝
Start with creating user and assign one of the roles from above.
For increased security use `Azure KeyValut` for password rotation or my [privileged service account solution](https://universecitiz3n.tech/powershell/PSAM/) to increase protection even further 🔑

Next step is creating `app registration` for `Microsoft Graph` calls.
Go to [apps](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps) and click on **New registration**

![img5]({{ site.url }}/assets/images/posts/2021-02-08/img5.png)

Enter app name and **register**

![img6]({{ site.url }}/assets/images/posts/2021-02-08/img6.png)

Next step is to add permissions for your app

![img7]({{ site.url }}/assets/images/posts/2021-02-08/img7.png)

![img8]({{ site.url }}/assets/images/posts/2021-02-08/img8.png)

Remember to grant **admin consent**

![img9]({{ site.url }}/assets/images/posts/2021-02-08/img9.png)

>NOTE: You can remove default API permissions

You will also need `client secret` to be able to authenticate.

![img10]({{ site.url }}/assets/images/posts/2021-02-08/img10.png)

Copy secret immediately 👈

## Powershell runbook

Now that we have everything in place you can proceed with scripting!
To be able to use `Microsoft Graph API` with `Delegated` user permissions you need to generate `Oauth2` token.
Here is how to do that

```powershell
#Client and user data
$AccountName = "username@onmicrosoft.com"
$AccountPassword = 'XXXXXXXXXXXXX'
$ClientId = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX"
$ClientSecret = 'XXXXXXXXXXXXXXXXXXXXXX'
$TenantID = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX"
$GraphUri = 'https://graph.microsoft.com'
$GraphVersion = 'beta'

# Authentication url
$AzureResourceURI = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

# Construct the Body for the POST
$Body = "grant_type=password"`
 + "&username=" + $Accountname `
 + "&client_id=" + $ClientId `
 + "&client_secret=" + $ClientSecret`
 + "&password=" + $AccountPassword `
 + "&scope=https://graph.microsoft.com/.default"

# The result should contain a token for use with Graph
$Response = Invoke-WebRequest -Uri $AzureResourceURI -Method POST -Body $Body -UseBasicParsing
$ResponseJSON = $Response | ConvertFrom-Json

# Add the token to headers for the Graph request
$Headers = @{
Authorization = "Bearer " + $ResponseJSON.access_token
}

#Run API call
$Deviceuri = "$GraphUri/$GraphVersion/devices"
$AllDevices = Invoke-RestMethod -Uri $Deviceuri -Headers $Headers -Method Get
```

OBVIOUSLY you should not keep your passwords and secrets as plain text in script!!
It's better to use variables or credentials in `Automation Account` 😉
With such generated token you can proceed and make API call for bitlocker recovery keys

```powershell
#Required header modification for bitlocker call
$Bitlockerheader = @{
  'Authorization'      = $Headers.Authorization
  'ocp-client-name'    = 'Bitlocker Recovery Keys'
  'ocp-client-version' = '1.2'
}

$bitlockerkeys = @()
$Bitlockeruri = "$GraphUri/$GraphVersion/bitlocker/recoveryKeys"
$bitlockerkeysuri = Invoke-RestMethod -Uri $Bitlockeruri -Headers $Bitlockerheader -Method Get
$bitlockerkeys += $bitlockerkeysuri.value
while ($bitlockerkeysuri.'@odata.nextLink') {
 $NextBatchRequest = $bitlockerkeysuri.'@odata.nextLink'
 $bitlockerkeysuri = Invoke-RestMethod -Uri $NextBatchRequest -Headers $Bitlockerheader -Method Get
 $bitlockerkeys += $bitlockerkeysuri.value
}
```

>NOTE: As stated in [documentation](https://docs.microsoft.com/en-us/graph/api/bitlocker-list-recoverykeys?view=graph-rest-beta&tabs=http#request-headers) header requires `ocp-client-name` and `ocp-client-version`

As an result you will receive list of keys

![img11]({{ site.url }}/assets/images/posts/2021-02-08/img11.png)

Alright we've got it!
But how about taking it further...just bear with me a little more 😁

## Proactive backup with Intune

Now that you have insights into state of bitlocker recovery keys in AAD you can take action if any device is missing a key.
Start with creating `PowerShell` script deployment using `Intune`.
Go to [devices | scripts](https://endpoint.microsoft.com/#blade/Microsoft_Intune_DeviceSettings/DevicesMenu/powershell) and create new `Windows 10` configuration.
Fill out the name and upload your backup script covered in first section of this post

![img12]({{ site.url }}/assets/images/posts/2021-02-08/img12.png)

Assign some AAD group and finish

![img13]({{ site.url }}/assets/images/posts/2021-02-08/img13.png)

Assign additional permissions to your application:

* Device.Read.All
* GroupMember.ReadWrite.All

Device read will help you out identify devices by their names and interate through all `Windows 10` devices managed by `Intune`.
Group member is required for modifications of group which is assigned to `Intune` script profile.
Now go to your `runbook` and expand it with following code

```powershell
# Get all AAD devices and filter out Windows managed by Intune
$AllDevices = @()
$Deviceuri = "$GraphUri/$GraphVersion/devices?`$filter=operatingSystem eq 'Windows' AND isManaged eq true AND accountEnabled eq true"
$Devices = Invoke-RestMethod -Uri $Deviceuri -Headers $Headers -Method Get
$AllDevices += $Devices.value
while ($Devices.'@odata.nextLink') {
 $NextBatchRequest = $Devices.'@odata.nextLink'
 $Devices = Invoke-RestMethod -Uri $NextBatchRequest -Headers $Headers -Method Get
 $AllDevices += $Devices.value
}
$AllDevices = $AllDevices | Where-Object { $PSItem.managementType -eq 'MDM' -and $PSItem.approximateLastSignInDateTime -gt $(Get-Date).AddMonths(-3) }

# Check group members
$BackupIntuneScriptGroup = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX'
$Groupuri = "$GraphUri/$GraphVersion/groups/$BackupIntuneScriptGroup/members"
$GroupMembers = Invoke-RestMethod -Uri $Groupuri -Headers $Headers -Method Get

# For every managed device check if there is a recovery key in AAD
$Results = @()
try {
 foreach ($device in $AllDevices) {
  if (($bitlockerkeys | Where-Object { $PSItem.deviceId -eq $device.deviceId } | Measure-Object).Count -gt 0) {
   if ($device.deviceId -in $GroupMembers.value.deviceId) {
    $GroupHeader = @{
     Authorization = $Headers.Authorization
    }
    $Response = Invoke-RestMethod -Method DELETE -Uri "$GraphUri/$GraphVersion/groups/$BackupIntuneScriptGroup/members/$($device.id)/`$ref" -Headers $GroupHeader
    $Results += [PSCustomObject]@{
     DeviceName       = $device.displayName
     DeviceId         = $device.deviceId
     RecoveryKeyInAAD = $true
     Action           = 'Removed from group'
     AdditionalInfo   = "$(($bitlockerkeys | Where-Object { $PSItem.deviceId -eq $device.deviceId } | Measure-Object).Count) keys found"
    } | ConvertTo-Json
   } else {
    $Results += [PSCustomObject]@{
     DeviceName       = $device.displayName
     DeviceId         = $device.deviceId
     RecoveryKeyInAAD = $true
     Action           = 'None'
     AdditionalInfo   = "$(($bitlockerkeys | Where-Object { $PSItem.deviceId -eq $device.deviceId } | Measure-Object).Count) keys found"
    } | ConvertTo-Json
   }
  } else {
   if ($device.displayName -in $GroupMembers.value.displayName) {
    $Results += [PSCustomObject]@{
     DeviceName       = $device.displayName
     DeviceId         = $device.deviceId
     RecoveryKeyInAAD = $false
     Action           = 'None'
     AdditionalInfo   = 'Already in group'
    } | ConvertTo-Json
   } else {
    $BodyContent = @{
     "@odata.id" = "$GraphUri/$GraphVersion/devices/$($device.id)"
    } | ConvertTo-Json
    $GroupHeader = @{
     Authorization  = $Headers.Authorization
     'Content-Type' = 'application/json'
    }

    $Response = Invoke-RestMethod -Method POST -Uri "$GraphUri/$GraphVersion/groups/$BackupIntuneScriptGroup/members/`$ref" -Headers $GroupHeader -Body $BodyContent
    $Results += [PSCustomObject]@{
     DeviceName       = $device.displayName
     DeviceId         = $device.deviceId
     RecoveryKeyInAAD = $false
     Action           = 'Added to backup group'
     AdditionalInfo   = ''
    } | ConvertTo-Json
   }
  }
 }
} catch {
 Write-Error $device
 Write-Error $_
 break
}
```

Output

![img14]({{ site.url }}/assets/images/posts/2021-02-08/img14.png)

# Summary

Thanks to `Microsoft Graph API` you can run check against `Azure AD` for bitlocker recovery keys.
If some device is missing a key `Intune` will take care of performing backup for you.
Now you can rest without worries.

See you in next! 😉 🧠
