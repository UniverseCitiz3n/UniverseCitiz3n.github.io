---
title: Intune - dealing with ErrorCode 0x8018002b 
categories:

    - Cloud

tags:

    - Intune
    - ActiveDirectory
    - Workstation
    - Windows 10

excerpt: A few things you should try that might help you 👨‍💻

comments: true

---
<!-- toc -->
# Intro

Happy New Year!🥳 Starting 2020 I promised myself to increase frequency of the posts so fingers crossed that it works out😉

In this post you will find couple of steps that are worth to try if your device is having problems enrolling to Intune. I can't guaranty that will help with every device. That's why you should think of this post as check list of things to keep in mind while debugging workstation.

My environment configuration:
* Hybrid Azure AD Join
* Auto-enrollment to Intune with GPO

![someimage]({{ site.url }}{{ site.baseurl }}/assets/images/posts/intune-macos-1.jpg)

Punkty:

* Service account in AD which has rights to create, rename computer objects in specified OU
* Organizational Unit which will store computer objects
* Connectivity to domain controller from Mac device

``` powershell

Write-Host 'This is a code'

```

See you in next! 😉 🧠

