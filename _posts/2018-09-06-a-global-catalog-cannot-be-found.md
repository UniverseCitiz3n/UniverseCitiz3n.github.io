---
title: SBS 2008 A global Catalog cannot be found
categories:
    - Windows Server
tags:
    - Windows SBS 2008
excerpt: Domain Controller not available on SBS 2003 single DC environment
---

# When disaster strikes…

So, one of my customers have this old server SBS 2008 (`Windows 2008 NOT R2`). We will be migrating them to O365 in.. 1 week. It was scheduled since June. By the way - this was my SECOND server I installed in production. Over 10 years ago! 

What happened? Power outage today morning AND UPS having issues with battery. Replacement battery on the way (though it's an old UPS so the delivery takes a few days). Server crashed. 
> `SYSVOL` and `NETLOGON` shares missing. No Global Catalog. No server holding FSMO roles. 

Users seeing network connections as private (not domain). The only server (PDC by the way) seeing its network as private as well. Active Directory not working. Exchange not working. Applications that rely on domain authentication - not working. 

![KaBoom]({{ site.url }}{{ site.baseurl }}/assets/images/posts/a-global-catalog/picture1.jpg)

Because this is 2008, the only backup I have is Windows Backup. Restoring system state requires booting from OS DVD (anyone still have Windows 2008 SBS DVD #1? I do!) What's more I was offsite and I couldn't perform restore from backup immediately. 

Fortunately backup did work - last night at 9.00 PM. So in the meantime of trying to fix this I was preparing one of my Hyper-V labs (another story to be told - StorageSpaces rocks!) and a VM to perform restore from backup - once I'll deliver the box to the client. 

# … keep your nerves at bay!

It took some time, but I've managed to recover the server remotely without failing back to backup.

Let me just recap what was wrong and how I fixed this (I hope I WON'T NEED THIS ANYMORE!) 

I can tell you this - DCDIAG is your friend!

1. DCDiag shows there's no GlobalCatalog (0x800034FE)
2. Active Directory not working so let's try this one: `nltest /sc_change_pwd:contoso.local`

Hurray, the Users and Computers snap in started working!
3. Network still Private!
4. Looking at FSMO roles? Server doesn't have them. THIS IS THE ONLY DC in the domain. 
	Transfer FSMO roles using ntdsutil (GUI didn't work) ([link](https://support.microsoft.com/en-us/help/255504/using-ntdsutil-exe-to-transfer-or-seize-fsmo-roles-to-a-domain-control))
5. Reboot but still no go. Dcdiag shows a little bit less errors, Now it finds GC but no SYSVOL and NETLOGON shares.
6. SYSVOL and NETLOGON folders exists on the server so I try with authoritative restore
	- Start CMD as Administrator and type `net stop ntfrs`
	- Open regedit and navigate to: `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\NtFrs\Parameters\Backup/Restore\Process at Startup`
		- Edit the BurFlags property and type D4
		- Quit registry
		- In CMD type: `net start ntfrs`
7. This performs authoritative restore based on files in `"%systemroot%\windows\sysvol\domainName"`
8. After a short time SYSVOL and NETLOGON shares were back (check with net share)
9. Server back in domain network. HURRAY!
10. Control reboot - everything is working - AD, DNS, Exchange, etc.!

# All ended well and good

The server is up and running. All this while helping my brother-in-law wife fix her laptop (endless bluescreen loops) due to faulty hardrive. Veeam to the rescue! (and gparted to fit 1TB hdd into 250GB SSD :smile: ) and taking care of two kids (Home Office)! 
Talk about multi-tasking?! 

> Exhausting! 

	
