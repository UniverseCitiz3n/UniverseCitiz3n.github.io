---
title: Get Expired Certs
categories:
    - Certificate
tags:
    - PowerShell
    - Certificates
---

# Get the One!

One of our certs was going to expire. I was tasked with a simple thing - get all servers where the cert is used/imported and list them. That's fairly simple task:

{% gist 0c93c9e0cab1c629c6785e4def0517d3 %}

This will give me a list with all computer names where the cert is imported. The only assumption - I'm looking into Windows' `Personal Store`, any non-Windows imported cert will be left in the dark.

# 'EVERYONE'

I thought I'll get all expired certs from the servers and export them into a list:

{% gist bc9801b831c9f3eea1cdbf5a9d642129 %}

![Everyone](/assets/images/posts/expired-certs/picture1.jpg)