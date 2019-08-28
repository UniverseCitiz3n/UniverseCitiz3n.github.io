---
title: Simple VM Inventory
categories:
    - HyperV
tags:
    - HyperV
    - PowerShell
    - Virtual Machine
excerpt: Get quick insight into your VM assets
---

# Quicky

Another quicky to get all VMs from your hosts/cluster and display some basic information about them like CPU, Memory, Disk count and size.
- I can get it using [Windows Admin Center](https://docs.microsoft.com/en-us/windows-server/manage/windows-admin-center/understand/windows-admin-center)

![Simple1]({{ site.url }}{{ site.baseurl }}/assets/images/posts/simple-vm-inventory/picture1.png) 

- or PowerShell

{% gist 0d5f252eacbb411bedc09e0a647e46d7 %}

The output looks like this:

![Simple2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/simple-vm-inventory/picture2.png) 

