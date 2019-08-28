---
title: Format Drive. Remotely
categories:
    - PowerShell
tags:
    - PowerShell
---

# Format drive - the Lazy way

Another day, another quicky. A few new VMs running with additional drives that someone forgot to initialize? Considering RDPing to each of those? Or maybe mmc console (DiskMGMT.MSC) and initializing one by one? Maybe [Honolulu](https://blogs.technet.microsoft.com/windowsserver/2017/09/14/sneak-peek-4-introducing-project-honolulu-our-new-windows-server-management-experience/) will help? 

No worries, PowerShell will do just fine. I love those quickies that can save you a few clicks here and there!

# The RAW meat

So, basically formatting a drive requires these four steps:
1.	have a disk with raw partition (uninitialized) 😊
2.	initializing the drive
3.	creating new partition, and assigning a letter to it
4.	finally – formatting the drive

{% gist b48f6aebbf547ce7f591783e3d06c94f %}

# Let's make it usable

Now, if you're like me and would like to be able to connect to remote machines with different credentials ([LAPS!](https://www.mczerniawski.pl/laps/powershell/tutorial/deploy-laps-with-powershell/)) and format drives with different labels and file systems - there's a function for you here:

{% gist c5d2b8fbe1052f8492855916e6bf132c %}

Or You can grab it as part of PPoSh (Polish PowerShell User Group) Module from [GitHub](https://github.com/PPOSHGROUP/PPoShTools) or [PowerShell Gallery](https://www.powershellgallery.com/packages/PPoShTools). There's more goodies in there.
If you've installed it before (`Install-Module PPoShTools`), just update it (`Update-Module PPoShTools`)

