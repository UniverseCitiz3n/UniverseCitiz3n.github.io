---
title: Install statusfy and run with Azure DevOps
categories:
    - Azure
tags:
    - PowerShell
    - Azure DevOps
    - Statusfy
    - WSL
---

# What is statusfy

> [Statusfy](https://statusfy.co/) is a Status Page System, easy to use and completely Open Source. You can easily create a fast System either Static Generated or Server Rendered and easily deploy it to a variety of hosting services.

I've decided to give it a go as our internal Status Page. Internal means it should be available only to our employees. Also, it should be available in case of internal resource fail (like compute, power or internet).

# The Architecture

I didn't want to use any paid solutions like [StatusPage](https://www.statuspage.io/), [Status](https://status.io/) or Atlassian [StatusPage](https://www.atlassian.com/software/statuspage). Those are all public sites. 

As this blog is run by `github pages` and `markdown` and I'm just loving it, I wanted to try something similar. 

The idea was to use Azure DevOps to run this. Repo, CI/CD, Blob Storage and NSG rules to firewall the traffic - all in one place.

These blogs:
- [Static Sites with Azure Blob Storage, CI/CD and Jekyll](https://www.rayheffer.com/static-sites-with-azure-blob-storage-ci-cd-and-jekyll/) by `Ray Heffer` 
- and [Nearly Free Blog CICD](https://cloudconfusion.co.uk/azure/Nearly-Free-Blog-CICD/) by `Gabriel McColl`

# Let's begin

First, I wanted to see it localy. As I'm using Windows 10 as my main machine I decided to go with Windows Subsystem for Linux
were very helpfull with this task.





```
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
```