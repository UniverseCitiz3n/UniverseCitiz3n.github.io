---
title: Get AzureAD Guest accounts and remove them
categories:
    - AzureAD
tags:
    - PowerShell
    - AzureAD
    - Office365
excerpt: Clean Azure AD from unneeded Guest accounts
---

# Cleanup Time

It's good to know what guest users accounts are invited to your tenant. I can either check that through `Users blade` in  [AzureAD Portal](https://portal.azure.com/#blade/Microsoft_AAD_IAM/UsersManagementMenuBlade/AllUsers) or using PowerShell:

```powershell
Connect-AzureAD
Get-AzureADUser -Filter "userType eq 'Guest'" -All $true 
```

If there are some accounts, it's best to verify with the business whether they are still required. Most Project Managers are not goot at PowerShell, but they're quite profficient with excel. I'll export all necessary data to a csv file with additional columnt ToDelete:

```powershell
$SelectFilter = @(
    'DisplayName',
    'UserPrincipalName',
    'Mail',
    @{
        name='ToDelete'
        expression={''}            
    }
    'Department',
    'UserType',
    'CreationType',
    'RefreshTokensValidFromDateTime',
    'AccountEnabled',
    @{
        name='Licensed'
        expression={
            if($_.AssignedLicenses){$TRUE}
            else{$False}
        }
    }
    @{
        name='Plan'
        expression={
            if($_.AssignedPlans){$TRUE}
            else{$False}
        }
    }
    'ObjectId' 
)
Get-AzureADUser -Filter "userType eq 'Guest'" -All $true |
    Select-Object $SelectFilter | 
    Export-csv -Path "C:\AdminTools\AzureADGuestUsers_$(Get-Date -f yyyyMMdd_HHmm).csv" -NoTypeInformation
```

Once they fill in which accounts should be deleted this will do the trick. 

As I don't ~~trust~~ know, what character they will use in the ToDelete column, I prefer to use `Out-GridView` to select only required rows :grin:

Then I can process with ~~extermination~~ cleaning up :smile: :

```powershell
Connect-AzureAD
$ToDeleteGuestUsers = Import-Csv -Path C:\AdminTools\AzureADGuestUsers_20190207_0844.csv | Out-GridView -passThru

$ToDeleteGuestUsers | foreach {
    Get-AzureADObjectByObjectId -ObjectIds $_.ObjectID
    Remove-AzureADUser -ObjectId $_.ObjectID -Verbose    
}
```


