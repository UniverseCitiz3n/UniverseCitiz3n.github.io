---
title: How to bypass Settings catalog limitation
categories:

    - Intune

tags:

    - Intune
    - MDM
    - MicrosoftEdge

excerpt: I needed to configure quite a long list of allowed urls but then I hit a wall

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Configuring Intune MDM polices sometimes is tricky.
Especially when you are migrating baseline Group Policies.
First of all, do not migrate everything AS IS 😣.
Take a look at the Microsoft Security Baseline, tweak it to your needs, apply it to some pilot group and then build-up.
But what about Settings catalog limitation?

# List of items

I want to configure `Allow cookies on specific sites` and with help of Settings catalog it seems fairly easy! 😎

![1]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2021-08-28-Edge/1.png)


Punkty:

* Service account in AD which has rights to create, rename computer objects in specified OU
* Organizational Unit which will store computer objects
* Connectivity to domain controller from Mac device

``` powershell

Write-Host 'This is a code'

```
See you in next! 😉 🧠

