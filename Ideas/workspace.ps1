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
$ChromeDriver.Url = 'https://universecitiz3n.github.io'
$ChromeDriver.FindElementById('wp-submit').Click()
$ChromeDriver.FindElementByClassName
$ChromeDriver.FindElementByCssSelector
$ChromeDriver.FindElementById
$ChromeDriver.FindElementByLinkText
$ChromeDriver.FindElementByName
$ChromeDriver.FindElementByPartialLinkText
$ChromeDriver.FindElementByTagName
$ChromeDriver.FindElementByXPath