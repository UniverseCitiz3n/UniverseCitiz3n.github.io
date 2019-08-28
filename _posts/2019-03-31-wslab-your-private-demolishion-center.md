---
title: WSLab - your private demolishion center
categories:
    - HyperV
tags:
    - HyperV
    - PowerShell
excerpt: An Ultimate test-environment workbench
---

# What is WSLab

Some long time ago while searching for issues with S2D I came across a tool called ws2016lab written by [Jaromir Kaspar](https://twitter.com/jaromirkaspar).

Back then (over 2 year ago (woah, it's been over 3 since it came out - [Building out labs](https://blogs.technet.microsoft.com/askpfeplat/2016/03/21/building-out-labs/)) I needed a fast way to spin up S2D labs and break them. As it was growing and inluded Windows 2019 and Windows 10 as well, Jaromir decided to rebrand it to WSLab.

What is [WSLab](https://github.com/Microsoft/WSLab)? It is a library of sample scripts to deploy an environment where you can just KKND (Anyone remembers [Krush Kill 'N Destroy](https://www.gog.com/game/krush_kill_n_destroy_2_krossfire) - then take look :smile: ).

## Ultimate weapon of destruction

I know there are other frameworks that allow for spinning up lab scenarios - like:

- [AutomatedLab](https://github.com/AutomatedLab/AutomatedLab)
- [LabBuilder](https://github.com/PlagueHO/LabBuilder)
- [My Own Lab](https://www.mczerniawski.pl/pposh/pposh-meetup-1/) :smile:

But in my opinion WSLab has a great advantage - simplicity. In the end it's just a few PowerShell lines to spin it up or destroy. 

Code you can copy and use in your current provisioning set up. And you don't have to figure it all out - just read the readme :) Jaromir does an awesome job with that too! 

## Still hesitating?

If you're still not quite sure, just take a look at the list of current scenarios:

```
├───AdmPwd.E
├───BitLocker on S2D cluster
├───BitLocker with JEA
├───Certification Authority
├───DeviceGuard
│   ├───SmartLocker
│   │   ├───DefaultPolicies
│   └───VBS
├───Exploring Server 2019
├───Host Guardian Service
├───Hyper-V with Shared Storage
├───LAPS
├───LAPS on Nano
├───Rolling Cluster Upgrade
│   └───RCU and Hyper-V Replica
├───Running WSLab in Azure
├───S2D and Bare Metal with SCVMM
├───S2D and Bulk VM creation
├───S2D and Cluster Sets
├───S2D and Disaster recovery
├───S2D and Diskspd
├───S2D and Emergency Patching
├───S2D and Failures simulation
├───S2D and Fault Domains
├───S2D and Grafana
├───S2D and Metadata deep dive
├───S2D and Networks deep dive
├───S2D and Pester
├───S2D and Scoped Volumes
├───S2D and SCVMM 2019
├───S2D and SCVMM in large Datacenters
├───S2D and SDN
├───S2D and Validate-DCB
├───S2D and Volumes deep dive
├───S2D and Windows Admin Center
├───S2D Converged
├───S2D Hyperconverged
├───S2D on AWS and VMware
├───SDNExpress with SCVMM
├───SDNExpress with Windows Admin Center
├───SecGuide GPOs
├───StorageMigrationService
├───StorageReplica
│   ├───Cluster_to_Cluster
│   ├───S2D_to_S2D
│   ├───S2D_to_S2D_Complex
│   ├───Server_to_server
│   └───Stretch_Cluster
├───Testing Nano performance
├───TestingCSVRedirection
├───VMFleet
├───Windows Admin Center and Enterprise CA
├───Windows Admin Center Deployments
├───Windows Event Forwarding
│   ├───NSA Event Forwarding Guidance
│   ├───Palantir Event Forwarding Guidance
│   └───Sysmon
└───Windows Update
```

## Aaaaand ...

Let me just quote Jaromir:

> So what is it good for?
> Simulations such as
> - how to script against servers
> - how to automate configuration
> - **what will happen when I run this and that command**
> - how change drive in S2D cluster
> - what will happen when one node goes down
> - **testing new features before pushing to production**

## ... last thing

There are now two scenarios I took part in.
- [S2D and Pester](https://github.com/Microsoft/WSLab/tree/master/Scenarios/S2D%20and%20Pester) which uses my pester module to test S2D operational and configuration status
- [Windows Event Forwading](https://github.com/Microsoft/WSLab/tree/dev/Scenarios/Windows%20Event%20Forwarding/Creating%20Custom%20WEF%20logs) - still in dev branch, where I helped a bit with generating xml. Glad I could be of use :smile:

## Don't wait!

Wait no longer, just grab the module and start playing around!

> - Lab can run LAB on Windows 10, Windows Server 2016 (both Core and GUI) or even in Azure VM
> - Major differentiator is that once hydrated (first 2 scripts), deploy takes ~5 minutes. Cleanup is ~10s.
> - Options for setting up a Windows Server 2016-based lab are simpler than other available lab automation systems as the project is based on Powershell scripts rather than XML or DSC configuration files.
