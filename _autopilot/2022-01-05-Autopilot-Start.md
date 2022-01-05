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
I had periods of time when I signed-in to tenant clicked through some stuff once in 3 months and it was sufficient 😁

# Windows and Office 365 deployment lab kit

Second part of your sandbox is **Hyper-v** lab.
The labs in the kit cover using Microsoft Endpoint Configuration Manager, Desktop Analytics (which is now deprecated), the Office Customization Tool, OneDrive, Windows Autopilot, and more.

What you get in the kit:

* Windows 10/11 Enterprise
* Windows 7 Enterprise
* Microsoft Endpoint Configuration Manager, Version 2107
* Windows Assessment and Deployment Kit for Windows 11/10
* Microsoft Deployment Toolkit
* Microsoft BitLocker Administration and Monitoring
* Windows Server 2022/2019
* Microsoft SQL Server

This environment has 90 days evaluation period and more or less after that time Microsoft releases updated version of the kit.

To get your own setup go [here](https://docs.microsoft.com/en-us/microsoft-365/enterprise/modern-desktop-deployment-and-management-lab).

# Summary

Now you have all the tools to create, test, break and learn!

Checkout next part of this series to see how to slightly improve your lab.

See you in next! 😉 🧠

