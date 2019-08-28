---
title: Privileged Users in Active Directory
categories:
    - ActiveDirectory
tags:
    - PowerShell
    - ActiveDirectory
    - Privilged Users
---

# Intro
> 'Privileged' accounts and groups in Active Directory are those to which powerful rights, privileges, and permissions are granted that allow them to perform nearly any action in Active Directory and on domain-joined systems." (from [Appendix B: Privileged Accounts and Groups in Active Directory](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-b--privileged-accounts-and-groups-in-active-directory) ).

If you're managing an Active Directory domain, You'd better keep an eye on those groups. If you'd like to know more, head to [adsecurity.org](https://adsecurity.org). Sean Metcalf is an never ending well of knowledge ([link](https://adsecurity.org/?p=3658)).


# Task for today
Long time ago I had a script that was looking at Privileged Groups and printed out current `privileged users` as well as changes in last 24 hours. Today I decided to do a re-write and wrap it into functions. The task is fairly simple:
- One function to get all privileged users
- One function to get changes

Those should be capable of running against different domains as well.

# The Raw meat

## Get-PrivilegedUsers

To get the `Privileged Groups` I will be using a filter `'AdminCount -eq 1'`. Then I'll just loop through each group and get all members. The output will contain samaccountname and Name of the user, the group it belongs to and DomainController that was queried:

{% gist af18a5b41918de49764ff3fc19300437 %}

## Get-PrivilegedGroupChanges

Similar as before I'll get all `Privileged Groups` with the same filter. Then I'll use replication attribute metadata `Get-ADReplicationAttributeMetadata` and `LastOriginatingChangeTime` on members to select only those who changed in last `$Hours`.

{% gist 54912f5feca8dadf3f9425d8b9e84c97 %}



