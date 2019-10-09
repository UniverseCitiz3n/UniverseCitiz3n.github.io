---
title: Browser automation with Selenium - use cases
categories:

    - Selenium

tags:

    - Selenium
    - Powershell
    - Automation
    - Credentials
    - Confluence

excerpt: What you can do and how to automate clicking in browser with Powershell

comments: true

---
# Intro

In this post I am going to show you some use cases of Selenium in automating browser where API is unavailable or not enough. Before we continue please be sure to check first steps in using this testing framework via Powershell - [How to use Selenium via Powershell
]({{ site.url }}{{ site.baseurl }}/selenium/Selenium-Powershell/) 😉 <br>
...ok, done reading? Let's roll!
# Signing in

What I'm about to show you might not be the most clever way to pass credentials at websites but it works in controlled environment. Just like in introduction most of the times we have:

![login]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2019-10-09-1.jpg)

So we need to fill username, password and captcha but there is no trick to that.
```powershell
$Credential = Get-Credentials
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
$PlainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$ChromeDriver.FindElementsById('user_login').SendKeys($Credential.UserName)
Start-Sleep 1
$ChromeDriver.FindElementsById('user_pass').SendKeys($PlainPass)
Start-Sleep 30 #Wait for user to pass captcha
$ChromeDriver.FindElementsById('wp-submit').Click()
```
I've created PSCredential variable and to be able to fill in password field we need to decipher it. Without those steps you will be entering *System.Security.SecureString* which obviously is not your password, or is it? 🤔<br> 
Regarding *captcha* the only way is to pause script until user passes the test.

# Tables on sites

Great example of table which required help of Selenium is permission table in Confluence Spaces.
![Space]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2019-10-09-2.jpg)













# Summary

See you in next! 😉 🧠

