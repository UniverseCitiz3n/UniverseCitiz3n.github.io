---
title: Create credential object with LAPS
categories:
    - LAPS
tags:
    - PowerShell
    - LAPS
---

# Why

In all environments that I manage I have deployed LAPS. I've already covered what is LAPS and how to deploy it with ease [here](https://www.mczerniawski.pl/laps/powershell/tutorial/deploy-laps-with-powershell).

Now, when I need to connect to remote machines I don't need to assign my regular or admin account local administrator privileges. I can just use LAPS. Why? If my account has no direct access or privileges on other machines it can't be easily exploited (think malware, ransomware). This does not protect you in all cases (determined, skilled adversary) but surely adds another layer of protection in your environment.

![LAPS](/assets/images/posts/laps-credential/picture1.png)

# How
The idea to use that in daily tasks is simple:
- Assign permissions to query AD for computer password to my admin account
- Use that account to retrieve password for specific machine
- Create credential object and use it to connect to remote machine.

Fairly simple tasks which is repeatable. A great opportunity to create a function for it.
The working code looks something like this:

{% gist ab34d20b30668981f06e1b86759950cb %}

Let's put it into function for better use:

{% gist 2f8ed02152e3a9be178445e26f11cace %}

Now it's a matter of:

{% gist 9f4685986d8631ca34bd04540905d15d %}

> Clean and easy!

![LAPS](/assets/images/posts/laps-credential/picture2.jpg)

P.S.
If you'd like to get a list of all computers that already have passwords (and you have permissions to read them), then this might help:

{% gist dfd440855a7389e16b292a3eedf29efd %}
