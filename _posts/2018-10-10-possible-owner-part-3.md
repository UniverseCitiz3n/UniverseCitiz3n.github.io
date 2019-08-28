---
title: Possible Owner in Failover Cluster. Part 3
categories:
    - HyperV
tags:
    - Failover Cluster
    - PowerShell
    - Virtual Machine
    - Possible Owner
excerpt: Configure Possible Owner through PowerShell
---

# Possible Owner 

- [Part 1](https://www.mczerniawski.pl/hyperv/preferred-owner-possible-owner-antiaffinity/) covers some theory and GUI configuration.
- [Part 2](https://www.mczerniawski.pl/hyperv/preferred-owner-part-2/) will focus on setting Preferred Owners with Powershell.
- [Part 3](https://www.mczerniawski.pl/hyperv/possible-owner-part-3/) will explain logic behind Possible Owners in PowerShell function.
- [Part 4](https://www.mczerniawski.pl/hyperv/anti-affinity-part-4/) will cover the last step - setting anti-affinity groups.
- Part 5 will describe reporting of current configuration in the cluster.

Today let's focus on logic behind Possible Owners feature in Failover clustering.

# General concept

This is a little trickier. Before a VM can have its `'Possible Owner'` property set, it must be on one of the Hyper-V nodes first. There can be a few scenarios - VM1 and 4 Hyper-V Nodes: Node1-4.
- I want to reset configuration to defaults - in other words set it to Node1-4
- I want to set configuration to Node2 and VM is on Node2
- I want to set configuration to Node1-2 and VM is on Node2
- I want to set configuration to Node1-2 and VM is on Node3 or Node4
 
First, in the `begin{}` block I will:
- create PSSesion to the Cluster
- if `$PossibleOwner` not set, I'll assign all current cluster nodes to it
- If `$PossibleOwner` is set I will validate whether provided nodes exists 
 
Then I'll loop through each VM. If it's found then:
- I'll get it's current configuration
- Compare to expected and if there's a mismatch I'll proceed

    1. Scenario 1 is the simplest - I'll just set PossibleOwner to all nodes. 
    2. Scenario 2 and 3 are similar, but provided parameter $PossibleOwner will be used
    3. Scenario 4 requires some additional work:
        - First, I need to reset PossibleOwner to default to allow migration
            - If the VM is turned on - I'll use Live Migration
            - If the VM is turned off - I'll use Quick Migration
        - After migration was successful I can finally set PossibleOwner to desired state
- In the end I'll return a custom object for each processed VM with 4 parameters: 
    - Cluster
    - VMName
    - CurrentNode VM is 
    - OwnerNode value which is the PossibleOwner we wanted to achieve
- And finally will remove PSSession

# Full Script

Here's the full script:
{% gist 1b28453cf890a3b0578bb7b9e38f0083 %}

And here's the output from PowerShell Core:
- Reset to defaults

![Reset]({{ site.url }}{{ site.baseurl }}/assets/images/posts/possible-owner-part-3/picture1.png) 

- Set to two nodes. VMs are on one of the nodes

![Set]({{ site.url }}{{ site.baseurl }}/assets/images/posts/possible-owner-part-3/picture2.png) 

- Set to two different nodes than VMs are on


![Set2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/possible-owner-part-3/picture3.png) 

# Summary

This one requires a little bit of more work than before. Mainly because involves moving VMs between nodes.  One last to go and we'll get into reporting :)

![Smile]({{ site.url }}{{ site.baseurl }}/assets/images/posts/possible-owner-part-3/picture4.jpg) 

