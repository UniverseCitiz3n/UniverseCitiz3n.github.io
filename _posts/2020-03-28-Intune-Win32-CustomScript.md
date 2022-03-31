---
title: Harness Intune Win32 app installer
categories:

    - Intune

tags:

    - Intune
    - Workstations
    - Powershell

excerpt: Patching vulnerabilities 🛡 with custom script and Intune Win32 package deployment 

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Whole world gone mad but keeping your endpoints patched should not wait. Case for this post is to fix vulnerability **COVID-19** 🦠 on devices 😷... wait what?? I meant **INTEL-SA-00189**! Using Intune for this task is now the best choice under circumstances when 100% of employees work remote from homes. So let's do it!

# Prepare your script

To use Intune Win32 application deployment you need to wrap installer with special tool (more info below), provide install and uninstall command and you are kind of done. For some basic stuff or in-house apps it should be enough but when you want some more control over what is happening during deployment I will let you in on a little secret... **you can wrap Powershell script**🥂. Well that's neat! Thanks to that I was able to check if workstation has my favorite folder for storing stuff and determine **exit code** based on installation result.

``` powershell
#Check for path where logs will be stored
if (!(Test-Path C:\Temp)) {
    New-Item -Path C:\ -ItemType Directory -Name Temp
    New-Item -Path C:\Temp -ItemType Directory -Name SU
}
elseif (!(Test-Path C:\Temp\SU)) {
    New-Item -Path C:\Temp -ItemType Directory -Name SU
}

function Get-Info
{
    "[$Env:ComputerName] [$Tag] [$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss').ToString())] [$($env:UserName)] [$($MyInvocation.ScriptLineNumber)]"
}

function Exit-WithCode
{
    param
    (
        $exitcode
    )

    $host.SetShouldExit($exitcode)
    exit
}

$SoftwareName = 'IntelGraphics'
#Check currently installed version of driver
$InstallationVersion = Get-CimInstance -ClassName win32_pnpsigneddriver | Select-Object devicename, manufacturer, driverversion | Where-Object {$PSItem.DeviceName -like 'Intel(R)*HD Graphics*'}
#Write driver version to file
"$(Get-Info) Installed version $($InstallationVersion.driverversion)" | Out-File -Append -FilePath c:\Temp\SU\IntelGraph.log
#Install drivers silently
$Process = start-process ".\Intel\igxpin.exe" -ArgumentList @('-report c:\temp\su\IntelGraph.log', '-s') -NoNewWindow -Wait -PassThru
$Process.WaitForExit()
#Determine exit of installation based on exitcode of Intel  
If($Process.Exitcode -eq '0'){
    #Hard reboot
    Exit-WithCode -exitcode 1641
}else{
    #Retry
    Exit-WithCode -exitcode 1618
}
```

There is not much going but it shows how simple it can be to fit installation to your needs. Notice that Intel installer path is **.\Intel\igxpin.exe** it means that Microsoft Intune Management Extension runs installation with current path set to inside of deployed package.

![path]({{ site.url }}/assets/images/posts/2020-03-28_1.jpg)

Another thing is that after installation is complete I'm exiting the script with specific codes. These are default codes with assigned action. I will explain them later.😉

# Microsoft Intune Content Prep Tool

Before you will be able create app deploy in Intune you need to wrap your stuff into **.intunewin** format. Go [here](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool) to get wrapping tool 🎁. Using it is child's play:

![wrap]({{ site.url }}/assets/images/posts/2020-03-28_wrap.gif)

Prepared package upload to app profile

![wrap2]({{ site.url }}/assets/images/posts/2020-03-28_2.jpg)

# Installation command and return codes

Going further, you will need to specify command for installing your package. Because it is **powershell** script remember to run it with **execution policy bypass** parameter.

![install]({{ site.url }}/assets/images/posts/2020-03-28_3.jpg)

To find out software uninstall command run code below on device which already has it installed

``` powershell
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction Ignore |
Where-Object DisplayName |
Select-Object -Property DisplayName, DisplayVersion, UninstallString, InstallDate |
Sort-Object -Property DisplayName
```

It scans through registry and will list all applications on device.<br>
Installing Intel Graphics drivers requires device reboot. It can be done with installation parameter but it will do the reboot immediately which in business is not a good option. Better way is to act accordingly to return codes.<br>

**Soft reboot**

* will only show Toast notification that your device needs to be restarted after installing distributed software. In your OS language.

![soft]({{ site.url }}/assets/images/posts/2020-03-28_4.jpg)

**But only if you allow it**

![softnotif]({{ site.url }}/assets/images/posts/2020-03-28_5.jpg)

**Hard reboot**

* will too show Toast notification about restart but also force user to reboot the device. And setting **Restart grace period** is good practice.

![grace]({{ site.url }}/assets/images/posts/2020-03-28_6.jpg)

![notify]({{ site.url }}/assets/images/posts/2020-03-28_8.jpg)

And in summary you will see

![status]({{ site.url }}/assets/images/posts/2020-03-28_7.jpg)

# Detection rule

Last step of app deployment is verification if software is present on device. You can specify this setting is many different ways:

![detection]({{ site.url }}/assets/images/posts/2020-03-28_9.jpg)

More detailed info you will find [here](https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management#step-4-detection-rules). In this deployment I decided to use **Custom detection script**

``` powershell
$Driver = Get-CimInstance -ClassName win32_pnpsigneddriver | Select-Object devicename, manufacturer, driverversion | Where-Object {$PSItem.DeviceName -like 'Intel(R)*HD Graphics*'}

if ($Driver.driverversion -eq '26.20.100.6888') {
    Write-Output 'Newest version installed'
    #Exit code will be 0 and STDOUT not empty
}
else {
    exit 1
}

```

And this table explains how it works

Exit code|Data read from Write-Output|Detection state
0|Empty|Not detected
0|Not empty|Detected
Not zero|Empty|Not detected
Not zero|Not Empty|Not detected

# Summary

Deployment of apps using Win32 allows you to do a lot of magic with great precise! For sure I will play with it a lot.🧙‍♂️<br>
Sneak peak on deployment status:

![detection]({{ site.url }}/assets/images/posts/2020-03-28_10.jpg)

See you in next! 😉 🧠
