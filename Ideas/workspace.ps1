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
$ChromeDriver.FindElementsById('file').SendKeys('C:\Temp\14853163_141016446369733_5206568431232995795_o.jpg')
$ChromeDriver.FindElementById('convert-button').Click()

Start-Sleep 10

$ChromeDriver.FindElementByXPath('//*[@id="convert-message"]/a').Click()