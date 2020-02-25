$UserName = 'maciejhorbacz@dunesbox.onmicrosoft.com'
$Password = '3RuRz5EsJas&'

$PathToBin = 'C:\Repos\Objectivity.ProjectManagement\Objectivity.ProjectManagement\Bin\WebDriver.dll'
[System.Reflection.Assembly]::LoadFrom("{0}" -f $PathToBin)
if ($env:Path -notcontains ";$PathToBin`Bin" ) {
    $env:Path += ";$PathToBin`Bin"
}


$ChOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$ChOptions.AcceptInsecureCertificates = $True
$ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($ChOptions)
$ChromeDriver.Manage().Window.Maximize()
Start-Sleep 2
$ChromeDriver.url = 'https://portal.azure.com/'
Start-Sleep 5
$ChromeDriver.FindElementById('i0116').SendKeys($UserName)
$ChromeDriver.FindElementById('idSIButton9').Click()
Start-Sleep 2
$ChromeDriver.FindElementById('i0118').SendKeys($Password)
$ChromeDriver.FindElementById('idSIButton9').Click()
#Waiting for 2FA accept. 
Start-Sleep 3
$ChromeDriver.FindElementById('idSIButton9').Click()


$SaveButtonXPath = '/html/body/div[1]/div[5]/main/div[4]/div[2]/section/div/div[2]/div[1]/div/ul/li[1]'
foreach ($userID in $AADUsers) {
    Write-Log -Info -Message "Changing user $($userID.UserPrincipalName)"
    $AzureUrl = "https://portal.azure.com/#blade/Microsoft_AAD_IAM/UserDetailsMenuBlade/UserAuthMethods/userId/$($userID.ObjectId)/adminUnitObjectId/"
    $ChromeDriver.url = $AzureUrl
    $ChromeDriver.Navigate().Refresh()
    Start-Sleep 5
    Write-Log -Info -Message "Clearing field value"
    $Boxes = foreach ($i in 0..4) {
        $TextBox = "__azc-textBox$i"
        try {
            $LocationX = $ChromeDriver.FindElementByName("__azc-textBox$i").Location.X
            $LocationY = $ChromeDriver.FindElementByName("__azc-textBox$i").Location.Y
        }
        catch {
            $TextBox = 'No such box'
            $LocationX = $null
            $LocationY = $null
        }
        [pscustomobject] @{
            ID        = $TextBox
            LocationX = $LocationX
            LocationY = $LocationY
        }
    }
    $Boxes
    $MobileBox = $Boxes |`
        Where-Object { 
        $PSItem.Locationy -eq (($Boxes |`
                    Where-Object {
                    $PSItem.locationx -eq $( ($boxes.locationx | Measure-Object -Maximum).Maximum)
                }).locationy | Measure-Object -Minimum).Minimum 
            }

    $ChromeDriver.FindElementByName($MobileBox.ID).Clear()
    Start-Sleep 1
    Write-Log -Info -Message "Setting user correct number"
    
    $ChromeDriver.FindElementsByName($MobileBox.ID).SendKeys($UserCorrectNumber)
    Start-Sleep 1
    Write-Log -Info -Message "Saving changes"    
    $ChromeDriver.FindElementByXPath($SaveButtonXPath).Click()
    Start-Sleep 1
}

# //*[@id="web-container"]/div[5]/main/div[4]/div[2]/section/div/div[2]/div[1]/div/ul/li[5]/div
