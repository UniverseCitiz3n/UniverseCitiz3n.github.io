---
title: Windows 2016 S2D - Balance VMs
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - S2D
    - Balance
---

# Reload!

Another day - another dirty - quicky. 

![Reload]({{ site.url }}{{ site.baseurl }}/assets/images/posts/s2d-balance-vms/picture1.jpg)

If you have a Windows 2016 Hyper-V cluster and a bunch of VMs you may have noticed an effect of auto balance feature. It evaluates a node's load based on some heuristics and then moves compute resources to a better node. More details can be found [here](https://blogs.msdn.microsoft.com/clustering/2016/04/29/failover-cluster-node-fairness-in-windows-server-2016/). It is enabled by default but can be easily adjusted if need be.

In my environment I need to rebalance VMs based on two factors:

- balance VMs based on their storage resources (where their VHDs reside) - i.e. after some maintenance 
- balance VMs based on their compute resources (owner node) - i.e. After some over trigger-happy operator creating a bunch of VMs on single node and then cluster feature balancing them.
 
This is a fairly easy task when you know WHAT to move where. But I'm lazy so I want the lazy job made for me.

# PowerShell Rocks!

If I need to align VMs compute to where their storage is (LiveMigrate that is) I use this:

{% gist 65f8af157d6656552af9f3d753d5ebe0 %}
 
And if I need to move storage to where compute is (Storage Migration) I prefer this snippet:

{% gist d7fe2d7b935ec6874639d211305b47aa %}
 
# Stop!

![Stop]({{ site.url }}{{ site.baseurl }}/assets/images/posts/s2d-balance-vms/picture2.jpg)

No more unnecesary IOPS

