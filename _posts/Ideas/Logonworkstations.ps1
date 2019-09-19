$RAdmins = Get-ADGroupMember -Identity RentedAdmins
foreach ($Admin in $RAdmins) {
    $CurrentStations = (Get-ADUser -Identity $Admin -Properties LogonWorkstations).LogonWorkstations
    $Rented = (Get-ADComputer -Filter "Name -like 'NBLAP*'").Name -join ','
    Set-ADUser -Identity $Admin -LogonWorkstations "$CurrentStations,$Rented"
}