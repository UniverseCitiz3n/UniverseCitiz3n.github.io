---
title: How to use Selenium via Powershell
categories:

    - Selenium

tags:

    - Selenium
    - Powershell
    - Automation

excerpt: Selenium is framework for testing web applications..but I'm using it for automate things where API is no good
---
# Into

Nobody likes clicking on over and over the same thing just to get your job done. That is why I've started to automate things 😄. Everything goes smoothly if service provider gives you tools like <span style="color:yellow">APIs</span>, <span style="color:blue">Powershell</span> cmdlets, <span style="color:green">WebHooks</span>, etc. But how to get things done on website if those tools are **no good**? You can use Selenium! And what is Selenium? It is code driven testing framework which automates browser. With it help I were able to speed-up new project creation process in our company Jira which in this case (our Jira's version is somewhere 6) I were not able to use REST API.

Let me reveal some of this magic ✨
# Getting started

What you will need is **Webdriver.dll** you can grab some from [here]({{ site.url }}{{ site.baseurl }}/assets/bins/Selenium) or download directly from [NuGet](https://www.nuget.org/packages/Selenium.WebDriver) and extract it with 7-zip.
Secondly you will need browser driver. I'm using **Chrome Driver** but there are drivers for Firefox, Opera, Edge, Safari. You can get Chrome driver [here](https://sites.google.com/a/chromium.org/chromedriver/). Lastly after you pick your driver be sure that you have installed browser itself 😅. It's the best to put .dll and .exe in the same folder to which you will be reaching in code.

Time for some code
# Starting web driver

Firstly you need to load assembly to your workspace and executable to environmental path variable.

``` powershell
$PathToFolder = 'C:\Temp\Selenium'
[System.Reflection.Assembly]::LoadFrom("{0}\WebDriver.dll" -f $PathToFolder)
if ($env:Path -notcontains ";$PathToFolder" ) {
    $env:Path += ";$PathToFolder"
}
```

Done.

Now you can lunch Selenium driven browser from your Powershell console! Like that:

``` powershell
$ChromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$ChromeOptions.AddArgument('start-maximized')
$ChromeOptions.AcceptInsecureCertificates = $True

$ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($ChromeOptions)
$ChromeDriver.Url = 'https://universecitiz3n.github.io'
```

[demo]({{ site.url }}{{ site.baseurl }}/assets/images/posts/demo.gif)
You can see in this code that I'm creating two objects:
 - ChromeOptions
 this is a class which helps you set your browser preferences. Fullscreen is nice and second to save few lines of code when you bump into:

 [cert]({{ site.url }}{{ site.baseurl }}/assets/images/posts/cert.jpg)

<span style="color:red">Yeah be sure that you trust site even though its cert expired!!</span>

 - ChromeDriver
 this creates new instance of webdriver the moment you create object from this class your browser will come to life ⚡️

 # Things you can do

Making you browser open specified site comes to this

``` powershell
$ChromeDriver.Url = 'https://yourwebsite.com'
```

**You must remember to put link in https:// format**

How about clicking on stuff? Well you need to know ID of element or its position. Your best friend for that is **Inspect** option provided by browser.
[inspect]({{ site.url }}{{ site.baseurl }}/assets/images/posts/inspect.jpg)

One you have opened **Inspect** tab you will be able to identify web objects and with right Selenium command manipulate them!
These are available methods within webdriver that you can use

``` powershell
#The ones I'm used to use
$ChromeDriver.FindElementById('')
$ChromeDriver.FindElementByXPath('')

#The rest
$ChromeDriver.FindElementByClassName('')
$ChromeDriver.FindElementByCssSelector('')
$ChromeDriver.FindElementByLinkText('')
$ChromeDriver.FindElementByName('')
$ChromeDriver.FindElementByPartialLinkText('')
$ChromeDriver.FindElementByTagName('')
```

If website is well designed you should be able to get IDs of objects and user **FindElementById**
[IDs]({{ site.url }}{{ site.baseurl }}/assets/images/posts/inspect3.jpg)

In this case ID for **Log in** button is **wp-submit** and to click it just run code like:

``` powershell
$ChromeDriver.FindElementById('wp-submit').Click()
```

Now, what if some element has no ID? For me **XPath** works the best. Getting XPath value is simple as
[XPath]({{ site.url }}{{ site.baseurl }}/assets/images/posts/inspect4.jpg)

and now you can easily click on anything! Just like that:

``` powershell
$ChromeDriver.FindElementByXPath('//*[@id="main"]/div[2]/div[1]/article/h2/a').Click()
```

[awesome]({{ site.url }}{{ site.baseurl }}/assets/images/posts/awesome.jpg)

