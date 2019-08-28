---
title: AntiAffinity Groups in Failover Cluster. Part 4
categories:
    - HyperV
tags:
    - Failover Cluster
    - PowerShell
    - Virtual Machine
    - Anti-Affinity Groups
excerpt: Configure Anti-Affinity Groups through PowerShell
---

# AntiAffinity

- [Part 1](https://www.mczerniawski.pl/hyperv/preferred-owner-possible-owner-antiaffinity/) covers some theory and GUI configuration.
- [Part 2](https://www.mczerniawski.pl/hyperv/preferred-owner-part-2/) will focus on setting Preferred Owners with Powershell.
- [Part 3](https://www.mczerniawski.pl/hyperv/possible-owner-part-3/) will explain logic behind Possible Owners in PowerShell function.
- [Part 4](https://www.mczerniawski.pl/hyperv/anti-affinity-part-4/) will cover the last step - setting anti-affinity groups.
- Part 5 will describe reporting of current configuration in the cluster.

Today is a quick one - `AntiAffinity groups`.

# General concept

There is no PowerShell cmdlet to set up Affinity Groups - like `Set-ClusterOwnerNode`. To achieve this I must alter a class property `AntiAffinityClassNames` with an array of strings. Each object represents an affinity group a VM belongs to. If two VMs share the same group - cluster service will try to keep them on separate nodes.

In short, this is all we need to check:

```powershell
$VMName = 'Windows2016'
(Get-ClusterGroup -Name $VMName).AntiAffinityClassNames 
```

And to set a simple assignment:

```powershell
(Get-ClusterGroup -Name $VMName).AntiAffinityClassNames = 'Template'
```

I'd like to be able to append new Groups if needed. 

# Full Script
Full script looks like this:

{% gist 66f8f6d9cc38ed5d5ab2a7561cda8704 %}

# Sample output
Running PSCore 6.1 and targeting one vm on a cluster:

![Set]({{ site.url }}{{ site.baseurl }}/assets/images/posts/antiaffinity-part-4/picture1.png) 

Adding new AntiAffinityGroup to the same VM:

![Add]({{ site.url }}{{ site.baseurl }}/assets/images/posts/antiaffinity-part-4/picture2.png) 

Clearing all on `'windows2016'`:

![Clear]({{ site.url }}{{ site.baseurl }}/assets/images/posts/antiaffinity-part-4/picture3.png) 

Setting two VMs into same AntiAffinity Group:

![Set2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/antiaffinity-part-4/picture4.png) 

# Summary

This one can help in keeping certain VMs on separate nodes (Domain Controllers, VM Guest cluster nodes, etc.)
Next we're going to get some reporting for every setting we've configured so far!


![Lego]({{ site.url }}{{ site.baseurl }}/assets/images/posts/antiaffinity-part-4/picture5.jpg) 


