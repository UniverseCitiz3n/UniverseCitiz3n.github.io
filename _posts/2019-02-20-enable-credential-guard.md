---
title: Enable Credential Guard
categories:
    - Security
tags:
    - CredentialGuard
    - Windows 10
    - PowerShell
excerpt: Easy way to enable Credential Guard on Win 10 machine
---

# Why

[Credential Guard](https://docs.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-how-it-works) is one of `Identity Protection` features that enhance the security of credentials stored on your machine. In other words - if properly configured it will stop or seriously slow down an attacker from aquiring your credentials stored in memory.
 
There are a few prerequisites that must be fulfilled before it works.

# Check

Microsoft publishes a [Windows Defender Device Guard and Windows Defender Credential Guard hardware readiness tool](https://www.microsoft.com/download/details.aspx?id=53337) that I will use here to verify if my machine is ready.

## Download and extract

```powershell
$ReadinessToolsURL = 'https://download.microsoft.com/download/B/D/8/BD821B1F-05F2-4A7E-AA03-DF6C4F687B07/dgreadiness_v3.6.zip'
$DGreadinessFolder = (Split-Path $ReadinessToolsURL -Leaf).Replace('.zip','')
$DownloadPath = "$env:USERPROFILE\Downloads"
$OutFileName = 'DGReadiness.zip'
$DestinationUnzipPath = 'C:\AdminTools\'
$OutFile = (Join-Path -Path $DownloadPath -ChildPath $OutFileName)
Invoke-WebRequest -UseBasicParsing -Uri $ReadinessToolsURL -OutFile $OutFile
Expand-Archive -Path $OutFile -DestinationPath $DestinationUnzipPath -force
$file = Get-ChildItem -Path (Join-Path -Path $DestinationUnzipPath -ChildPath $DGreadinessFolder) -Filter "*.ps1" | Select-Object -ExpandProperty FullName
Start-Process powershell.exe -Verb RunAs -ArgumentList "$file -Ready" -Wait
Get-Content C:\DGLogs\DeviceGuardCheckLog.txt
```

This code will:

- download the tool from MS site
- extract it
- start new PowerShell process as Admin (I hope you're not downloading files from Internet as Administrator? :grin: ) 
- and finally will display the log. 

```
PS C:\AdminTools\dgreadiness_v3.6> .\DG_Readiness_Tool_v3.6.ps1 -Ready
###########################################################################
Readiness Tool Version 3.4 Release.
Tool to check if your device is capable to run Device Guard and Credential Guard.
###########################################################################
###########################################################################
OS and Hardware requirements for enabling Device Guard and Credential Guard
 1. OS SKUs: Available only on these OS Skus - Enterprise, Server, Education, Enterprise IoT, Pro, and Home
 2. Hardware: Recent hardware that supports virtualization extension with SLAT
To learn more please visit: https://aka.ms/dgwhcr
###########################################################################

Credential-Guard is not running.
HVCI is not running.
Config-CI is not running. (Not Enabled)
Not all services are running.
```

# Fix

Seems like my machine is not ready. 
> Time to fix it! 

The easiest way is to use the same script provided by Microsoft. This time with '-Enable -AutoReboot' parameters

```powershell
Start-Process powershell.exe -Verb RunAs -ArgumentList "$file -Enable -AutoReboot" -Wait
```

After a reboot let's check it again:

```
PS C:\AdminTools\dgreadiness_v3.6> .\DG_Readiness_Tool_v3.6.ps1 -Ready
###########################################################################
Readiness Tool Version 3.4 Release.
Tool to check if your device is capable to run Device Guard and Credential Guard.
###########################################################################
###########################################################################
OS and Hardware requirements for enabling Device Guard and Credential Guard
 1. OS SKUs: Available only on these OS Skus - Enterprise, Server, Education, Enterprise IoT, Pro, and Home
 2. Hardware: Recent hardware that supports virtualization extension with SLAT
To learn more please visit: https://aka.ms/dgwhcr
###########################################################################

Credential-Guard is enabled and running.
HVCI is enabled and running.
Config-CI is enabled and running. (Audit mode)
HVCI, Credential-Guard, and Config-CI are enabled and running.
```

# Scale 

If you'd like to scale out - and set it up on all your machines - I recommend reading through [Manage Windows Defender Credential Guard](https://docs.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage) and watching [Deep Dive into Credential Guard](https://mva.microsoft.com/en-us/training-courses/deep-dive-into-credential-guard-16651?l=sRcyvLJyC_3304300474)



