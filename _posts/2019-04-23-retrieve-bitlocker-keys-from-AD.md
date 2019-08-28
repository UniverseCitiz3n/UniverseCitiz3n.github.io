---
title: Retrieve BitLocker keys shortcuts
categories:
    - BitLocker
tags:
    - PowerShell
    - BitLocker
excerpt: Two quick ways to get BitLocker keys from AD accros the realm
---

# Ups
Some [time ago](https://www.mczerniawski.pl/bitlocker/retrieve-bitlocker-recovery-key) I've posted how to set AD environment for BitLocker and retrieve keys from AD. I've missed one spot though. For that to work you had to be:

1. AD User
2. Member of local adminstrators on your machine.

I've updated that post with proper information how to [fix that](https://www.mczerniawski.pl/bitlocker/retrieve-bitlocker-recovery-key/#update-2019-04-23) - delegate proper permission to `SELF` object.

# Some Goodies

Today I'd like to share some `quick-dirty` scripts to automate even more:

## Backup ALL

If you'd like to backup BitLocker key to both AD and AzureAD at the same time, here's a sample script. Just select only machines you need in the Out-GridView

> Remember to Invoke (and retrieve BitLocker) to remote machine you require administrative permissions (or JEA with proper configuration)!

```powershell
$ComputerName =  Get-ADComputer -filter {OperatingSystem -like '*Windows*'} | Out-GridView -PassThru
Invoke-command -ComputerName $ComputerName -ScriptBlock {
  $bitLockerVolume = Get-BitlockerVolume
  foreach ($Blv in $bitLockerVolume) {
    $keyProtectors = $blv.KeyProtector | Where-Object {$PSItem.KeyProtectorType -eq 'RecoveryPassword'}
    if ($KeyProtectors) {
      Write-Host "MountPoint {'$($blv.MountPoint)'} - KeyProtector {'$($keyProtectors.KeyProtectorID)'}"
      Write-Host "    Backing up to AD"
      Backup-BitLockerKeyProtector -MountPoint $blv.MountPoint -KeyProtectorId $keyProtectors.KeyProtectorID
      Write-Host "    Backing up to Azure AD"
      BackupToAAD-BitLockerKeyProtector -MountPoint $blv.MountPoint -KeyProtectorId $keyProtectors.KeyProtectorID
    }
  }
}
```

## See ALL

And if You'd like to get all computers from AD with (and without) BitLocker information here's another one:

> Remember the account you're running HAS to have proper AD permissions!

```powershell
$computers = Get-ADcomputer -filter {OperatingSystem -like '*Windows*'} -Properties OperatingSystem,LastLogon

$results = foreach ($computer in $computers) {
    $ComputerName = $computer
    $DNComputer = Get-ADComputer $computerName | Select-Object -ExpandProperty DistinguishedName
    $obj = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $DNComputer -Properties 'msFVE-RecoveryPassword' | Select-Object Name,msFVE-RecoveryPassword
    if ($obj) {
    [pscustomobject]@{
        ComputerName = $ComputerName
        RecoveryPassword = $obj.'msFVE-RecoveryPassword'
        Date = Get-Date -Date ($obj.Name ).Split('{')[0]
        KeyID = (($obj.Name ).Split('{')[1]).TrimEnd('}')
        LastLogon = [datetime]::FromFileTime($computer.LastLogon)
        }
    }
    else {
     [pscustomobject]@{
        ComputerName = $ComputerName
        RecoveryPassword = $null
        Date = $Null
        KeyID = $null
        LastLogon = [datetime]::FromFileTime($computer.LastLogon)
        }
    }
}
```

Now you can easily spot which computers are missing BitLocker keys stored in AD:

```powershell
$empty = $results | where-object  {$null -eq $PSItem.RecoveryPassword }
```