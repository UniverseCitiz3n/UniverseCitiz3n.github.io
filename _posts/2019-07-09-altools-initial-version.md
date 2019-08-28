---
title: ALTools initial version
categories:
    - PowerShell
tags:
    - PowerShell
    - Azure Logs
    - ALTools
excerpt: How to send custom object to Azure Logs
---

# Intro

My recent projects are build around using [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/get-started-portal) for storing operational or final results.  
This includes [WEFTools](https://github.com/mczerniawski/WEFTools) or [pChecksAD](https://github.com/mczerniawski/pChecksAD) as well as some internal projects.

If you haven't tried storing logs in `always-on, always available, very affordable` Azure Logs solution - I highly recommend you try it!

Because of this I decided to put [Microsoft examples](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api) into a usable micro-module.

As it is available on [GitHub](https://github.com/mczerniawski/ALTools) and [PowerShell Gallery](https://www.powershellgallery.com/packages/ALTools/) you can also use it.

## Examples

What are some usage examples? Currently we're using Azure Log to:

- store relevant Event Logs and then consume with PowerBI - more information and examples in [WEFTools](https://github.com/mczerniawski/WEFTools) repository
- store results of maintenance checks for infrastructure (Hyper-V, S2D, internal services, AD ([pChecksAD](https://github.com/mczerniawski/pChecksAD)))
- store software inventory of `not-always-connected-devices-to-on-premises` into a common database
- store logs of actions performed by custom PowerShell scripts run from AzureAutomation or Intune
- store results of internal processes without dependancy on any database
- visualize data with PowerBI reporting

If you'd like to see some PowerShell usage example - [here's the link](https://github.com/mczerniawski/ALTools/blob/master/README.md) of two mentioned repos:

- [WEFTools](https://github.com/mczerniawski/WEFTools/blob/master/docs/Run.md)
- [pChecksAD](https://github.com/mczerniawski/pChecksAD/blob/master/docs/Run-Checks.md)

## Outro

Why wrapping those three functions into a micromodule? This way I don't have to copy-paste the same three functions into each module or computer that needs to use this. Also I'm have CI/CD set up so I'm more confident in building this that manual copy paste. Kevin Marquette has a great explanation of [What is a micro module](https://powershellexplained.com/2019-04-11-Powershell-Building-Micro-Modules/#what-is-a-micro-module).
