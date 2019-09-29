$PathToFolder = 'C:\Temp\Selenium'
[System.Reflection.Assembly]::LoadFrom("{0}\WebDriver.dll" -f $PathToFolder)
if ($env:Path -notcontains ";$PathToFolder" ) {
    $env:Path += ";$PathToFolder"
}

$ChOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$ChOptions.AcceptInsecureCertificates = $True
$ChOptions.AddArgument('start-maximized')
$ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($ChOptions)
#$ChromeDriver.Manage().Window.Maximize()
$ChromeDriver.Url = 'https://powershell.org'
$ChromeDriver.FindElementsById('user_login').SendKeys('yourlogin@domain.com')
$ChromeDriver.FindElementsById('search').Clear()