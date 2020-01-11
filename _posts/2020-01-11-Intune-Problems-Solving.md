---
title: Intune - dealing with ErrorCode 0x8018002b 
categories:

    - Cloud

tags:

    - Intune
    - ActiveDirectory
    - Workstation
    - Windows 10

excerpt: A few things you should try that might help you 👨‍💻

comments: true

---
<!-- toc -->

# Intro

Happy New Year!🥳 Starting 2020 I promised myself to increase frequency of the posts so fingers crossed that it works out😉

In this post you will find couple of steps that are worth to try if your device is having problems enrolling to Intune. I can't guaranty that will help with every device. That's why you should think of this post as check list of things to keep in mind while debugging workstation.

My environment configuration:

* Hybrid Azure AD Join
* Auto-enrollment to Intune with GPO

Things that will come in handy during troubleshooting:

* dsregcmd /status - cmdlet which shows is device is AAD joined. More [details](https://docs.microsoft.com/pl-pl/azure/active-directory/devices/troubleshoot-device-dsregcmd)
* Event Viewer - Application and Services Logs:
    - Microsoft/Windows/AAD
    - Microsoft/Windows/DeviceManagement-Enterprise-Diagnostics-Provider
    - Microsoft/Windows/User Device Registration
* Systeminfo

# BIOS update

Check if your device has up-to date BIOS version. Sometimes simple plain update will get things moving. If you are using Dell laptops it is best to use **Dell Command | Update** tool. Version 3.1.0 brought at of nice improvements and features! I like using it from Powershell terminal and it is very simple:

``` powershell
#Go to location of installation
cd 'C:\Program Files (x86)\Dell\CommandUpdate'
#Firstly you need to set bios password if you have one
./dcu-cli.exe /configure -biospassword="YourBiosPass"
#Response should be
'-biospassword' setting updated with value 'YourBiosPass'.
Execution completed.
Program exited with return code: 0
#Updating BIOS
./dcu-cli.exe /applyupdates -autoSuspendBitLocker
#Tool will scan device for any drivers that need update. For BIOS update laptop needs to connected to power source and -autoSuspendBitLocker is needed too.
```
after reboot update will be applied.

# Boot mode

In my experince if device 

See you in next! 😉 🧠

