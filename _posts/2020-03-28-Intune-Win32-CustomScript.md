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

To user Intune Win32 application deployment you need to wrap installer with special tool (more info below), provide install and uninstall command and you are kind of done. For some basic stuff or in-house apps it should be enough but when you want some more control over what is happening during deployment I will let you in on a little secret... **you can wrap Powershell script**🥂. Well that's neat! Thanks to that I was able to check if workstation has my favorite folder for storing stuff and determine **exit code** based on installation result.

``` powershell
#Check for path where logs will be stored
if (!(Test-Path C:\Temp)) {
    New-Item -Path C:\ -ItemType Directory -Name Temp
    New-Item -Path C:\Temp -ItemType Directory -Name SU
}
elseif (!(Test-Path C:\Temp\SU)) {
    New-Item -Path C:\Temp -ItemType Directory -Name SU
}

$SoftwareName = 'IntelGraphics'
#Check currently installed version of driver
$InstallationVersion = Get-CimInstance -ClassName win32_pnpsigneddriver | Select-Object devicename, manufacturer, driverversion | Where-Object {$PSItem.DeviceName -like 'Intel(R)*HD Graphics*'}
#Write driver version to file
"[$Env:ComputerName] [$SoftwareName] [$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss').ToString())] Installed version $($InstallationVersion.driverversion)" | Out-File -Append -FilePath c:\Temp\SU\IntelGraph.log
#Install drivers silently
$Process = start-process ".\Intel\igxpin.exe" -ArgumentList @('-report c:\temp\su\IntelGraph.log', '-s') -NoNewWindow -Wait -PassThru
$Process.WaitForExit()
#Determine exit of installation based on exitcode of Intel  
If($Process.Exitcode -eq '0'){
    #Hard reboot
    Exit 1641
}else{
    #Retry
    Exit 1618
}
```

There is not much doing but it shows how simple it can be to fit installation to your needs. Notice that Intel installer path is **.\Intel\igxpin.exe** it means that Microsoft Intune Management Extension runs installation with current path set to insides of deployed packaged.

![path]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_1.jpg)

Another thing is that after installation is complete I'm exiting the script with specific codes. These are default codes with assigned action. I will explain them later.😉

# Microsoft Intune Content Prep Tool

Before you will be able create app deloy in Intune you need to wrap you stuff into **.intunewin** format. Go [here](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool) to get wrapping tool 🎁. Using it is child's play:

![wrap]({{ site.url }}{{ site.baseurl }}/assets/images/posts/wrapping.mp4)

Prepared package upload to app profile

![wrap2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_2.jpg)

# Installation command and return codes

Going further, you will need to specify command for installing your package. Because it is **powershell** script remember to run it with **execution policy bypass** parameter.

![install]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_3.jpg)

In this case I'm updating drivers so uninstall command won't be really needed so **Exit 0** should be fine. I hope that it won't brake anything that I'm not aware right now... 😅<br>
After installing Intel Graphics drivers you need reboot the device. It can be done with installation parameter but it will do the reboot immediately which in business is not a good option. Better way is to act accordingly to return codes.<br>
**Soft reboot** - will only show Toast notification that your device needs to be restarted after installing distributed software. In your OS language.

![soft]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_4.jpg)

**But only if you allow it**

![softnotif]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_5.jpg)

**Hard reboot** - will too show Toast notification about restart if you set **Restart grace period**

![grace]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_6.jpg)

![notify]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_8.jpg)

And in summary you will see

![status]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_7.jpg)

# Detection rule

Last step of app deployment is verification if software is present on device. You can specify this setting is many different ways: 

![detection]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_7.jpg)

More detailed info you will find [here](https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management#step-4-detection-rules). In this deployment I decided to use **Custom detection script**

``` powershell
$Driver = Get-CimInstance -ClassName win32_pnpsigneddriver | Select-Object devicename, manufacturer, driverversion | Where-Object {$PSItem.DeviceName -like 'Intel(R)*HD Graphics*'}

if ($Driver.driverversion -eq '26.20.100.6888') {
    Write-Output 'Newest version installed'
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

Deployment of apps using Win32 allows you to do a lot of magic with great precise! For sure I will play with it a lot.🧙‍♂️

![detection]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-03-28_10.jpg)

See you in next! 😉 🧠

