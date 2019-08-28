---
title: Hyper-V Cluster - Get CSV Usage
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - S2D
    - CSV
---

# Why

My daily tasks include maintaining a few Hyper-V Clusters (and other Failover Clusters). All of them are using CSV (Cluster Shared Volumes) - whether it's 2012R2 cluster with SAN or 2016 with S2D. 

While in the middle of something (moving VMs, load balancing resources, creating new ones) I need the information of current utilization of my CSVs. This can also be useful when I need to deploy a new VM - query storage with least utilization.

# How

- I can get the information from Failover Cluster Manager:

![FCM]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture1.png)

- I can get it using [Windows Admin Center](https://docs.microsoft.com/en-us/windows-server/manage/windows-admin-center/understand/windows-admin-center)

![WAC]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture2.png)

- or I can get it through PowerShell

# The PowerShell Way

There's a Cmdlet from FailoverClusters module that can provide us with all the information - `Get-ClusterSharedVolume`:


![Get-CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture3.png)

It's rather not very detailed, but Get-Member will reveal what's inside:

![Get-CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture4.png)

`SharedVolumeInfo` Property looks promising:

![Get-CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture5.png)

Partition property is also an object, which holds very valuable information:

![Get-CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture6.png)

Now I have all the information I need.

As I mentioned before - I tend to use alternative credentials to access critical resources. Unfortunately `Get-ClusterSharedVolume` doesn't accept `Credential` parameter. So despite it's possible to query cluster directly, I'd rather use `Invoke-Command` to access cluster information. This way I can connect cross-domain as well. 

# Final 

Let's wrap it up into a function and see how it goes:

{% gist 3b865a34118b2b48b6d3650baacafa12 %}

And the output:

![Output]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture7.png)

This comes quite handy for a quick glance:

![Output]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-csvusage/picture8.png)


