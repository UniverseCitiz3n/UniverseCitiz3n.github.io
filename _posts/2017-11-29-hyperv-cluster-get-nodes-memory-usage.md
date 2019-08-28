---
title: Hyper-V Cluster - Get Nodes Memory Usage
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - S2D
    - Memory
---

# Why

Similar as before ([here](https://www.mczerniawski.pl/hyperv/hyperv-cluster-get-csv-usage/)) having information about your cluster nodes memory usage can be helpful. Especially when creating a bunch of new VMs.

# How

- I can get the information from Failover Cluster Manager (one node at a time):

![FCM]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-nodes-memory/picture1.png)

- I can get it using Windows Admin Center

![WAC]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-nodes-memory/picture2.png)

- or I can get it through PowerShell

# The PowerShell way

Because both solutions (Failover Cluster Manager and WAC) lack the flexibility (node by node, or no accurate number) i prefer PowerShell.

As I mentioned before - I tend to use alternative credentials to access critical resources. Unfortunately `Get-ClusterNode` doesn't accept Credential parameter. So, despite it's possible to query nodes directly, I'd rather use Invoke-Command to access cluster information. This way I can connect cross-domain as well. Then, the information I need can be easily retrieved using WMI:

```powershell
Get-WmiObject -Class win32_operatingsystem -ComputerName $ClusterNode
```

It's good to have all active nodes in a cluster queried with one sweep.  I'll be using Select-Object to filter the output. It's easier to read the code that way ([link](https://www.mczerniawski.pl/powershell/select-object/select-object-filtering/)).

# Let's wrap it into a function:

{% gist 4b1cc1319d9a38eae3c352c8536f78a6 %}
The output will be like this:

![Output]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-nodes-memory/picture3.png)

This comes quite handy for a quick glance:

![Output]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-nodes-memory/picture4.png)



