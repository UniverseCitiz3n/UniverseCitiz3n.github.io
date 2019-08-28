---
title: Export CloudFlare zone configuration
categories:
    - CloudFlare
tags:
    - PowerShell
    - CloudFlare
    - API
---

# Why?

I needed to dump configuration of our DNS zones hosted in Cloudflare. As this is going to be repetitive task I wanted to automated it.
After a quick search I've found some PoSh modules to work with Cloudflare but it seems they're a bit outdated. Because I needed to dump all DNS entries of all zones I decided to use a their API directly.

# How

The main idea is to connect to [Cloudflare API](https://api.cloudflare.com) and query for all zones. For each zone prepare an object and with current settings and all DNS entries. Then, dump each zone into JSON file. This is stored in our GIT repo.

> Seems easy.

# Starting
- Step one - Cloudflare requires TLS 1.2 for API connection. This is set with this statement during script execution in case it's not default on the system we're running:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

- Step two - authenticate to Cloudflare API:

```powershell
$CloudFlareAPIToken = 'YOURTOKENGOESHERE'
$CloudFlareEmailAddress = 'YOUREMAIL AKA YOUR LOGIN'
 
$CloudFlareBaseUrl = 'https://api.cloudflare.com/client/v4/zones'
$CloudFlareHeaders = @{
    'X-Auth-Key' = $CloudFlareAPIToken
    'X-Auth-Email' = $CloudFlareEmailAddress
}
```
- Step three - list all zones and get their ID. This is a simple Invoke-RestMethod:
```powershell
Invoke-RestMethod  -URI "https://api.cloudflare.com/client/v4/zones/?match=all" -Method Get -Headers $CloudFlareHeaders
```
- Step four - list all dns entries for specific zone. Another simple Invoke-RestMethod:
```powershell
Invoke-RestMethod  -URI "https://api.cloudflare.com/client/v4/zones/ZONEID/dns_records?match=all" -Method Get -Headers $CloudFlareHeaders 
```

# Let's Roll

Let's combine it into something more useful. I've wrapped this into a function that accepts three parameters: API token, e-mail address/login and destination folder.
After successful authentication it will enumerate all zones and save their configuration into hashtable. Then using zone od it will enumerate all DNS entries and add it into hashtable under DNSentries. Then hashtable will be saved as JSON file (name of the file will be zone name).

{% gist 912c5441291cce2a46f21f63c6e263bc %}

# Summary
Thanks to this I can plug it into our CI, inject tokens (API, e-mail, folder) on the fly, get the configuration and afterwards commit to GIT. Without much of my attention! Now, even before we switch to full DNS as a Code (great article by Kieran Jacobsen [here](https://poshsecurity.com/blog/managing-dns-with-dnscontrol-cloudflare-dnsimple-github-vsts-key-vault-and-docker)) we can control if any changes were made to our configuration with ease!