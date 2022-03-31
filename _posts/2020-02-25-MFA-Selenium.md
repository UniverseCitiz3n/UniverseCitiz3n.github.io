---
title: How long would it take... 
categories:

    - Selenium

tags:

    - 2FA
    - Azure
    - Active Directory
    - Powershell

    - Selenium

excerpt: ... to fix hundreds of users mobile numbers in AzureAD MFA config manually? 😱

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Multi-factor authentication (MFA) is great security measure. The most common second factor is probably SMS code sent to your mobile phone. And what could go wrong there? Well I don't know how but at some point recently we had around **150 users** which did not receive codes even though they configured **MFA**.

# Issue

A user raised an issue that he does not receive codes for MFA. Is it cellphone carrier issue? Maybe user changed number and forgot about it? Or something else? First two assumptions were ruled out immediately so I focused on configuration of the service itself. For that I went to **user profile** in **Azure AD** and then to **Authentication methods**. There I saw:

![mfa]({{ site.url }}/assets/images/posts/2020-02-25-mfa.jpg)

Duplicated international call prefix 😮. I've removed additional digits - **0048** - and SMS codes began to arrive to user. That was easy! But then wondering came... how many users might have the same issue? 🤔<br>
To check that I've run:

``` powershell
Connect-MsolService
$MSONUSER = Get-MsolUser -All | select DisplayName -ExpandProperty StrongAuthenticationUserDetails |`
select DisplayName,email,phonenumber
```

Some sorting and filtering and I ended up with list of around 150 users which fitted in similar pattern where country prefix was doubled. I won't fix it manually!! Let's use some Powershell of MSGraph 😎.<br>
<font size="36">NOPE</font><br>
Powershell can't do that and API is (as on 25.02.2020) to be hopefully exposed in [Q1 2020](https://microsoftgraph.uservoice.com/forums/920506-microsoft-graph-feature-requests/suggestions/18493399-expose-user-authentication-phone-and-authenticatio).<br>
Some quick calculations...

![mfa2]({{ site.url }}/assets/images/posts/2020-02-25-mfa2.gif)

150 users x 2-5 minutes = 300-750 minutes = **5-12, 5 hours**

![mfa3]({{ site.url }}/assets/images/posts/2020-02-25-mfa3.gif)

There must be some way!! Wait a minute... 💡

# Selenium

If I'm not gonna click it then let's make browser click for me 😁 ([Checkout my post about starting with Selenium](https://universecitiz3n.tech/selenium/Selenium-Powershell/)). All I need is list of problematic users with their correct numbers and overview of properties of boxes in authorization methods tab. So to let's take a look at **url** of page while being in MFA tab

<https://portal.azure.com/#blade/Microsoft_AAD_IAM/UserDetailsMenuBlade/UserAuthMethods/userId/><br>**7af69645-0661-451f-b9fd-4fa36946f164**/adminUnitObjectId/

The only thing that changes is userID which you can grab from AzureAD like that

``` powershell
Connect-AzureAD
$AADUsers = Get-AzureADUser -All:$True
#That way we get list of all users and it should look like that:
ObjectId                             DisplayName       UserPrincipalName                      UserType
--------                             -----------       -----------------                      --------
7af69645-0661-451f-b9fd-4fa36946f164 Adele Vance       AdeleV@dunesbox.onmicrosoft.com        Member
```

Next thing. I did not expect that providing box properties will be such challenge. Normally you can operate on ID of an item and it will not change. But portal.azure.com proved me wrong! There IDs are randomly generated on every page refresh 😐. But **name** of a box always starts with **__azc-textBox** and at the end there is a digit. At the begging I though that **Phone** box will always have index 0 but this too was incorrect. There is one more box which is every time while you are on this site... top search box!

![mfa4]({{ site.url }}/assets/images/posts/2020-02-25-mfa4.jpg)

Knowing that I decided not to rely on name of a box entirely but rather on coordinates.<br>So I iterate through first 5

``` powershell
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
```

I got results like below and one last thing to do was to identify **Phone** box.

``` powershell
ID             LocationX LocationY
--             --------- ---------
__azc-textBox0       283         7
__azc-textBox1       844       295
__azc-textBox2       844       334
__azc-textBox3       844       373
__azc-textBox4       844       412

$MobileBox = $Boxes |`
Where-Object { 
    $PSItem.Locationy -eq (($Boxes |`
       Where-Object {
           $PSItem.locationx -eq $( ($boxes.locationx | Measure-Object -Maximum).Maximum)
        }).locationy | Measure-Object -Minimum).Minimum 
    }
```

With all that knowledge I was able to write my script which will modify phone numbers for provided users.

``` powershell

$UsersToFix = import-csv UsersToFix.csv
$PathToBin = 'c:\your\path\to\WebDriver.dll'
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
foreach ($userID in $UsersToFix) {
    Write-Default -Info -Message "Changing user $($userID.UserPrincipalName)"
    $AzureUrl = "https://portal.azure.com/#blade/Microsoft_AAD_IAM/UserDetailsMenuBlade/UserAuthMethods/userId/$($userID.ObjectId)/adminUnitObjectId/"
    $ChromeDriver.url = $AzureUrl
    $ChromeDriver.Navigate().Refresh()
    Start-Sleep 5
    Write-Output "Clearing field value"
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
    Write-Output "Setting user correct number"
    
    $ChromeDriver.FindElementsByName($MobileBox.ID).SendKeys($UserCorrectNumber)
    Start-Sleep 1
    Write-Output "Saving changes"    
    $ChromeDriver.FindElementByXPath($SaveButtonXPath).Click()
    Start-Sleep 1
}
```

# Summary

Thanks to that fixing this issue took around **one hour** where **25 minutes** was runtime of this script. It is not the most efficient way but for now it is the only one so I hope it will be useful for you!

See you in next! 😉 🧠
