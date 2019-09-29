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
Nobody likes clicking on over and over the same thing just to get your job done. That is why I've started to automate things 😄. Everything goes smoothly if service provider gives you tools like <span style="color:yellow">APIs</span>, <span style="color:blue">Powershell</span> cmdlets,<span style="color:green">WebHooks</span>, etc. But how to get things done on website if those tools are **no good**? You can use Selenium! And what is Selenium? It is code driven testing framework which automates browser. With it help I were able to speed-up new project creation process in our company Jira which in this case (our Jira's version is somewhere 6) I were not able to use REST API. 

Let me reveal some of this magic ✨

# Getting started
What you will need is **Webdriver.dll** you can grab some from [here]({{ site.url }}{{ site.baseurl }}/assets/bins/Selenium) or download directly from [NuGet](https://www.nuget.org/packages/Selenium.WebDriver) and extract it with 7-zip. 
Secondly you will need browser driver. I'm using **Chrome Driver** but there are drivers for Firefox, Opera, Edge, Safari. You can get Chrome driver [here](https://sites.google.com/a/chromium.org/chromedriver/). Lastly after you pick your driver be sure that you have installed browser itself 😅. It's the best to put .dll and .exe in the same folder to which you will be reaching in code.

