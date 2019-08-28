---
title: Remove VM from Hyper-V host and from AD
categories:
    - HyperV
tags:
    - HyperV
    - PowerShell
    - Virtual Machine
excerpt: Decomission VM from AD and Hyper-V host or Cluster
---

# Not so Simple, yet very annoying task

In my company when we decomission a VM there's a list of things to do:

- get all DNS entries that may be related 
- get all dhcp entries that may be related
- get AD computer object and :
    - disable it and move to proper OU (if VM is to be deleted according to our schedule)
    - disable it and mote to repository OU (if VM is put into an archive repository)
    - disable and remove it
- get all AD groups that may be related and remove (we name groups after the VM like VMName1-Admins, VMName1-SQL-DB1-Users)
- if the VM was clustered - remove from Cluster
- remove from Hyper-V host
- remove files from storage
- remove from monitoring (zabbix) system

**Additional requirements is that there should be a log of the actions**

# Let's automate

This isn't rocket science here. To allow for better flow control I've used `Out-GridView -PassThru` for a `poor man's GUI` :grin:

This is still a very early **Work-In-Progress** but maybe it will be of some use to anyone :smile:

This is supposed to be run interactively by an admin. Also - it will delete VM files only from it's main location. If VM has disk in different location - it won't delete it for now!

Just some basic variable initilization:

```powershell
throw "PERFORM with CAUTION!"

# REQUIRES ADMINISTRATIVE RIGHTS ON DESTINATION HOST and proper permissions in AD

$ComputerName = 'VMName1' #Provide VMName to hunt for
$ActionToProcess = 'Disabled' # Select one of: 'Disabled', 'Remove' ,'Respository'
$HyperVHost = 'Cluster1' # Provide cluster or hyper-V host name
$dhcpComputer = 'DHCP1' # Provide DHCP server name
$Clustered = $true # Select one of: $true, $false
$IncludeZabbix = $true # Select one of: $true, $false
$DisabledPath = 'OU=Servers,OU=Disabled,DC=contoso,DC=com'
$RepoPath = 'OU=VMRepository,OU=Disabled,DC=contoso,DC=com'
$TranscriptPath = 'C:\AdminTools\Cleanup'
$DNSServer = 'DNSServer' # Provide DNS server name
$Domain = 'contoso.com' # Provide domain name
$ZabbixURI = 'https://zabbix.{0}/zabbix/api_jsonrpc.php' -f $Domain

####################################

Start-Transcript -Path ('{0}\{1}_{2}.log' -f $TranscriptPath, $ComputerName, (Get-Date -f 'yyyyMMdd_HHmm') )
Write-Host -Message "Starting Cleanup for Computername {$ComputerName} with action {$ActionToProcess}"
```

Start with DNS and DHCP cleanup. I'm searching for objects matching to my VMName and then allow the operator to choose which records to delete (using `Out-GridView -PassThru`)

```powershell
#region DNS Entries
$serverprops = @{
    ComputerName = $DNSServer
    ZoneName     = $Domain
}
$DNSrecords = Get-DnsServerResourceRecord  @serverprops | Where-Object {$PSItem.HostName -match $ComputerName} | Out-GridView -PassThru
if ($DNSrecords) {
    $DNSrecords | ForEach-Object { 
        Write-Host -Message "Removing DNS entry {$($PSItem.HostName)} - IP {$($PSItem.RecordData)} - record type {$($PSItem.RecordType)}"
        Remove-DnsServerResourceRecord @serverprops -Name $PSItem.HostName -RRType $PSItem.RecordType -confirm:$false
    }
}
#endregion

#region DHCP entries
$dhcpScopes = Get-DhcpServerv4Scope -computername $dhcpComputer
$DHCPLeases = $dhcpScopes | ForEach-Object { Get-DhcpServerv4Lease -ComputerName $dhcpComputer -ScopeId $PSItem.ScopeID | Where-Object {$PSItem.HostName -match $ComputerName} }| Out-GridView -PassThru

if ($DHCPLeases) {
    foreach ($dhcplease in $DHCPLeases) {
        if ($dhcplease.AddressState -match 'Reservation') {
            Write-Host -Message "Removing DHCP Reservation {$($dhcplease.HostName)} - IP {$($dhcplease.IPAddress)} - address state {$($dhcplease.AddressState)}"
            Remove-DhcpServerv4Reservation -ComputerName $dhcpComputer -ScopeId $dhcplease.scopeid -ClientId $dhcplease.ClientID -Confirm:$false -PassThru
        }
        else {
            Write-Host -Message "Removing DHCP Lease {$($dhcplease.HostName)} - IP {$($dhcplease.IPAddress)} - address state {$($dhcplease.AddressState)}"
            Remove-DhcpServerv4Lease -ComputerName $dhcpComputer -ScopeId $dhcplease.scopeid -ClientId $dhcplease.ClientID -Confirm:$false -PassThru
        }
    }
}
#endregion
```
Now some fun with AD Object. Get it and then process based on operator input `$ActionToProcess = 'Disabled'` :

```powershell
#region Get AD Computer Object
$ComputerObject = Get-ADComputer $ComputerName | Out-GridView -PassThru
Write-Host -Message "Found AD Object for Computer {$computerName} - {$($ComputerObject.Name)} with state {$($ComputerObject.Enabled)}"
#endregion

#region Process with AD Object
switch ($ActionToProcess) {
    'Disabled' {
        #region to Disabled
        if ($ComputerObject) {

            $ComputerObject | foreach-object { 
                Write-Host -Message "Disabling Computer Object {$($PSItem.Name)}"
                $PSItem | Set-ADComputer -Enabled $false
                Write-Host -Message "Moving Computer Object {$($PSItem.Name)} to DisabledPath: {$DisabledPath}"
                $PSItem | Move-ADObject -TargetPath $DisabledPath -PassThru
            }
        }
        else {
            Write-Log -Info -Message "No Computer Objects found for Computer {$ComputerName}"
        }
        #endregion
    }
    'Remove' {
        #region to Remove
        if ($ComputerObject) {
            $ComputerObject | foreach-object { 
                Write-Host -Message "Disabling Computer Object {$($PSItem.Name)}"
                $PSItem | Set-ADComputer -Enabled $false
                Write-Host -Message "Removing Computer Object {$($PSItem.Name)}"
                $PSItem | Get-ADObject | ForEach-Object {  
                    Remove-ADObject -Recursive -Identity $PSItem
                }
            }
        }
        else {
            Write-Log -Info -Message "No Computer Objects found for Computer {$ComputerName}"
        }
        #endregion
    }
    'Respository' {
        #region to Repository
        if ($ComputerObject) {
            $ComputerObject | foreach-object { 
                Write-Host -Message "Disabling Computer Object {$($PSItem.Name)}"
                $PSItem | Set-ADComputer -Enabled $false
                Write-Host -Message "Moving Computer Object {$($PSItem.Name)} to VMRepoPath: {$RepoPath}"
                $PSItem | Move-ADObject -TargetPath $RepoPath -PassThru
            }
        }
        else {
            Write-Log -Info -Message "No Computer Objects found for Computer {$ComputerName}"
        }
        #endregion
    }
}
#endregion
```

Now let's move with groups:

```powershell
#region Groups
$ComputerGroups = Get-ADGroup -filter * | Where-Object {$PSItem.name -match ('{0}-' -f $ComputerName)} | Out-GridView -PassThru
if ($ComputerGroups) {
    $ComputerGroups | ForEach-Object {
        Write-Host -Message "Removing ADGroup {$($PSItem.Name)} with DN  {$($PSItem.DistinguishedName)}"
        $PSItem | Remove-ADGroup -Confirm:$false
    }
}
else {
    Write-Log -Info -Message "No Groups found for Computer {$ComputerName}"
}
#endregion
```

If the VM was clustered - remove from cluster and then from Hyper-V. Else - jump straight to Hyper-V host and remove it:

```powershell
#region VM on the production cluster
if ($Clustered) {
    #region Remove from Cluster Group
    $ClusterResource = Get-ClusterResource -Name ('Virtual Machine {0}' -f $ComputerName) -Cluster $HyperVHost -ErrorAction SilentlyContinue
    if ($ClusterResource) { 
        $VM = Invoke-Command -ComputerName ($ClusterResource.OwnerNode.NodeName) -ScriptBlock {
            Get-VM -Name $USING:ClusterResource.OwnerGroup
        } | Out-GridView -PassThru
        Write-Host -Message "Removing VM {$($VM.Name)} from cluster {$HyperVHost}"
        Remove-ClusterGroup -Cluster $HyperVHost -VMId $vm.Id -RemoveResources
    }
    else {
        Write-Log -Info -Message "No Cluster Resource on cluster {$HyperVHost} found for Computer {$ComputerName}"
    }
    #endregion 

    #region Remove from host and remove files
    Invoke-Command -ComputerName $VM.PSComputerName -ScriptBlock {
        $VMToProcess = Get-VM -Name $USING:VM.Name
        if ($VMToProcess.State -eq 'Running') {
            Write-Host "Turning off VM {$($VMToProcess.VMName)} on host {$($USING:HypervHost)}"
            $VMToProcess | Stop-VM  -Force
        }
        Start-Sleep -Seconds 10
        $VMToProcess = Get-VM -Name $USING:VM.Name
        if ($VMToProcess.State -eq 'Off') {
            Write-Host "Removing VM {$($VMToProcess.VMName)} from host {$($USING:HypervHost)}"
            Remove-VM -Name $VMToProcess.VMName
            Start-Sleep -Seconds 5
            Write-Host "Removing VM files {$($VMToProcess.VMName)} from path {$($VMToProcess.Path)}"
            Remove-Item -Path $VMToProcess.Path -Recurse 
        }
    }
    #endregion
   
}
#endregion

#region remove from HyperVHost
else { 
    Invoke-Command -ComputerName $HyperVHost -ScriptBlock {
        $VMToProcess = Get-VM -Name $USING:ComputerName
        if ($VMToProcess.State -eq 'Running') {
            Write-Host "Turning off VM {$($VMToProcess.VMName)} on host {$($USING:HypervHost)}"
            $VMToProcess | Stop-VM  -Force
        }
        Start-Sleep -Seconds 10
        $VMToProcess = Get-VM -Name $USING:ComputerName
        if ($VMToProcess.State -eq 'Off') {
            Write-Host "Removing VM {$($VMToProcess.VMName)} from host {$($USING:HypervHost)}"
            Remove-VM -Name $VMToProcess.VMName
            Start-Sleep -Seconds 5
            Write-Host "Removing VM files {$($VMToProcess.VMName)} from path {$($VMToProcess.Path)}"
            Remove-Item -Path $VMToProcess.Path -Recurse 
        }
    } 
    
}
#endregion
```

Finally - if it was added to Zabbix - delete it:

```powershell
#region Zabbix
if ($IncludeZabbix) {
    if (-not ($zabbixSession)) {
        Import-Module PSZabbix
        $zabbixSession = New-ZbxApiSession "$zabbixURI" (Get-Credential $env:Username)
    }
    #region cleanup zabbix
    $zbxHost = Get-ZbxHost -Session $zabbixSession | Where-Object {$PSItem.Name -match "$computername" } | Out-GridView -PassThru
    if ($zbxHost) {
        Write-Log -Info -Message "Removing host {$ComputerName} from zabbix - hostID {$($zbxHost.HostId)}"
        Remove-ZbxHost -Session $zabbixSession -HostId $zbxHost.hostid
    }
    else {
        Write-Log -Info -Message "No Zabbix host found for Computer {$ComputerName}"
    }


}
#endregion
```

And stop the tanscript

```powershell
Write-Host -Message "Finished Cleanup for Computername {$ComputerName} with action {$ActionToProcess}"
Stop-Transcript
```

# Full Script

```powershell
throw "PERFORM with CAUTION!"

# REQUIRES ADMINISTRATIVE RIGHTS ON DESTINATION HOST and proper permissions in AD

$ComputerName = 'VMName1' #Provide VMName to hunt for
$ActionToProcess = 'Disabled' # Select one of: 'Disabled', 'Remove' ,'Respository'
$HyperVHost = 'Cluster1' # Provide cluster or hyper-V host name
$dhcpComputer = 'DHCP1' # Provide DHCP server name
$Clustered = $true # Select one of: $true, $false
$IncludeZabbix = $true # Select one of: $true, $false
$DisabledPath = 'OU=Servers,OU=Disabled,DC=contoso,DC=com'
$RepoPath = 'OU=VMRepository,OU=Disabled,DC=contoso,DC=com'
$TranscriptPath = 'C:\AdminTools\Cleanup'
$DNSServer = 'DNSServer' # Provide DNS server name
$Domain = 'contoso.com' # Provide domain name
$ZabbixURI = 'https://zabbix.{0}/zabbix/api_jsonrpc.php' -f $Domain

####################################

Start-Transcript -Path ('{0}\{1}_{2}.log' -f $TranscriptPath, $ComputerName, (Get-Date -f 'yyyyMMdd_HHmm') )
Write-Host -Message "Starting Cleanup for Computername {$ComputerName} with action {$ActionToProcess}"

#region DNS Entries
$serverprops = @{
    ComputerName = $DNSServer
    ZoneName     = $Domain
}
$DNSrecords = Get-DnsServerResourceRecord  @serverprops | Where-Object {$PSItem.HostName -match $ComputerName} | Out-GridView -PassThru
if ($DNSrecords) {
    $DNSrecords | ForEach-Object { 
        Write-Host -Message "Removing DNS entry {$($PSItem.HostName)} - IP {$($PSItem.RecordData)} - record type {$($PSItem.RecordType)}"
        Remove-DnsServerResourceRecord @serverprops -Name $PSItem.HostName -RRType $PSItem.RecordType -confirm:$false
    }
}
#endregion

#region DHCP entries
$dhcpScopes = Get-DhcpServerv4Scope -computername $dhcpComputer
$DHCPLeases = $dhcpScopes | ForEach-Object { Get-DhcpServerv4Lease -ComputerName $dhcpComputer -ScopeId $PSItem.ScopeID | Where-Object {$PSItem.HostName -match $ComputerName} }| Out-GridView -PassThru

if ($DHCPLeases) {
    foreach ($dhcplease in $DHCPLeases) {
        if ($dhcplease.AddressState -match 'Reservation') {
            Write-Host -Message "Removing DHCP Reservation {$($dhcplease.HostName)} - IP {$($dhcplease.IPAddress)} - address state {$($dhcplease.AddressState)}"
            Remove-DhcpServerv4Reservation -ComputerName $dhcpComputer -ScopeId $dhcplease.scopeid -ClientId $dhcplease.ClientID -Confirm:$false -PassThru
        }
        else {
            Write-Host -Message "Removing DHCP Lease {$($dhcplease.HostName)} - IP {$($dhcplease.IPAddress)} - address state {$($dhcplease.AddressState)}"
            Remove-DhcpServerv4Lease -ComputerName $dhcpComputer -ScopeId $dhcplease.scopeid -ClientId $dhcplease.ClientID -Confirm:$false -PassThru
        }
    }
}
#endregion

#region Get AD Computer Object
$ComputerObject = Get-ADComputer $ComputerName | Out-GridView -PassThru
Write-Host -Message "Found AD Object for Computer {$computerName} - {$($ComputerObject.Name)} with state {$($ComputerObject.Enabled)}"
#endregion

#region Process with AD Object
switch ($ActionToProcess) {
    'Disabled' {
        #region to Disabled
        if ($ComputerObject) {

            $ComputerObject | foreach-object { 
                Write-Host -Message "Disabling Computer Object {$($PSItem.Name)}"
                $PSItem | Set-ADComputer -Enabled $false
                Write-Host -Message "Moving Computer Object {$($PSItem.Name)} to DisabledPath: {$DisabledPath}"
                $PSItem | Move-ADObject -TargetPath $DisabledPath -PassThru
            }
        }
        else {
            Write-Log -Info -Message "No Computer Objects found for Computer {$ComputerName}"
        }
        #endregion
    }
    'Remove' {
        #region to Remove
        if ($ComputerObject) {
            $ComputerObject | foreach-object { 
                Write-Host -Message "Disabling Computer Object {$($PSItem.Name)}"
                $PSItem | Set-ADComputer -Enabled $false
                Write-Host -Message "Removing Computer Object {$($PSItem.Name)}"
                $PSItem | Get-ADObject | ForEach-Object {  
                    Remove-ADObject -Recursive -Identity $PSItem
                }
            }
        }
        else {
            Write-Log -Info -Message "No Computer Objects found for Computer {$ComputerName}"
        }
        #endregion
    }
    'Respository' {
        #region to Repository
        if ($ComputerObject) {
            $ComputerObject | foreach-object { 
                Write-Host -Message "Disabling Computer Object {$($PSItem.Name)}"
                $PSItem | Set-ADComputer -Enabled $false
                Write-Host -Message "Moving Computer Object {$($PSItem.Name)} to VMRepoPath: {$RepoPath}"
                $PSItem | Move-ADObject -TargetPath $RepoPath -PassThru
            }
        }
        else {
            Write-Log -Info -Message "No Computer Objects found for Computer {$ComputerName}"
        }
        #endregion
    }
}
#endregion

#region Groups
$ComputerGroups = Get-ADGroup -filter * | Where-Object {$PSItem.name -match ('{0}-' -f $ComputerName)} | Out-GridView -PassThru
if ($ComputerGroups) {
    $ComputerGroups | ForEach-Object {
        Write-Host -Message "Removing ADGroup {$($PSItem.Name)} with DN  {$($PSItem.DistinguishedName)}"
        $PSItem | Remove-ADGroup -Confirm:$false
    }
}
else {
    Write-Log -Info -Message "No Groups found for Computer {$ComputerName}"
}
#endregion

#region VM on the production cluster
if ($Clustered) {
    #region Remove from Cluster Group
    $ClusterResource = Get-ClusterResource -Name ('Virtual Machine {0}' -f $ComputerName) -Cluster $HyperVHost -ErrorAction SilentlyContinue
    if ($ClusterResource) { 
        $VM = Invoke-Command -ComputerName ($ClusterResource.OwnerNode.NodeName) -ScriptBlock {
            Get-VM -Name $USING:ClusterResource.OwnerGroup
        } | Out-GridView -PassThru
        Write-Host -Message "Removing VM {$($VM.Name)} from cluster {$HyperVHost}"
        Remove-ClusterGroup -Cluster $HyperVHost -VMId $vm.Id -RemoveResources
    }
    else {
        Write-Log -Info -Message "No Cluster Resource on cluster {$HyperVHost} found for Computer {$ComputerName}"
    }
    #endregion 

    #region Remove from host and remove files
    Invoke-Command -ComputerName $VM.PSComputerName -ScriptBlock {
        $VMToProcess = Get-VM -Name $USING:VM.Name
        if ($VMToProcess.State -eq 'Running') {
            Write-Host "Turning off VM {$($VMToProcess.VMName)} on host {$($USING:HypervHost)}"
            $VMToProcess | Stop-VM  -Force
        }
        Start-Sleep -Seconds 10
        $VMToProcess = Get-VM -Name $USING:VM.Name
        if ($VMToProcess.State -eq 'Off') {
            Write-Host "Removing VM {$($VMToProcess.VMName)} from host {$($USING:HypervHost)}"
            Remove-VM -Name $VMToProcess.VMName
            Start-Sleep -Seconds 5
            Write-Host "Removing VM files {$($VMToProcess.VMName)} from path {$($VMToProcess.Path)}"
            Remove-Item -Path $VMToProcess.Path -Recurse 
        }
    }
    #endregion
   
}
#endregion

#region remove from HyperVHost
else { 
    Invoke-Command -ComputerName $HyperVHost -ScriptBlock {
        $VMToProcess = Get-VM -Name $USING:ComputerName
        if ($VMToProcess.State -eq 'Running') {
            Write-Host "Turning off VM {$($VMToProcess.VMName)} on host {$($USING:HypervHost)}"
            $VMToProcess | Stop-VM  -Force
        }
        Start-Sleep -Seconds 10
        $VMToProcess = Get-VM -Name $USING:ComputerName
        if ($VMToProcess.State -eq 'Off') {
            Write-Host "Removing VM {$($VMToProcess.VMName)} from host {$($USING:HypervHost)}"
            Remove-VM -Name $VMToProcess.VMName
            Start-Sleep -Seconds 5
            Write-Host "Removing VM files {$($VMToProcess.VMName)} from path {$($VMToProcess.Path)}"
            Remove-Item -Path $VMToProcess.Path -Recurse 
        }
    } 
    
}
#endregion

#region Zabbix
if ($IncludeZabbix) {
    if (-not ($zabbixSession)) {
        Import-Module PSZabbix
        $zabbixSession = New-ZbxApiSession "$zabbixURI" (Get-Credential $env:Username)
    }
    #region cleanup zabbix
    $zbxHost = Get-ZbxHost -Session $zabbixSession | Where-Object {$PSItem.Name -match "$computername" } | Out-GridView -PassThru
    if ($zbxHost) {
        Write-Log -Info -Message "Removing host {$ComputerName} from zabbix - hostID {$($zbxHost.HostId)}"
        Remove-ZbxHost -Session $zabbixSession -HostId $zbxHost.hostid
    }
    else {
        Write-Log -Info -Message "No Zabbix host found for Computer {$ComputerName}"
    }


}
#endregion

Write-Host -Message "Finished Cleanup for Computername {$ComputerName} with action {$ActionToProcess}"
Stop-Transcript
```

# Summary

These are just basic commands - but thanks to PowerShell - decommisioning a VM takes a minute or two :smile:

---
