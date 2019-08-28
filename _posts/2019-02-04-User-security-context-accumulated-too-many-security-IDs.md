---
title: User Security Context Accumulated Too Many Security IDs
categories:
    - Office365
tags:
    - PowerShell
    - Security Groups
    - ActiveDirectory
last_modified_at: 2019-02-05T12:00:00+01:00
---

# The Story

Today I got an interesting call from my colleague. One of our users after changing his password was unable to log in to office.com, use Outlook or Skype. What's so interesting about it? It was one of those `enter the rabbit hole` questions :smile: .

After some initial shooting at the trouble that also included changing password - the output was the same. User was unable to log in to any office.com resources. After:
- verifying there are no active incidents on Microsoft side :grin: 
- trying to log in myself with his credentials
- checking AzureAD sync status 
- and a few more 

I still got the same page:

![Oops](/assets/images/posts/user-security-context/picture1.png)

So I tried running a process as that user:

![Oops2](/assets/images/posts/user-security-context/picture2.png)

Now we're getting to something.  Quick check for his group membership:

```powershell
$username = 'mczerniawski'
$dn = (Get-ADUser $username).DistinguishedName
$userGroups = Get-ADGroup -LDAPFilter ("(member:1.2.840.113556.1.4.1941:={0})" -f $dn)
$userGroups | Measure-Object | Select-Object -ExpandProperty Count
```
And the result was clear: 
> `1374`

Obviously `changing the password` wasn't the issue. In the meantime user was added to a few groups which exceeded the default number of 1000 security IDs [Microsoft Support KB](https://support.microsoft.com/en-us/help/275266/error-message-during-a-logon-attempt-the-user-s-security-context-accum)

# Let the hunt begin

Ok, let's hunt for the offending group/groups.

```powershell
$SearchBaseOU = 'OU=Security Groups,DC=contoso,DC=com'
$Groups = Get-ADGroup -Filter 'GroupCategory -eq "Security"' -SearchBase $SearchBaseOU -Properties memberof
$results = ForEach($Group in $Groups)
{
    #get members of current group
    $Members = Get-ADGroupMember -Identity $Group
    #get groups to which current group belongs to
    $MembersOf = $Group | Select-Object -ExpandProperty Memberof 
    #count
    $NumberOfMembers = $Members.count
    $NumberOfMembersOf = $MembersOf.count
    
    #output
    [pscustomobject]@{
        Group=$Group.DistinguishedName
        NumberOfMembers=$NumberOfMembers
        Members = $Members
        NumberOfMembersOf=$NumberOfMembersOf
        MembersOf = $MembersOf 
    }
}
```
Now, having the results I can easily get the information I need:

```powershell
$results | Sort-Object NumberofMembersof -Descending | Select-Object -First 10 | Select-Object Group,NumberofMembersof
```

In this case there were three `master access groups` for Sharepoint Online resources. Because for each site we create its own Active Directory groups for `Visitors`, `Members` and `Owners` to simplify management, there were also created three `master` groups and added respectively to *ALL* `Visitors`, `Members` and `Owners` groups.

|Group|NumberOfMembersOf|
|-----|-----------------|
|CN=SPO_All_Members,OU=Security Groups,DC=contoso,DC=com|349|
|CN=SPO_All_Visitors,OU=Security Groups,DC=contoso,DC=com|314|
|CN=SPO_All_Owners,OU=Security Groups,DC=contoso,DC=com|304|


# This ain't over yet!

Ok, the issue is resolved. A cleanup was made, AzureAD sync followed, user can log in,  **yay, let's call it a day and close the ticket**.

Wait a minute. How many more of our users will face the same issue today/tomorrow/next week?

It would be good to get all users and their current `memberof` information - with all groups the user belongs to - recursively:

```powershell
$users = Get-ADUser -filter * -SearchBase 'OU=Users,DC=contoso,DC=com'
$report = foreach ($user in $users) {
    $userGroups = Get-ADGroup -LDAPFilter ("(member:1.2.840.113556.1.4.1941:={0})" -f $user.distinguishedName) | Select-Object -expand Name | Sort-Object Name 
    [pscustomobject]@{
        UserName = $user.sAMAccountName
        GroupCount = $userGroups| Measure-Object | Select-Object -ExpandProperty Count
        Groups = $userGroups 
    }
}

$Date = Get-Date -f yyyyMMdd_HHmm
$report | Export-CSV -Path ('C:\AdminTools\UserGroupReport_{0}.csv' -f $Date) -Delimiter ';' -NoTypeInformation
```

Now that's something I can work with:

![Oh sh!](/assets/images/posts/user-security-context/picture3.png)

It's gonna be a busy day! :smile:


# Update

We decided to get a `visual` overview of what's going on where in our infrastructure.  I was going to use [BloodHound](https://github.com/BloodHoundAD/BloodHound/wiki/Getting-started) for this or write my own GraphViz implementation, but my colleague found a [great script](https://gallery.technet.microsoft.com/scriptcenter/Graph-Nested-AD-Security-eaa01644) from [Axel Limousin](https://social.technet.microsoft.com/profile/axel%20limousin%20-%20itsi).

The usage is quite simple and everything is documented by Axel.

Another benefit of this is that we were able to found some nesting potential issues.