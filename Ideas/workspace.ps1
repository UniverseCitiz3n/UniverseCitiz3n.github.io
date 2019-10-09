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
$ChromeDriver.Url = 'https://www.onlineconverter.com/jpg-to-gif'
$ChromeDriver.FindElementsById('file').
Start-Sleep 1
$ChromeDriver.FindElementsById('user_pass').SendKeys('=K||"|WE^LI$R:Qs')
Start-Sleep 30
$ChromeDriver.FindElementsById('wp-submit').Click()