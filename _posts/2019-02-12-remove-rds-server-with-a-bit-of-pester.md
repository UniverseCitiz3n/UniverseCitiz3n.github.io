---
title: Remove RDS Server with a bit of Pester
categories:
    - PowerShell
tags:
    - PowerShell
    - Remote Desktop Services
    - Pester
---

# Remove RDS server

Simple task, simple solution. One of our Remote Desktop Services Hosts was no longer needed. It was running `Windows 2012R2` and the team finally decided to move to 2016. Anyway - the time for decomission has come.

I've decided to use this as an introduction lesson to [Pester](https://github.com/pester/Pester) for our junior admin. I just :heart: using Pester in [infra checks](https://arconnetblog.wordpress.com/2017/07/05/pposh-2nd-meetup-pester/)   This is an overkill for such a simple task, but remember - intro lesson.

## Checklist 
Let's create a simple checklist for tasks to be done:
- remove collection from `Connection Broker`
- remove server from `RDS Deployment`
- remove RDS role from `Server`
- proceed with decomissioning server from domain (not current task)

Now let's prepare a simple Pester checklist *`BEFORE`* we do anything (in pseudo-code)
```powershell
Describe "Verify current state of RDS server" {
    IT "Collection name {$RDSCollectionName} on connectionBroker {$RDSConnectionBroker} exists" {
         Get-Current-State-of-Collection | 
            Should -BeTrue -Because "We need to make sure collection exists"
    }
    IT "Server {$RDSServer} in connectionBroker {$RDSConnectionBroker} has RDS Role" {
        Get-Current-State-of-RDS-Server |
            Should -BeTrue -Because "Server should be in RDS Deployment"
    }
    IT "Server {$RDSServer} should have RDS roles installed" {
        Get-Current-State-of-RDS-Server-Role | 
            Should -BeTrue -Because "Server should have all roles installed"
    }
}
```

I didn't use `Context` block by purpose here not to overcomplicate it. As you can see there is no 'actual' code in here - just knowledge WHAT is needed. Now, let's go on a hunt HOW to `Get-Current-State-of...`

# Discovery

This won't be hard as RDS module have all necessary cmdlets. How do I know it? by running `Get-Command -Module RemoteDesktop`. There are 79 total cmdlets. Because I need to `Get-` some information, let's narrow it down:

```powershell
PS C:\AdminTools> Get-Command -Module RemoteDesktop -Name Get-*

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-RDAvailableApp                                 2.0.0.0    RemoteDesktop
Function        Get-RDCertificate                                  2.0.0.0    RemoteDesktop
Function        Get-RDConnectionBrokerHighAvailability             2.0.0.0    RemoteDesktop
Function        Get-RDDeploymentGatewayConfiguration               2.0.0.0    RemoteDesktop
Function        Get-RDFileTypeAssociation                          2.0.0.0    RemoteDesktop
Function        Get-RDLicenseConfiguration                         2.0.0.0    RemoteDesktop
Function        Get-RDPersonalSessionDesktopAssignment             2.0.0.0    RemoteDesktop
Function        Get-RDPersonalVirtualDesktopAssignment             2.0.0.0    RemoteDesktop
Function        Get-RDPersonalVirtualDesktopPatchSchedule          2.0.0.0    RemoteDesktop
Function        Get-RDRemoteApp                                    2.0.0.0    RemoteDesktop
Function        Get-RDRemoteDesktop                                2.0.0.0    RemoteDesktop
Function        Get-RDServer                                       2.0.0.0    RemoteDesktop
Function        Get-RDSessionCollection                            2.0.0.0    RemoteDesktop
Function        Get-RDSessionCollectionConfiguration               2.0.0.0    RemoteDesktop
Function        Get-RDSessionHost                                  2.0.0.0    RemoteDesktop
Function        Get-RDUserSession                                  2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktop                               2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktopCollection                     2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktopCollectionConfiguration        2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktopCollectionJobStatus            2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktopConcurrency                    2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktopIdleCount                      2.0.0.0    RemoteDesktop
Function        Get-RDVirtualDesktopTemplateExportPath             2.0.0.0    RemoteDesktop
Function        Get-RDWorkspace                                    2.0.0.0    RemoteDesktop
```

Ok, Seems I will need:
- `Get-RDSessionCollection`
- `Get-RDServer`
- and to get Windows Features - `Get-WindowsFeature`

Let's code a bit:

```powershell
$RDSCollectionName = 'CollectionName'
$RDSConnectionBroker = 'ConnectionBroker.contoso.com'
$RDSServer = 'RDSServer'
$RDServerRole = 'RDS-RD-SERVER'

Describe "Verify current state of RDS server" {
    IT "Collection name {$RDSCollectionName} on connectionBroker {$RDSConnectionBroker} exists" {
        Get-RDSessionCollection -ConnectionBroker $RDSConnectionBroker | Where-Object {$PSItem.CollectionName -eq $RDSCollectionName} | 
            Should -BeTrue -Because "We need to make sure collection exists"
    }
    IT "Server {$RDSServer} in connectionBroker {$RDSConnectionBroker} has RDS Role" {
        Get-RDServer -ConnectionBroker $RDSConnectionBroker -Role $RDServerRole |
           Should -BeTrue -Because "Server should be in RDS Deployment"
    }
    IT "Server {$RDSServer} should have RDS roles installed" {
        Get-WindowsFeature -ComputerName $RDSServer | Where-Object {$PSItem.Name -eq $RDServerRole} | Where-Object {$PSItem.Installed -eq $True} | 
            Should -BeTrue -Because "Server should have all roles installed"
    }
}
```

Which will generate following output:

```
Describing Verify current state of RDS server
  [+] Collection name {CollectionName} on connectionBroker {ConnectionBroker.contoso.com} exists 5.8s
  [+] Server {RDSServer} in connectionBroker {ConnectionBroker.contoso.com} has RDS Role 3.96s
  [+] Server {RDSServer} should have RDS roles installed 936ms
```

Hey, this can be my checklist IF server is properly configured, right? :smile:

Ok, let's get back to our task - removing server:

```powershell
Remove-RDSessionCollection -CollectionName $RDSCollectionName -ConnectionBroker $RDSConnectionBroker
Remove-RDServer -ConnectionBroker $RDSConnectionBroker -Server $RDSServer -Role $RDServerRole
$status = Invoke-Command -ComputerName $RDSServer -ScriptBlock {
    $status = Get-WindowsFeature -ComputerName $RDSServer | Where-Object {$PSItem.Name -eq $USING:RDServerRole} 
    if ($status.Installed) {
        $status | Remove-WindowsFeature    
    }
    Get-WindowsFeature | Where-Object {$PSItem.Name -eq $USING:RDServerRole} 
}
if($status.ExitCode -eq 'SuccessRestartRequired') {
    Restart-Computer -ComputerName $RDSServer -Protocol WSMan -Wait -Force 
}
```

This will perform all three steps we require.

Let's ~~assume~~ test if everything is ok now, that we have pester base:
```powershell
Describe "Verify current state of RDS server" {
    IT "Collection name {$RDSCollectionName} on connectionBroker {$RDSConnectionBroker} is removed" {
        Get-RDSessionCollection -ConnectionBroker $RDSConnectionBroker | Where-Object {$PSItem.CollectionName -eq $RDSCollectionName} | 
            Should -BeNullOrEmpty -Because "Collection should be removed before removing server role"
    }
    IT "Server {$RDSServer} removed from connectionBroker {$RDSConnectionBroker}" {
        Get-RDServer -ConnectionBroker $RDSConnectionBroker -Role $RDServerRole | Where-Object {$PSitem.Server -eq $RDSServer} |
            Should -BeNullOrEmpty -Because "Server should be removed from connection broker"
    }
    IT "Server {$RDSServer} should have RDS roles uninstalled" {
        Get-WindowsFeature -ComputerName $RDSServer | Where-Object {$PSItem.Name -eq $RDServerRole} | Where-Object {$PSItem.Installed -ne $False} | 
            Should -BeNullOrEmpty -Because "Server should be removed from connection broker"
    }
}
```
```
Describing Verify current state of RDS server
  [+] Collection name {CollectionName} on connectionBroker {ConnectionBroker.contoso.com} is removed 2.61s
  [+] Server {RDSServer} removed from connectionBroker {ConnectionBroker.contoso.com} 3.59s
  [+] Server {RDSServer} should have RDS roles uninstalled 170ms
```

## > It wasn't hard, wasn't it?




