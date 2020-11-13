---
title: Build, Test, Deploy – Software Distribution Using Intune
categories:

    - Powershell

tags:

    - Intune
    - Powershell
    - WindowsSandbox

excerpt: Take a look at my process where I'm using Powershell to install software and test installation in Windows Sandbox

comments: true
toc: true
toc_label: Table of contents
---

# Intro

The time has come to summarize my project!
In this post you will find links to resources where you can find project details 😎

# Github

The heart (source code) of the project

[Intune Application Sandbox](https://github.com/UniverseCitiz3n/Intune-App-Sandbox)

To configure tool on your device `Clone` this repo and run `Add-SandboxShell.ps1`.

It will create folder - `C:\SandboxEnvironment` where all necessary items will be stored.
You will be also prompt to choose which context menu items you wish to apply.

1. Run test in Sandbox
1. Pack with IntunewinUtil
1. Both

Feel free to dig in and use those cool scripts:

* Get-WindowsInstalledPrograms.ps1 - It scans device registry and finds uninstallation strings for Software
* Install-ProgramScriptTemplate.ps1 - My template script which uses `Powershell` to install software
* Write-FileLog.ps1 - Simple script which helps you create installation log file with necessary info

# PWSH24

It was an honor of conducting a session regarding my tool on this years **PowerShell & DevOps Global Conference**!

> The DevOps Collective, in conjunction with the organizers of PSConf Asia and PSConf Day UK, would like to announce a new event…the Global PowerShell & DevOps Conference – Online. With the cancellation of major PowerShell-related conferences including the PowerShell + DevOps Global Summit and PSConf Asia, all three organizing groups were looking at doing some sort of mini-events. Instead of three groups working independently of each other on three different virtual events (all of which would have the same audience), we decided to pool our resources and together produce a 24-hour live stream of the best PowerShell & DevOps content that we can find.

Ton of great sessions now can be found on **powershell.org** YouTube chanel also mine session! 📽

[Build, Test, Deploy – Software Distribution Using Intune](https://www.youtube.com/watch?v=VusAXYzhgXo)

# PSConfBook 3

The last spot where I've contributed was **The PowerShell Conference Book Volume 3**! 📚
What's **PSConfBook**?

> Multiple subject matter experts have teamed up to bring you the ultimate collection of PowerShell topics that are designed to be like a conference in a book. This book not only delivers top-notch content that rivals any book on the market, but all royalties are donated to the OnRamp scholarship program which bootstraps others into the industry.

Go ahead and grab [e-book](https://leanpub.com/psconfbook3/) or [hard copy](https://www.amazon.com/dp/B08MGR749H/ref=cm_sw_r_tw_dp_x_mAdQFbYW1DJN6).

# The journey continues

Wow a lot has happened!
I've gained ton of new experience in different fields.🤓
I hope that you and many others will find my project useful and also I'm waiting for you contributions!

See you in next! 😉 🧠
