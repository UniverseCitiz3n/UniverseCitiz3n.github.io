New-ManagementRole "LanSweeperRole" -Parent "Mail Recipients"
Get-ManagementRoleEntry "LanSweeperRole\*" |`
    Where-Object { $PSItem.Name -notlike 'Get-mailbox' -or $PSItem.Name -notlike 'Get-mailContact' -or $PSItem.Name -notlike 'Get-ActiveSyncDevice' } |`
    ForEach-Object { Remove-ManagementRoleEntry -Identity "$($PSItem.id)\$($PSItem.name)" -Confirm:$false }
New-RoleGroup 'LanSweeperScan' -Role 'LanSweeperRole' -Member 'sa_Lansweeper_O365'