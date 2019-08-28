---
title: Detach and Remove Disk from VM
categories:
    - HyperV
tags:
    - HyperV
    - PowerShell
    - Virtual Machine
excerpt: How to detach and remove disk from VM
---

# Simple, annoying task

Those kind I love. Why? Cause I can automate them :smile:

Here's the story - a VM on a Hyper-V host with a bunch of disks, that are no longer needed. Task:
- disable (set to `offline`)
- remove from VM configuration
- remove from disk

The hardest part was to map disk number from within OS to disk attached in VM configuration. It seems that `Location` from VM configuration maps to LUN number in `Location` within the Windows OS. That's great! 

![Disk]({{ site.url }}{{ site.baseurl }}/assets/images/posts/detach-and-remove-vhdx/picture1.png) 

# Disclaimer

> THIS IS A SCRIPT, NOT A FUNCTION

Bear in mind this is an interactive script that is supposed to be run with caution! Re-check your variables before removing. :smile: This is a dirty soltuion to get the task done!

> Consider yourself warned!

# Let's get to work

- initialize variables

```powershell
$Credential = Get-Credential

$VMConnectionProps = @{
    ComputerName = 'TestVM' #VMName
}
$HostConnectionProps =@{
    ComputerName = 'HyperVHost1' #HyperV Host Name
}

if ($Credential) {
    $VMConnectionProps.Credential = $Credential
    $HostConnectionProps.Credential = $Credential
}
```

- using Out-GridView select which disks to process

```powershell
$disksToDisable =  Invoke-Command @VMConnectionProps -ScriptBlock {
    Get-Disk | where-object {$null -ne $PSItem.Number } 
} | Out-GridView -PassThru
```

- set disks to `offline`

```powershell
if ($disksToDisable) {
    Invoke-Command @VMConnectionProps -ScriptBlock {
        foreach ($disk in $USING:disksToDisable) {
            Write-Host "Processing with disk - [$($disk.FriendlyName)] to disable."
            Set-Disk -InputObject $disk -IsOffline $true
        }
    }
}
```

- get vhdx files attached to VM (from VM configuration)

```powershell
$VMDisks = Invoke-Command @HostConnectionProps -ScriptBlock {
    Get-VM -Name $USING:VMConnectionProps.ComputerName | Select-Object -ExpandProperty HardDrives
}
```

- compare and get final list of disks

```powershell
$ToDelete= foreach ($diskToDisable in $disksToDisable) {
    $VMDisks | Where-Object {$PSItem.ControllerLocation -eq $diskToDisable.Number}
}
```

- detach disks from VM

```powershell
foreach ($disk in $ToDelete) {
    Write-Host "Processing VM [$($VMConnectionProp.ComputerName)] on Host [$($HostConnectionProps.ComputerName)] - Removing disk [$($disk.ControllerLocation)] with Path [$($disk.Path)]"
    Invoke-Command @HostConnectionProps -ScriptBlock {
        $removeVMHardDiskDriveSplat = @{
            ControllerType     = $USING:disk.ControllerType
            ControllerNumber   = $USING:disk.ControllerNumber
            VMName             = $USING:VMConnectionProps.ComputerName
            ControllerLocation = $USING:disk.controllerLocation
        }
        Remove-VMHardDiskDrive @removeVMHardDiskDriveSplat
    }
}
```

- remove vhdx from Hyper-V

```powershell
Invoke-Command @HostConnectionProps -ScriptBlock {
    foreach ($disk in $USING:ToDelete) {
        Remove-Item -Path $disk.Path 
    }
}
```

# Full script

Here's the full script

```powershell
$Credential = Get-Credential

$VMConnectionProps = @{
    ComputerName = 'TestVM' #VMName
}
$HostConnectionProps =@{
    ComputerName = 'HyperVHost1' #HyperV Host Name
}

if ($Credential) {
    $VMConnectionProps.Credential = $Credential
    $HostConnectionProps.Credential = $Credential
}

#Get specifc disks from VM
$disksToDisable =  Invoke-Command @VMConnectionProps -ScriptBlock {
    Get-Disk | where-object {$null -ne $PSItem.Number } 
} | Out-GridView -PassThru

#Set disk to offline
if ($disksToDisable) {
    Invoke-Command @VMConnectionProps -ScriptBlock {
        foreach ($disk in $USING:disksToDisable) {
            Write-Host "Processing with disk - [$($disk.FriendlyName)] to disable."
            Set-Disk -InputObject $disk -IsOffline $true
        }
    }
}

#Get disks attached to VM
$VMDisks = Invoke-Command @HostConnectionProps -ScriptBlock {
    Get-VM -Name $USING:VMConnectionProps.ComputerName | Select-Object -ExpandProperty HardDrives
}

#get vhdx to disable and delete
$ToDelete= foreach ($diskToDisable in $disksToDisable) {
    $VMDisks | Where-Object {$PSItem.ControllerLocation -eq $diskToDisable.Number}
}

#detach disk from VM
foreach ($disk in $ToDelete) {
    Write-Host "Processing VM [$($VMConnectionProp.ComputerName)] on Host [$($HostConnectionProps.ComputerName)] - Removing disk [$($disk.ControllerLocation)] with Path [$($disk.Path)]"
    Invoke-Command @HostConnectionProps -ScriptBlock {
        $removeVMHardDiskDriveSplat = @{
            ControllerType     = $USING:disk.ControllerType
            ControllerNumber   = $USING:disk.ControllerNumber
            VMName             = $USING:VMConnectionProps.ComputerName
            ControllerLocation = $USING:disk.controllerLocation
        }
        Remove-VMHardDiskDrive @removeVMHardDiskDriveSplat
    }
}
#remove vhdx from Hyper-V
Invoke-Command @HostConnectionProps -ScriptBlock {
    foreach ($disk in $USING:ToDelete) {
        Remove-Item -Path $disk.Path 
    }
}
```