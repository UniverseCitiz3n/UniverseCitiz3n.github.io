---
title: Microsoft Monitoring Agent - Clear Cache
categories:
    - Azure
tags:
    - Azure
    - Log Analytics
    - Microsoft Monitoring Agent
    - Powershell
excerpt: When troubleshooting MMA sometimes clearing cache is necessary. This is a simple how to.
---

# When things go bad

There are situations where clearing the cache helps. Be it DNS cache, memory cache or, like in this example, Microsoft Monitoring Agent cache. This did bite me a bit lately. 

I was testing Update Management as part of [Azure Automation](https://docs.microsoft.com/en-us/azure/automation/automation-tutorial-update-management) to manage patch management for on-premises Hyper-V VMs and standalone servers.  
Everything went smooth and I decided to move VMs between Azure Log Analytics workspaces - from test to production. And here where things went sideways.

All VMs were visible under both `Automation Accounts` but only one could manage the update process - the `test` one:

![Troubleshoot]({{ site.url }}{{ site.baseurl }}/assets/images/posts/microsoft-monitoring-agent-clear/picture1.png)

So let's get into some troublshooting!

## Wait a minute

But hey, wait a minute. What's great about this solution? It's free! As literaly free. All it requires is:

- free Azure subscription
- installation of free Agent
- configuration of free Azure Automation account
- and willingness to share some telemetry with Microsoft

Well, nothing comes for free in the end.  
But time this saves me across my realms to provide patching is worth it. Whether we're talking about corporate resources (like hundreds of VMs previously managed by WSUS) or small customers (2-3-10 OS instances per client).  
The latter are just bound to one aggregated subscription.

What you get in return is:

- ease of scheduling patch process for both Windows and Linux worlds
- `at a glance` view for compliance (missing critical, security or other updates)
- past time of maintenance window - to better tailor future time schedules
- Azure Log for advanced queries with 5GB of logs for free each month

I'm using this for a few months now and I'm really impressed by the ease of use.

Now, let's get back to troubleshooting.

## Let's shoot

Ok, so all [official docs](https://docs.microsoft.com/en-gb/azure/automation/troubleshoot/update-agent-issues) didn't mention my case at that time. The troubleshooter guide is only for Azure VMs and the offline script [Troubleshoot-WindowsUpdateAgentRegistration](https://www.powershellgallery.com/packages/Troubleshoot-WindowsUpdateAgentRegistration) returned with all `Passed` CheckResults.  
It would be too easy otherwise!  

As those VMs were reporting to both workspaces my first call was to delete the old one. As you may have guessed - didn't work.  
Neither removing both.  
Nor reinstalling the agent!

My search-fu was failing. All `microsoft monitoring agent update management troubleshoot` query variations returned the above Microsoft Docs link or were pointing me to `clear SCOM agent cache`. Well, MMA is a next gen SCOM agent so it's worth the shot.

## The Fix

Now, to properly clear the cache for MMA I had to do following:

1. Remove Workspace from configuration
2. Stop MMA service
3. Flush this directory `C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State`
4. Remove this registry entry `HKLM:\software\microsoft\hybridrunbookworker`
5. Start MMA service
6. Add workspace
7. Reload configuration

> Thing to remember  
> - If VM is renamed - this will help TOO!

## The Solution

As there were a few of those VMs and I knew it will come in handy in time here's some `PowerShell` :grin:

```powershell
$Computers = Get-ADComputer -filter "Name -like 'YourVM*'" | Select-Object -ExpandProperty Name
$Creds = Get-Credential
$WorkspaceID = 'YourWorkspaceID'
$WorkspaceKey = 'SuperSecretPrimaryKeyForWorkspace'

Invoke-Command -ComputerName $Computers -Credential $creds -ScriptBlock {
    $WorkspaceID = $USING:WorkspaceID
    $WorkspaceKey = $USING:WorkspaceKey

    #Create COM Object to manipulate MMA configuration
    $AgentCfg = New-Object -ComObject AgentConfigManager.MgmtSvcCfg
    # Remove desired OMS Workspace
    if($AgentCfg.GetCloudWorkspace($WorkspaceID)) {
        $AgentCfg.RemoveCloudWorkspace($WorkspaceID)
    }

    Stop-Service -ServiceName 'HealthService'
    #Remove files
    Remove-item -path 'C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State'
    #Remove registry
    Get-ChildItem 'HKLM:\software\microsoft\hybridrunbookworker' | Remove-Item
    #let it rest a while. It was a hard task! :)
    Start-sleep -Seconds 10

    Start-Service -ServiceName 'HealthService'

    # Add OMS Workspace
    $AgentCfg.AddCloudWorkspace($WorkspaceID,$WorkspaceKey)
    $AgentCfg.ReloadConfiguration()
    Start-Sleep -seconds 5
    $AgentCfg.GetCloudWorkspaces()
    #endregion
}
```

Well, that is it. 

> Another thing to remember:  
> - Azure Log and its solutions isn't **REAL TIME** processing. Give it a moment!

So don't panic if it won't help the moment you flush your VM!

Now If I would like to verify on-premises configuration for selected VMs in the future, this will work:

```powershell
$Computers = Get-ADComputer -filter "Name -like 'YourVM*'" | Select-Object -ExpandProperty Name
$Creds = Get-Credential

#region Verify current Status
$ServiceStatus = Invoke-Command -ComputerName $Computers -Credential $creds -ScriptBlock {

    $AgentCfg = New-Object -ComObject AgentConfigManager.MgmtSvcCfg
    $AgentStatus = $AgentCfg.GetCloudWorkspaces() | select-object WorkspaceID,ConnectionStatus,ConnectionStatusText
    $ServiceStatus = Get-Service 'HealthService' | select-object Status,Name
    [pscustomobject]@{
        ComputerName = $env:ComputerName
        AgentWorkspaceID = $AgentStatus.WorkspaceID
        AgentConnectionStatus = $AgentStatus.ConnectionStatus
        AgentConnectionStatusText = $AgentStatus.ConnectionStatusText
        ServiceName = $ServiceStatus.Name
        ServiceStatus = $ServiceStatus.Status
    }
}

$ServiceStatus | Format-Table
```

![Status]({{ site.url }}{{ site.baseurl }}/assets/images/posts/microsoft-monitoring-agent-clear/picture2.png)

Issues with VMs are sometimes trivial.

> Maybe the service isn't working,  
  > or it's reporting to WRONG Workspace

:grin: