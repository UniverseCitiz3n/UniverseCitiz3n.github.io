---
title: Add Disk to VM
categories:
    - HyperV
tags:
    - HyperV
    - PowerShell
    - Virtual Machine
excerpt: Quickly add disks to Virtual Machines
---

# Why

Adding a disk to a VM is not a big issue. I can use Hyper-V console or Windows Admin Center or PowerShell. But because I need to do it on a frequent basis and it's boring I wanted to find a better way.

Just a reminder - how to add VHD to a VM:
- In Hyper-V we use Settings menu for given VM:

![HyperV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/add-disk-to-vm/picture1.png) 

Select New, and then name it, select path and proper options.

- In Windows Admin Center we need to get to VMs menu, Inventory, select given VM and go to disks:

![WAC]({{ site.url }}{{ site.baseurl }}/assets/images/posts/add-disk-to-vm/picture2.png) 
	
Then again, fill in proper path and options.
In PowerShell - it's sligthly better:

```powershell
#Create VHD in given path
New-VHD -Path 'Path' -Dynamic -SizeBytes 100GB
#Attach it to a VM
Add-VMHardDiskStrive -VMName 'VM1' -ComputerName 'HyperVHost' -Path 'Path'
```

There are two problems with this. First - I need to know WHERE to put the files for given VM. In general I have all disks on the same CSV - along with VM configuration. Second - it's boring :)

# The Idea

So, I wanted to speed this up a bit. What I know?

- In general I name disks according to this template: `<VMName>_disk<number>.vhdx`.
- Disks are in the same location as other VM files (like configuration).
- When disk is attached in correct order - it usually gets the same disk number within the Windows OS. This simplifies a bit later on. 
- I use Hyper-V hosts from 2012R2 version to 2019.
- Some Hyper-V hosts are in different domains - meaning I need to use Credential parameter.
- Sometimes VHD is in a different location.
- Sometimes I want to manually name the VHD. 
- I use dynamic disks now, but I want to support other types later on as well. 
Knowing this I ended up with a function that will:

1. Use Invoke-Command  
	- I will be able to connect to different versions of Hyper-V 
	- I will be able to use optional Credential parameter to connect to Hyper-V hosts in different domains. Or run it from unprivilged powershell session. 
	- This will also work from PowerShell Core 
2. Gather some basic info about disks of given VM. 
	- This will give me current VM path location
	- And also the number of current VHDs. (remember the `<VMName>_disk<number>.vhdx` part?
3. Create VHD and then attach it to a VM.

Here's the code:
{% gist e1b2c5e907e53e8e8f45c21496589412 %}

What's next? Well a VHD needs to be formatted right? Booring:) Glad I have this [Format Drive. Remotely](https://www.mczerniawski.pl/powershell/format-drive-remotely/).

# Final code

Well if I combine both of these functions I can do it in one swing. For multiple disks at once!

{% gist b3ef3c684d83f78013890169d2d41b23 %}

Here's the output:

{% gist 4a8bb6f6ac80c76e4317a0d24d87b9e9 %}


