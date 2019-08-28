---
title: Fix Hyper-V - The object might have been deleted
categories:
    - HyperV
tags:
    - PowerShell
    - HyperV
    - HPE
excerpt: Thank you HPE for your updates...
---

# Gotta Love the gottchas

So here's the story. I have a test Hyper-V cluster of 5 nodes - all HP Proliant DL 380 G7 connected to HP MSA2040 and HP P2000 arrays.  
It's been working quite fine as a test environment. Recently I've decided to update drivers and firmware to newest version available in SPP `P03093_001_spp-Gen8.1-SPPGen81.4` (2019 edition).

Patching went well, nodes rebooted, cluster operational, failvoer cluster manager working and reporting no issues, VMs running.  
Then a few days later I try to export a running VM. I (~~try to~~) connect using Hyper-V and get:

![Hyper-V]({{ site.url }}{{ site.baseurl }}/assets/images/posts/fix-hyperv-management/picture1.png)

Well, I check with FailoverCluster as see no issues. 3 out of 5 servers are operating normally.  
I try to restart vmms service

```powershell
Restart-Service vmms
```

Still no go. Let's try and reboot the server :grin:

```powershell
Restart-Computer TestHyperv1 -Protocol WSMan -Wait -force
```

A quick search and I get to [this thread from 2015](https://social.technet.microsoft.com/Forums/en-US/1cc9115d-5fce-4a64-a90f-d3fdc008b861/windows-10-build-10240-managing-hyperv-on-2012-r2-datacenter-cannot-connect?forum=winserverhyperv). A slightly different error, but provided by Brian Ehlert fix works. Running as administrator below command works:

```
MOFCOMP %SYSTEMROOT%\System32\WindowsVirtualization.V2.mof
```

Now, I need to find out WHAT caused the issue and WHY only on 2 out of 5 identical nodes :evil: