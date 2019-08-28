---
title: Preferred Owner, Possible Owner and Anti-Affinity Groups in Failover Cluster. Part 1
categories:
    - HyperV
tags:
    - Failover Cluster
    - PowerShell
    - Virtual Machine
    - Preferred Owner
    - Possible Owner
    - Anti-Affinity Groups
excerpt: Some insight and code for configuring preferred, possible owners and anti-affinity groups
---

# Oh my!

![Bum]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-1/picture1.jpg)

This is going to be a 5 part blog series.
- [Part 1](https://www.mczerniawski.pl/hyperv/preferred-owner-possible-owner-antiaffinity/) (this part) covers some theory and GUI configuration.
- [Part 2](https://www.mczerniawski.pl/hyperv/preferred-owner-part-2/) will focus on setting Preferred Owners with Powershell.
- [Part 3](https://www.mczerniawski.pl/hyperv/possible-owner-part-3/) will explain logic behind Possible Owners in PowerShell function.
- [Part 4](https://www.mczerniawski.pl/hyperv/anti-affinity-part-4/) will cover the last step - setting anti-affinity groups.
- Part 5 will describe reporting of current configuration in the cluster.

# Intro

What are these, why may I need it and how to configure it - in the context of Virtual Machine resources?

By default settings for all high available Hyper-V VMs are:
- run on any available node in the cluster (possible owners)
- VM likes all nodes the same (no preferred owner).
- VM likes all other VMs the same (not a member of any anti-affinity group).

There are three advanced failover policies I can set up for my VMs. Let's assume I have 4 nodes (Node1-4):

- **Preferred Owners** -  this is the preference of first node to run on - describes which node is the BEST for this particular VM.  If I configure Node3-4 for my VM as preferred owner, any time the VM is on another node it will migrate back to Node 3 or Node 4. Fallback option configures if and when to fallback (see pics below).

- **Possible owners** - this sets to which nodes a VM can failover. If I configure my VM with Node2-4 it won't be able to migrate to Node1. 

- **Anti-Affinity** - this is the preference to keep similar VMs apart from each other. If I have my VM1 and VM2 hosting same role (think DC, or SQL cluster) I want to keep them off the same nodes. With this settings cluster will try to keep it that way. If VM1 is on Node1 and VM2 is Node3 and I will try to migrate VM1 to Best Possible Node, cluster service will try to migrate it first to Node2 or Node4 if possible. If not (i.e. lack of resources) it will be put on Node3

Possible owners is the `'hard set'`. It will restrain VM from running on any other node. To configure this, VM has to be on one of `'possible owner'` list first. I cannot set this to Node3 and Node4 if VM is on Node1 or Node2.

Let's try to configure these options with GUI first.

# The GUI

1. Preferred Owners 
	- Right clik on any VM and select Properties then I can check which nodes are considered 'Preferred' ![GUI1]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-1/picture2.png)

	- On the Failover tab I can set fallback policies ![GUI2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-1/picture3.png)
			
2. Possible owners 

    - Select VM, on the Resources tab on the bottom right click on the Virtual Machine Name, select Properties: ![GUI3]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-1/picture4.png)
			
    - On the Advanced Policies tab select which nodes are Possible. By default all are selected: ![GUI4]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-1/picture5.png)
			
3. Anti-Affinity Groups 
    - There's no way to set it up through GUI! :D

# Summary

Let me give a few examples in which scenarios this can be usefull:
- If some VMs share common data we can set them to similar nodes to lower network traffic (preferred owner).
- If some VMs must be on specific nodes - i.e. External Connector licensing or SQL by CPU core (possible owner).
- If some VMs shouldn't be on the same nodes - guest clustering, Domain Controllers, DFSR partners.

Stay tuned for next parts coming soon:
- [Part 1](https://www.mczerniawski.pl/hyperv/preferred-owner-possible-owner-antiaffinity/) (this part) was a bit of theory and GUI way.
- [Part 2](https://www.mczerniawski.pl/hyperv/preferred-owner-part-2/) will focus on setting Preferred Owners with Powershell.
- [Part 3](https://www.mczerniawski.pl/hyperv/possible-owner-part-3/) will explain logic behind Possible Owners in PowerShell function.
- [Part 4](https://www.mczerniawski.pl/hyperv/anti-affinity-part-4/) will cover the last step - setting anti-affinity groups.
- Part 5 will describe reporting of current configuration in the cluster.

		
