---
title: PowerShell process with alternate credentials RunAs Administrator
categories:
    - PowerShell
tags:
    - PowerShell
    - RunAs
---

# The WHY?

Imagine an environment where users have no administrative rights on their machines. Yes, those environments DO happen. Now, you either have a special account to run privileged operations for EACH of them or you have [LAPS](https://technet.microsoft.com/en-us/mt227395.aspx) deployed (which I highly recommend anyway!). 

Usually, you're running things from your local workstation from where you remotely connect with the credentials and all is fine. But there's the day you're summoned to the workstation (let it be your Boss' newest laptop). You're considered a PowerShell guru. You won't fall back. You're logged in as your Boss' account. You still need to run PowerShell script as alternate user (lets call it SuperAdmin) but also as Administrator (to flush DNS settings). What do you do?

# Cookbook by Lee Holmes
You can user Start-ProcessAsUser from PowershellCookbook module:

```powershell
Get-Command Start-ProcessAsUser
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Start-ProcessAsUser                                1.3.6      PowerShellCookbook

NAME
    Start-ProcessAsUser

SYNOPSIS
    Launch a process under alternate credentials, providing functionality
    similar to runas.exe.


    -------------------------- EXAMPLE 1 --------------------------

    PS >$file = Join-Path ([Environment]::GetFolderPath("System")) certmgr.msc

    PS > Start-ProcessAsUser Administrator mmc $file

```

# Start-Process inception
You can also create a simple Start-Process inception. 
```powershell
Start-Process powershell.exe -Credential (Get-Credential) -NoNewWindow -ArgumentList {
  Start-Process powershell.exe -Verb RunAs -ArgumentList {
    Import-Module PPoShTools
    Import-Module c:\PowerShell\SomeVeryImportantFunction.ps1
    
    Invoke-MyVeryImportantFunction
  }
}
```
In our example it will look like this:
```powershell
Start-Process powershell.exe -Credential (Get-Credential) -NoNewWindow -ArgumentList {
  Start-Process powershell.exe -Verb RunAs -ArgumentList {
    Clear-DnsClientCache
  }
}
```
## Credentials from file

This can be also used to consume stored credentials in xml file. First, for each user and each machine that this should be used you need to write credentials to file:
```powershell
Get-Credential | Export-Clixml C:\AdminTools\Tests\funnycats.jpg
```

Then you can create a ps1 script file that will be invoked from scheduled tasks:
```powershell
$creds = Import-Clixml C:\AdminTools\Tests\funnycats.jpg
Start-Process powershell.exe -Credential (Get-Credential) -NoNewWindow -ArgumentList {
  Start-Process powershell.exe -Verb RunAs -ArgumentList {
    Import-Module PPoShTools
    Import-Module c:\PowerShell\SomeVeryImportantFunction.ps1
    
    Invoke-MyVeryImportantFunction
  }
}

```
## No silver bullet though

This is not perfect, as your Boss can use the same command to extract stored credentials from funnycats.jpg and use it at his own fun.

