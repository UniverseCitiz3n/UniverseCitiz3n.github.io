---
title: VMs from Cluster with given IP
categories:
    - HyperV
tags:
    - HyperV
    - PowerShell
    - Virtual Machine
excerpt: Qick search for all VMs with given IP
---

# Quicky

I had to find all how much memory consumed certain VMs from my clusters and Hyper-V hosts with specific IP address range. 

It's rather simple task:

- Step 1 - Get all VMs from all Hyper-V hosts
- Step 2 - Query VMNetworkAdapter for specific IP address
- Step 3 - Select interesting properties

{% gist 7b8e35fd954cc1302b5489845b9cc1d0 %}
