---
title: Manage Hyper-V Snapshots
categories:
    - HyperV
tags:
    - HyperV
    - Snapshot
    - PowerShell
excerpt: How to easily find, create and delete snaphots in your FailoverCluster realm
toc: true
toc_label: Manage snapshots
---

# Show me all your snapshots

We have a cluster with a bunch of VMs. Let's say around 300 :grin:.  
Some actions require us to take a snapshot of certain VMs and then remove them after we're sure everything is ok.  
We are using VeeamOne to track this, but it's goot do have good old PowerShell take care of the task itself.

There are 3 snippets here I'm using very often:

- create new snapshot with a certain name for selected VMs
- find all VMs with snapshots of certain name (i.e. 'SystemUpdate')
- remove all snapshots of certain name from selected VMs

This code also can be used to target single Hyper-V instances and use different Credentials.
Also some Hyper-V nodes may be in maintenance mode so first let's check which of those are available.

```powershell
$HyperVHost = 'ClusterName' #clustername 'ClusterName' or hostname 'HyperVHost'
$Cluster = $true #true if cluster is targeted
#$Credential = Get-Credential #Optional
$connProperties = @{
    ComputerName = $HyperVHost
}
if ($Credential) {
    $connProperties.Credential = $Credential
}
if ($Cluster) {
    $Nodes = Invoke-Command @connProperties -ScriptBlock {
        Get-ClusterNode | where-object { $_.State -eq 'Up' } | select-object -ExpandProperty Name
    }
    $connProperties.ComputerName = $Nodes
}
```

## Create Snapshots

Once I have all `active` nodes I can query them for VMs and process only specific ones to create snapshot `SystemUpdate`:

```powershell
$SnapshotName = 'SystemUpdate'
$VMsToProcess = @(
    'VMName1',
    'VMName2'
)

Invoke-Command @connProperties -ScriptBlock {
    $VMs =  Get-VM
    foreach ($VM in $VMs) {
        if($VM.VMName -in $USING:VMsToProcess) {
            Write-Host "Processing VM {$($VM.Name)} on Host {$($ENV:COMPUTERNAME)}"
            Checkpoint-VM -VM $VM -SnapshotName $USING:SnapshotName
        }
    }
}
```

## Find Snapshots

If I need to find all VMs with a snapshot of a name 'SystemUpdate' here's the code:

```powershell
$SnapshotName = 'SystemUpdate'
$VMs = Invoke-Command @connProperties -ScriptBlock {
    Get-VM | Get-VMSnapshot -Name $USING:SnapshotName -ErrorAction SilentlyContinue
}

$VMsToProcess = $VMs | Out-GridView -passThru
```

I'll get a window where I can select specific VMs to process. Also I'll see whether there is a parent snapshot present:

![OGV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/manage-hyperv-snapshots/picture1.png)

## Remove Snapshots

Now let's merge those snapshots:

```powershell
foreach ($process in $VMsToProcess) {
    $connProperties.ComputerName = $process.PSComputerName
    Invoke-Command @connProperties -ScriptBlock {
        Write-Host "Processing $($USING:process.VMName) on host $($env:COMPUTERNAME)"
        Get-VM $USING:process.VMName | Get-VMSnapshot -Name $USING:SnapshotName | Remove-VMSnapshot -Verbose
    }
}
```

## Full Code

Here are full snippets for given tasks

### Create Snapshots - Full Code

```powershell
$HyperVHost = 'ClusterName' #clustername 'ClusterName' or hostname 'HyperVHost'
$Cluster = $true #true if cluster is targeted
#$Credential = Get-Credential #Optional
$connProperties = @{
    ComputerName = $HyperVHost
}
if ($Credential) {
    $connProperties.Credential = $Credential
}
if ($Cluster) {
    $Nodes = Invoke-Command @connProperties -ScriptBlock {
        Get-ClusterNode | where-object { $_.State -eq 'Up' } | select-object -ExpandProperty Name
    }
    $connProperties.ComputerName = $Nodes
}
$SnapshotName = 'SystemUpdate'
$VMsToProcess = @(
    'VMName1',
    'VMName2'
)

Invoke-Command @connProperties -ScriptBlock {
    $VMs =  Get-VM
    foreach ($VM in $VMs) {
        if($VM.VMName -in $USING:VMsToProcess) {
            Write-Host "Processing VM {$($VM.Name)} on Host {$($ENV:COMPUTERNAME)}"
            Checkpoint-VM -VM $vM -SnapshotName $USING:SnapshotName
        }
    }
}
```

### Find Snapshots - Full Code

```powershell
$HyperVHost = 'ClusterName' #clustername 'ClusterName' or hostname 'HyperVHost'
$Cluster = $true #true if cluster is targeted
#$Credential = Get-Credential #Optional
$connProperties = @{
    ComputerName = $HyperVHost
}
if ($Credential) {
    $connProperties.Credential = $Credential
}
if ($Cluster) {
    $Nodes = Invoke-Command @connProperties -ScriptBlock {
        Get-ClusterNode | where-object { $_.State -eq 'Up' } | select-object -ExpandProperty Name
    }
    $connProperties.ComputerName = $Nodes
}
$SnapshotName = 'SystemUpdate'
$VMs = Invoke-Command @connProperties -ScriptBlock {
    Get-VM | Get-VMSnapshot -Name $USING:SnapshotName -ErrorAction SilentlyContinue
}

$VMsToProcess = $VMs | Out-GridView -passThru

```

### Remove Snapshots - Full Code

```powershell
$HyperVHost = 'ClusterName' #clustername 'ClusterName' or hostname 'HyperVHost'
$Cluster = $true #true if cluster is targeted
#$Credential = Get-Credential #Optional
$connProperties = @{
    ComputerName = $HyperVHost
}
if ($Credential) {
    $connProperties.Credential = $Credential
}
if ($Cluster) {
    $Nodes = Invoke-Command @connProperties -ScriptBlock {
        Get-ClusterNode | where-object { $_.State -eq 'Up' } | select-object -ExpandProperty Name
    }
    $connProperties.ComputerName = $Nodes
}
$SnapshotName = 'SystemUpdate'
$VMs = Invoke-Command @connProperties -ScriptBlock {
    Get-VM | Get-VMSnapshot -Name $USING:SnapshotName -ErrorAction SilentlyContinue
}

$VMsToProcess = $VMs | Out-GridView -passThru

foreach ($process in $VMsToProcess) {
    $connProperties.ComputerName = $process.PSComputerName
    Invoke-Command @connProperties -ScriptBlock {
        Write-Host "Processing $($USING:process.VMName) on host $($env:COMPUTERNAME)"
        Get-VM $USING:process.VMName | Get-VMSnapshot -Name $USING:SnapshotName | Remove-VMSnapshot -Verbose
    }
}
```

# Summary

These three little snippets saves me time whether I'm running a demo lab on  my private host, test hosts or production ones.
