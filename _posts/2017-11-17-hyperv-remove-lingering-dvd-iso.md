---
title: Hyper-V Remove Lingering DVD iso
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - ISO
---

# Mass Dismount

Another day - another dirty - quicky.

So you've got a bunch of hosts and some VMs there. Some of those have iso files attached. Some of them shouldn't. Especially if that ISO is not accessible for all nodes in the cluster. 

![DVD]({{ site.url }}{{ site.baseurl }}/assets/images/posts/remove-lingering/picture1.jpg)

You can get an error like this:

![Error1]({{ site.url }}{{ site.baseurl }}/assets/images/posts/remove-lingering/picture2.png)

Now, getting vm after vm can be a little overwhelming, right?

![VMs]({{ site.url }}{{ site.baseurl }}/assets/images/posts/remove-lingering/picture3.png)

We could do a clean sweep and remove all DVDs from ALL Vms, but that's a little to... Trigger happy.

# PowerShell Rocks!

So here's a oneliner that will query your ClusterNodes and display necessary information in Out-GridView.

This will allow us to select only specific VMs and click OK to dismount ISO from their DVD drive. 

Because `Set-VMDvDDrive` does not accept pipeline input, we're doing a foreach-object loop. If you select Cancel - it won't dismount a thing:

{% gist c5d4f5a2df663f9c1f97599d9325d9e1 %}

# Job Done!