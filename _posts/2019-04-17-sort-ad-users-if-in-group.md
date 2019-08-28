---
title: Sort AD Users if they belong to AD Group
categories:
    - PowerShell
tags:
    - ActiveDirectory
    - Powershell
excerpt: How to quickly Sort users if they belong to a set of groups
---

# Quicky Dirty

So here's the situation - a user on reddit asked a question:

### Get-Help
> How can I compare two arrays? (Active directory)

> I have an array containing disabled users. $disabledusers

> I have an array containing groups that disabled users belong to. $groups

> Not all users in the disabled users array belong to a group.

> How can I print only the users from $disabledusers that belong to a group? ($groups)?

### Find-Solution

If I assume that $disabledUsers contain full AD Objects (not only samaccounts) and $groups contain a list of groups then this would like like this:

```powershell
$Groups | ForEach-Object {
    $Members = Get-ADGroupMember $PSItem
    Compare-Object -ReferenceObject $Members.samaccountname -DifferenceObject $disabledUsers.samaccountname -IncludeEqual |
        Where-Object {$PSItem.SideIndicator -eq '=='} |
        Select-Object -ExpandProperty InputObject
}
```

As PowerShell loves objects let's sort the input into 3 variables:

```powershell
$Both = $OnlyUsers = $OnlyGroups = @()
$Groups | ForEach-Object {
    $Members = Get-ADGroupMember $PSItem
    $CompareResult = Compare-Object -ReferenceObject $Members.samaccountname -DifferenceObject $disabledUsers.samaccountname -IncludeEqual
    Switch ($CompareResult) {
        {$PSItem.SideIndicator -eq '=='} {
                                           $Both += $PSItem.InputObject
                                         }
        {$PSItem.SideIndicator -eq '<='} {
                                           $OnlyGroups += $PSItem.InputObject
                                         }
        {$PSItem.SideIndicator -eq '=>'} {
                                           $OnlyUsers += $PSItem.InputObject
                                         }
    }
}

Write-Host "Both Sources: `n $Both"
Write-Host "Only Groups: `n $OnlyGroups"
Write-Host "Only Users: `n $OnlyUsers"
```
## Switch

Switch will act like `foreach-object | if {} elseif {} elseif {}` statement here. If you're more interested, Kevin Marquette is the man in [explaining stuff](https://powershellexplained.com/2018-01-12-Powershell-switch-statement/).