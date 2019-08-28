---
title: Deploy LAPS with PowerShell
categories:
    - LAPS
tags:
    - PowerShell
    - LAPS
    - Tutorial
toc: true
toc_label: Deploy LAPS
last_modified_at: 2019-01-22T23:00:00+01:00
---

# What is LAPS and why I need it

In windows domain based environments accounts with domain admin rights should be protected by all means. We all know that those accounts have the greatest privileges in the domain. There are other accounts that should be kept secure as well. Sean Metcalf has a [great article](https://adsecurity.org/?p=3700) about it. He is a Great Fountain of Knowledge about Active Directory!

But what many admins tend to forget is that domain based computers also have local accounts that can be used in attack or lateral movement. It isn't uncommon to have local Administrator account with the same password on many machines (think mass deployment from WDS, VM templates). Some change the default name of the Administrator account but that's not enough - it can be easily enumerated using SID ([Well-known security identifiers in Windows operating systems](https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems)).

Back in 2015 Microsoft has released LAPS - [Local Administrator Password Solution](https://technet.microsoft.com/en-us/mt227395.aspx). Jessica Payne has a great [blog post](https://blogs.technet.microsoft.com/askpfeplat/2015/12/28/local-administrator-password-solution-laps-implementation-hints-and-security-nerd-commentary-including-mini-threat-model/) describing what is LAPS and what it's not. I really recommend reading it very carefully. Also, there's a great TechNet article with more details [here](https://technet.microsoft.com/en-us/mt227395.aspx).

It's over two years since this is available for free for everyone. Yet I haven't seen this implemented anywhere. I've heard the tales, yet no proof. Recently I had to deploy a new domain. With this came the opportunity to automate the deployment of LAPS as well. I've created a small script that will help with the process. With it I can easily perform all steps - which is great even for building test environments.

# Preparation

Before we dive in I'd like to step through the necessary steps:

1. Prepare Active Directory
    - Extend AD scheme
    - Prepare OU for computers' objects with necessary permissions
    - Prepare delegation for designated groups of people to read the passwords
2. Deploy application to the endpoints (workstations and servers) - either through Software Deployment products (like SCCM) or through GPO. I will be using GPO.

Basically, LAPS is a Group Policy Client Side Extension (CSE) that sits on endpoints. Occasionally (this is configurable) it changes specified administrator account password and stores it in its Active Directory computer object property ms-Mcs-AdmPwd. This is an extended attribute so not everyone can read it.

## Get the LAPS files

This isn't rocket science - simple web search will point you to Microsoft site with LAPS installation files. But hey, remember we're automating? With these few lines, we can have all necessary files fetched for us. The last line will also install only management modules on the station we're running the code from.

{% gist 58ff763d9e8ed04dc5b180add01928d2 %}

## Prepare AD groups and FileShare

First, let's create all necessary groups. This means we will need:

- Two group that will have read and full access rights to a file share which will be used in GPO - based installations.
- Two groups with permissions to read password attribute from Active Directory - respectively for Workstations and Servers

{% gist 393d9207671290be7e49b1252d902e2f %}

Now, let's create a file share and copy all files to the remote location. Then let's clean up local temporary files:

{% gist 33b977421311684d7d65acea87f1a486 %}

## Extend

To extend AD scheme the account must be in "schema admins" group. Make sure you've got that sorted out before you proceed.

Every time you need to extend Active Directory you should have strong business need behind it. Remember to create AD backup and document the change. Then brace yourself for a very hard task. This time it's this hard:

{% gist 9b52ea8e1aff7694b1b95d4eb377ad7e %}

Phew, this wasn't hard at all ;)

## Check OU Permissions

What is the point of storing passwords to all machines in AD if everyone could read it? To make sure only required groups can read the extended attributes we run this code:

{% gist 448add24a5a675e4e19902d86cecea9f %}

The output should look similar to this:
![check permissions](/assets/images/posts/laps/picture1.png)

## Alter OU permissions

Now, we need to:

- grant computers the right to modify their own AD object with password property
- grant proper groups permissions to read these attributes

{% gist 61d0158e056099a8e71245844fed5468 %}

# Endpoint deployment

We're nearly done. The last step is to deploy LAPS to endpoints. As stated before I'll be using GPO. There are some caveats to have in mind with this type of deployment:

- Software installation will trigger only before user is logged in ([link](https://msdn.microsoft.com/en-us/library/bb742421.aspx))
- Therefore, it requires network access before user logging in
- Computer account is used to access network share to get installation files ([link](https://support.microsoft.com/en-us/help/278472/packages-assigned-to-computers-with-group-policy-are-not-installed))

As this is a small deployment I'm using single Group Policy Object to both install and configure LAPS. It could be easily split into two different parts though.

## LAPS configuration through GPO

To be able to configure LAPS through GP, we need to have the admx templates installed on the machine from where we will create a GPO. This was done when we first downloaded and installed the files. Create a GPO, link it to the OU where computer objects are stored, edit and navigate here: `Computer Configuration \ Policies \ Administrative Templates \ LAPS`. Basically, there are only a handful of options here which are self-explanatory. I'll be using Enable local admin password management . If you want to manage the passwords of different account than 'Administrator',  just enable and edit Name of administrator account to manage. As far as I know, you can only manage one account per computer object - because there's only one ms-Mcs-AdmPwd property for a computer object. Also, only one account name per GPO. If, for example, you have different default local administrator name for workstations and servers - you will require two Group Policy Objects to cover that.

## LAPS deployment through GPO

To install LAPS through GPO, I'll be using Software Installation options that can be found here: `Computer Configuration \ Policies \ Software Settings \ Software Installation`.

Remember that software installation will occur only during machine logon time and only if network is connected and share is available. If there will be issues with this, an event log like this will be recorded:

![EventLog error 1](/assets/images/posts/laps/picture2.png)
followed by

![EventLog error 2](/assets/images/posts/laps/picture3.png)

We can edit `Computer Configuration \ Policies \ Administrative Templates \ System \ Logon \ Always wait for the network at computer startup and logon` and forcing Windows to wait for network connectivity before processing any GPO, but that can extend logon time, especially when users often work remotely.
I use it for OUs where servers computer objects are stored.
Once the app is installed it requires some time before changing the password and propagating it to AD. The CSE only runs at Group Policy refresh cycles.

# Reading the password

Ok, we have everything set up and configured. Our workstations and servers are happily grabbing GPOs and installing LAPS. What's next? How to get the password? There are different ways to achieve that.

- We can simply use 'Active Directory Users and Computers' snap-in and then 'Attribute Editor' tab.

![Read Password ADUC](/assets/images/posts/laps/picture4.png)

- We can use the fat client - LAPS UI application that get installed with management tools.

![Read Password LAPS UI](/assets/images/posts/laps/picture5.png)

- We can also use PowerShell to retrieve the password using simple command

{% gist f02f24b03c472ff081e807d4b4d1051a %}

# LAPS auditing

In the next part I'll cover LAPS auditing. How to enable logging of security events who accessed which machine's password. If you're interested - please stay tuned.

# Summary

LAPS is not a silver bullet. It's not a magic pill that will fix everything. LAPS is designed to help in randomizing local administrator password in a domain environment. This is an important step that you can implement for free. This is a first step to a multilayered, complex defense strategy we should deploy to protect our network from adversaries.
