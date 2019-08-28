---
title: Remove AAD Group Membership from disabled on-premises AD users
categories:
    - Office365
tags:
    - PowerShell
    - AzureAD
    - Office365
    - ActiveDirectory
---

# The Problem

So here's the problem - when an employee leaves our company we cannot delete his/her user account. Instead we disable it. This is mainly cause of how Jira works. During off-boarding process we get the group the user belongs to, store that within our process, remove all membership (except of Jira primary group), disable the user account, move it to proper OU and change the password to a random one.

This was all fine till we realized that apart from on-premises groups user also belongs to a number of AzureAD groups - mainly cause of Outlook groups and MS Teams groups created in AzureAD. 

> Cleanup TIME!

# The Resolution

There were two steps to fix this.

1. One time sweep to remove all stale groups of disabled users.
2. Expand our off-boarding process to include this task as well.

When doing this one-time purge I decided to take following approach:

- Get all disabled users from certain OUs
- Export that list (change management process :smile: )
- Connect to AzureAD and for each disabled user get his AzureAD group membership (property `DirSyncEnabled` not existing) with `Get-AzureADUserMembership` cmdlet
- Get a custom object and export both to csv (human processing - again change management process) and json (once change is accepted, re-use it with powershell). The returned group membership is a hashtable, and csv doesn't cope with that well :smile: . Need to flatten it with `$PSItem.GroupName -join ','`
- Remove user AAD group membership with `Remove-AzureADGroupMember` cmdlet.

# The Code

Remember this was one time sweep. The code is a nasty script, not a function but it gets the job done.

```powershell
#export folder path
$exportPath = 'c:\AdminTools\mczerniawski'
#AAD credentials
$credential = Get-Credential

#Get all disabled Users
$userOUs = @('OU=Users,DC=contoso,DC=com','OU=Leavers,DC=contoso,DC=com')

$disabledUsers = foreach ($ou in $userOUs) {
    get-aduser -filter {Enabled -eq $false} -SearchBase $ou
} 
$disabledUsers | Export-Csv -Path (Join-Path -Path $exportPath -ChildPath 'disabled_users.csv') -NoTypeInformation

#get user membership in AzureAD Groups
Connect-AzureAD -Credential $credential
Connect-MsolService -Credential $credential
$disabled_OnlineMembership = foreach ($user in $disabledUsers) {
    if ($user.UserPrincipalName) {
        $userObjectId = Get-Msoluser -UserPrincipalName $user.UserPrincipalName | Select-Object -ExpandProperty ObjectId
        $group = Get-AzureADUserMembership -ObjectId $userObjectId | Select-Object * | Where-Object {-not ($PSItem.DirSyncEnabled)}
        if ($group) {
            [pscustomobject]@{
                UserName = $user.SamAccountName
                DisplayName = $user.Name
                Enabled = $user.Enabled
                UserDN = $user.DistinguishedName
                AADUserObjecID = $userObjectId
                GroupName = $group.DisplayName
                GroupMail = $group.Mail
                AADGroupID = $group.ObjectID
            }
        }
    }
}

#Export For further Powershell processing object:
$disabled_OnlineMembership | ConvertTo-Json -Depth 99| Out-File (Join-Path -Path $exportPath -ChildPath 'disabled_onlineMembership.json')

#Export For further 'human' processing through excel:
$disabled_OnlineMembership | Select-Object UserName,DisplayName,Enabled,UserDN,AADUserObjectID,
                             @{n='Groups';e={$PSItem.GroupName -join ','}},
                             @{n='GroupMail';e={$PSItem.GroupMail -join ','}} |
                             Export-Csv -Path (Join-Path -Path $exportPath -ChildPath 'disabled_onlineMembership.csv') -NoTypeInformation 


#Import Data
$UsersToClean = Get-Content -Path (Join-Path -Path $exportPath -ChildPath 'disabled_onlineMembership.json') -RAW | ConvertFrom-Json 

#Remove from groups
foreach ($onlineUser in $UsersToClean) {
    Write-Host "Processing user {$($onlineUser.DisplayName)}"
    foreach ($group in $onlineUser.AADGroupID) {
        Write-Host "      Processing group {$($group)}"
        Remove-AzureADGroupMember -ObjectId $group -MemberId $onlineUser.AADUserObjectID
    }
}
   
```

# Summary

I always thought that SysAdmin job was `30%` improvements (new functionality), `30%` maintenance, `30%` cleanup and `10%` coffee. But with current ever-changing online world I'd say it's `50%` improvements, `50%` maintenance, `50%` cleanup and `50%` coffee. The question remains - where to get those missing `100%` from :smile:
