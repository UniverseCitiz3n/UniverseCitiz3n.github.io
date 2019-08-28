---
title: Preferred Owner in Failover Cluster. Part 2
categories:
    - HyperV
tags:
    - Failover Cluster
    - PowerShell
    - Virtual Machine
    - Preferred Owner
excerpt: Configure Preferred Owner through PowerShell
---

# Preffered Owner

- [Part 1](https://www.mczerniawski.pl/hyperv/preferred-owner-possible-owner-antiaffinity/) covers some theory and GUI configuration.
- [Part 2](https://www.mczerniawski.pl/hyperv/preferred-owner-part-2/) will focus on setting Preferred Owners with Powershell.
- [Part 3](https://www.mczerniawski.pl/hyperv/possible-owner-part-3/) will explain logic behind Possible Owners in PowerShell function.
- [Part 4](https://www.mczerniawski.pl/hyperv/anti-affinity-part-4/) will cover the last step - setting anti-affinity groups.
- Part 5 will describe reporting of current configuration in the cluster.

In first part I've covered some basic information about different advanced assignment policies for VM in a Failover cluster. This time I'd like to use some PowerShell to set `'preferred owner'` for my VMs.

# General concept

As stated before - I like my functions to run with alternative Credentials. If Credential parameter is passed, then PSSession will use it. Else, it will use current user context. Thanks to this I can code, run and test using VSCode on my workstation without the need to run with scissors admin rights. This does complicate code a bit, but gives me flexibility. 

I choose to use Invoke-Command, get necessary data and parse/transform/check in my main session. This way I don't need all RSAT cmdlets on my workstation and this code is portable. It should also work from any system (Linux/MacOS/Windows)! 

If it's not possible to create PSSession - no code will do anything so I'll error here:

{% gist b5a7d104b86dadb656fda851c009231a %}

To reset Preferred Owners to defaults (no preferred owner ) I'll need to pass empty string or `$null`.
If `$PreferredOwner` is provided, I need to be able to verify if provided  Nodes are correct - if `$Cluster` does have members with those names.  To do this I'll use `Compare-Object` with `-IncludeEqual`. It will compare each node (`$preferredOwner`) with all cluster members (`$nodesInCluster`) and give proper verbose information:

{% gist 5abf570b5b14f2f89124b7f1d52dc38d %}

When this is done I can loop through `$VMName`, read current status, set proper owners and read new status again. If `-Verbose` is set I will see what has changed from state A to state B.

{% gist c8f04fb86e8fd49ddd59b7554bf5deb6 %}

# Full Script

This is the full script

{% gist ed38fbe881574fecb3c9702136a2b12a %}

And this is an example output:
- setting preferred owner

![Set]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-2/picture1.png) 

- Clearing to defaults

![Clear]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-2/picture2.png) 

- Same from PowerShell Core 6.1

![PSCore]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-2/picture3.png) 

# Summary

This one is pretty simple. 
- Create connection properties based on Credential parameter
- Validate provided nodes against cluster
- Set proper value if no $PreferredOwner is provided
- Verify if given VM exists and if so - Set Preferred Owner


![Donald]({{ site.url }}{{ site.baseurl }}/assets/images/posts/preferred-owner-part-2/picture4.jpg) 

