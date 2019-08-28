---
title: Filter AD users with exclusion list and split into chunks 
categories:
    - ActiveDirectory
tags:
    - ActiveDirectory
    - PowerShell
excerpt: Imagine you need to grab all users from a given location, check whether they are not in a specific group and then split the result into smaller chunks.
---

# The Story

Recently I got a simple task - add a bunch (600+) of users from a specific OU to a specific AD Group. BUT - I was meant to add only users not members of other groups AND do it in waves (let's say of 40 people) at once. As we were rolling out a new feature we wanted to be sure that some users would be `skipped` at first run.

It shouldn't be hard. Let's see...

## Small steps

First I need to declare some variables like 

- `location` ($OUs) where all my user accounts are located, 
- `group` to be added to ($GroupName) 
- and the `exclusion` groups ($ExcludeGroups) which members should be skipped. 
- I also want the `splitting factor` ($SplitAt) - how many users should be in each 'wave'.

```powershell
$GroupName = 'NewFeatureGroup'
$OUs = @('OU=Users,OU=Site1 Users,DC=contoso,DC=com','OU=Users,OU=Site2 Users,DC=contoso,DC=com')
$ExcludeGroups = @('GroupLeftOver1','NewFeatureGroup')
$SplitAt = 40
```

I'm adding the destination group ($GroupName) to the excluded group as well. This way I can re-run the script and get only new users from given location - not those that are already in.

Now, I need to get users from $ExcludeGroups, then from all $OUs and filter them out. Sort them at the end. Easy

```powershell
$ExcludeUsers = foreach ($group in $ExcludeGroups) {
    Get-ADGroupMember -Identity $group | ForEach-Object { Get-ADUser -identity $PSItem }
}
$Users = foreach ($OU in $OUs) {
    Get-ADUser -filter * -SearchBase $OU  | Where-Object {
        $PSItem.samaccountname -notin $ExcludeUsers.samaccountname
    }
}

$FinalUsers = $Users| Sort-Object
```

As I'll be using `for()` loop to split into groups, I need to know how many groups will be needed. In other words - If I would have 412 users and would like to split in chunks of 40, I would get 11 groups. If there would be 754 users I would need 19 groups.

```powershell
$maxGroups  = [math]::Round($FinalUsers.Count / $SplitAt)
```

Now, Let's split. I've decided to use an array of hashtables. Each group would be a hashtable with values `GroupNumber` and `GroupMembers`. This will allow me to retrieve members of each group separately if needed.

```powershell
$SplitArray = @()
$SplitArray = for ($i = 0; $i -le $maxGroups ; $i++){
    @{
        GroupNumber = $i
        GroupMembers = $FinalUsers | Select-Object -First $SplitAt -Skip ($i*$SplitAt)
    }
}
```

Now when I need to add them (or just retrieve) I can easily do this with:

```powershell
#select first group
$GroupToSelectAndAdd = 0
$ToAdd = ($SplitArray | Where-Object {$PSItem.GroupNumber -eq $GroupToSelectAndAdd} )['GroupMembers']
Add-ADGroupMember -Identity $GroupName -Members $ToAdd
```

## Full script

Here's the full script

```powershell
$GroupName = 'NewFeatureGroup'
$OUs = @('OU=Users,OU=Site1 Users,DC=contoso,DC=com','OU=Users,OU=Site2 Users,DC=contoso,DC=com')
$ExcludeGroups = @('GroupLeftOver1','NewFeatureGroup')
$SplitAt = 40

$ExcludeUsers = foreach ($group in $ExcludeGroups) {
    Get-ADGroupMember -Identity $group | ForEach-Object { Get-ADUser -identity $PSItem }
}
$Users = foreach ($OU in $OUs) {
    Get-ADUser -filter * -SearchBase $OU  | Where-Object {
        $PSItem.samaccountname -notin $ExcludeUsers.samaccountname
    }
}

$FinalUsers =$Users| Sort-Object

$maxGroups  = [math]::Round($FinalUsers.Count / $SplitAt)

$SplitArray = @()
$SplitArray = for ($i = 0; $i -le $maxGroups ; $i++){
    @{
        GroupNumber = $i
        GroupMembers = $FinalUsers | Select-Object -First $SplitAt -Skip ($i*$SplitAt)
    }
}
#select first group
$GroupToSelectAndAdd = 0
$ToAdd = ($SplitArray | Where-Object {$PSItem.GroupNumber -eq $GroupToSelectAndAdd} )['GroupMembers']
Add-ADGroupMember -Identity $GroupName  -Members $ToAdd

#select fifth group
$GroupToSelectAndAdd = 4
$ToAdd = ($SplitArray | Where-Object {$PSItem.GroupNumber -eq $GroupToSelectAndAdd} )['GroupMembers']
Add-ADGroupMember -Identity $GroupName  -Members $ToAdd
```

