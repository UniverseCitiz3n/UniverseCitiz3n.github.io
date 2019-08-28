---
title: Active Directory Health Checklist
categories:
    - ActiveDirectory
tags:
    - ActiveDirectory
    - Checklist
excerpt: List with some health checks for Active Directory
---

# Intro

During latest [PSConfEU](https://www.psconf.eu/) I've had an awesome [experience](https://www.mczerniawski.pl/random/psconfeu-2019/).

Amongst other things I talked with [Friedrich Weinmann](https://twitter.com/fredweinmann) and [Przemyslaw Klys](https://twitter.com/PrzemyslawKlys) about checks. Active Directory checks specificaly.

Each of us is working on a different approach to `check` Active Directory.  
There are also other solutios out there that `check and monitor` Active Directory for a `green` state. Those are either blackbox solutions (like purchased software - think SCOM) or self-crafted (like nagios/zabbix monitoring and Grafana dashboards).

This also includes PowerShell modules (like mine [pChecksAD](https://github.com/mczerniawski/pChecksAD)) that do the same. Each in a different way. The problem we saw is that each environment is different and each of those solution monitor a set of features. If I see a great `check` in someones solution - I want to add it to my module as well :smile:
There are also [Microsoft Docs](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-domain-services) with very detailed description of all services and dependancies for AD and DCs as well.

# A Check List

And so I've decided to create [a repository](https://github.com/mczerniawski/Active-Directory-CheckList) with simple lists in different topics with `RAW` checks - independent of final solution one could use.

Currently there are 3 areas - Configuration, Operational and Security with checks split into General (overall service) and per Node (per Domain Controller) checks.

Take a look and let me know what else should I add - or better - create a Pull Request with necessary information!
