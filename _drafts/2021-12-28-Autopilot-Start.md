---
title: Autopilot pt. 1
categories:

    - Autopilot

tags:

    - Intune
    - Microsoft365

excerpt: Prepare your own sandbox  

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Hi there!
For some time I've been thinking about creating a few posts on starting your own **Windows Autopilot** small lab.
This lab is **Hyper-V** based so prepare your strongest hardware or dust off your servers and enjoy!

# Microsoft 365 tenant

Windows Autopilot is cloud solution which purpose is to bring devices into management state over the Internet.

This requires...🥁🥁...Microsoft 365 tenant with licenses!

THE BEST way to get your own POC/sandbox/place where you can break things is to request **Microsoft 365 Developer Program** 🙌

Simply, go [here](https://developer.microsoft.com/en-us/microsoft-365/dev-program) and fill-out the from!

You will get Microsoft 365 E5 instant sandbox with:

* 25 user licenses for development purposes
* Fully loaded sample data with 16 sample users, user data, and content to help you model your solutions.
* Easy access to pre-provisioned core Microsoft 365 workloads and capabilities (Windows not included), including:
    * All Office 365 apps
    * Everything you need for Power Platform development
    * Office 365 Advanced Threat Protection
    * Advanced analytics with Power BI
    * **Enterprise Mobility + Security (EMS) for compliance and information protection** 👈👈
    * Azure Active Directory for building advanced identity and access management solutions

All this and more for free!

Where is a catch? Such sandbox has renewable expiration period of 90 days.

![expr](https://cdn.graph.office.net/prod/media/office/dev-program/home/BAM_1_800x450.png?v={1/string})

How to renew it? You need to create some activity within environment.
From my experience it does not have to be anything complicated.
I had periods when I signed-in to tenant clicked through some stuff once in 3 months and it was sufficient 😁

![someimage]({{ site.url }}{{ site.baseurl }}/assets/images/posts/intune-macos-1.jpg)

Punkty:

* Service account in AD which has rights to create, rename computer objects in specified OU
* Organizational Unit which will store computer objects
* Connectivity to domain controller from Mac device

``` powershell

Write-Host 'This is a code'

```
See you in next! 😉 🧠

