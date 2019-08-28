---
title: Get VM Process Id
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - VM
    - Process ID
---

# The task

Imagine a standard operation - I need to expand vhdx size. It isn't hard, right? Just:

- go to Hyper-V manager, 
- right click the VM,
- Select settings,
- Select vhdx you want to expand,
- Click edit
- Then next
- Then select expand, click next
- Select new size,
- Then next
- Then finish.

Or I can use PowerShell:

1. Get VM hard disk location
2. Resize VHD file

{% gist dad726ac1ef101261146b69ed19763b3 %}

# Trouble round the corner

But then the nasty gnome comes in. The task doesn't complete. Within **30 minutes**. This is a dynamicly expanding disk. Shouldn't take longer than a few seconds. 

I try to stop the VM from within the guest OS. No go. 

I try to turn it off from Hyper-V host level. No go again. 

VM stays in `'Stopped-Critical'` state. I try to kill the process vmwp.exe that is responsible for this VM. To get that, I first need VM GUID. 

GUI way is to go to VM folder and check for xml name:

![VM]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-vm-process-id/picture1.png)

Now, using ProcessExplorer I can add UserName column (View-> Select Columns) and check for given GUID:

![GUID]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-vm-process-id/picture2.png)

Or I can use PowerShell:

{% gist f22dd5409e19deb8f1449e738f15b9b0 %} 

# Not so happy ending

Now, killing `vmwp` process **USSUALY** works. 

It didn't work this time and caused the vmms (Virtual Machine Management Service) to stuck. 

> Which in the end caused the whole node to go crazy. 

But that's another story.

