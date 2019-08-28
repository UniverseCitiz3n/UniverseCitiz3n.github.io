---
title: Full CI/CD PowerShell Module for with Plaster
header:
    image: /assets/images/posts/powershell-module-with-plaster/picture1.png
categories:
    - PowerShell
tags:
    - PowerShell
    - CI CD
    - Plaster
---

# Old Friends

Long time ago (link) I've created a little helper function to ease creation of [PowerShell modules](https://arconnetblog.wordpress.com/2017/05/07/new-module-helper-function/). Since then I've learnt a lot of new stuff, but most importantly I've met [Plaster](https://github.com/PowerShell/Plaster). I've decided to revisit the idea of scaffolding a PowerShell module with Plaster. 

# New Friends

I'm using this template for some time now, but never found time to publish it. If You've been to our [Polish PowerShell User Group](https://www.meetup.com/Polish-PowerShell-Group-PPoSh/) [#10 Meetup](https://www.meetup.com/Polish-PowerShell-Group-PPoSh/events/247776635/), You could get a sneak peak of it being used in our CI/CD chain both for open source (AppVeyor and GitHub) and closed source (TeamCity in Objectivity).  We (with [Tomek Dabrowski](https://dombrosblog.wordpress.com/)) had the privilege to show that during PSConfEU 2018 ([YouTube](https://www.youtube.com/watch?v=4zLyKGJDW5I) and [slides](https://github.com/psconfeu/2018/tree/master/Mateusz%20Czerniawski/PPoShModule%20Story%20-%20Release%20Pipeline) ) as well.

# The Benefit

What is the benefit of using Plaster? Simplicity and repeatability when creating new modules. It can also be used to create functions and tests files based on another template (that is yet to be discovered by me :)) )
If you'd like to know more, these are the best sources to start from:
- Kevin Marquette - [Powershell: Adventures in Plaster](https://kevinmarquette.github.io/2017-05-12-Powershell-Plaster-adventures-in/) and [Powershell: GetPlastered, a Plaster template to create a Plaster template](https://kevinmarquette.github.io/2017-05-14-Powershell-Plaster-GetPlastered-template/)
- Mike F Robbins - [Using Plaster to create a PowerShell Script Module template](https://mikefrobbins.com/2018/02/15/using-plaster-to-create-a-powershell-script-module-template/) and [PowerShell Script Module Design: Plaster Template for Creating Modules](https://mikefrobbins.com/2018/08/30/powershell-script-module-design-plaster-template-for-creating-modules/)
- David Christian - [Working with Plaster (YouTube)](https://www.youtube.com/watch?v=16CYGTKH73U&feature=youtu.be) and [Working with Plaster (blog)](https://overpoweredshell.com/Working-with-Plaster/)

Our PPoShTemplate creates basic folder structure, script style rules for PSScriptAnalyzer and adds build scripts to support both local runs and with CI/CD (works well with TeamCity and AppVeyor). The bonus is that if you clone your repo's wiki it will regenerate it during local build run (details in our video from PSConfEU).

# How to Use it

This is VERY simple - just download/clone this repo [PlasterModuleTemplate](https://github.com/PPOSHGROUP/PlasterModuleTemplate) and Invoke-Plaster

{% gist 706aebc8c0eb3ee39c0655aadcac258f %}

This will trigger Plaster. After you answer some questions your new module will be created:

{% gist db91cf1f1c43848bfc760757350fb6db %}

# What's next

Currently we're preparing to add [Azure DevOps Services](https://azure.microsoft.com/en-us/services/devops/) (a.k.a VSTS) into the mix, so soon additional files in build directory will be added to support that.
