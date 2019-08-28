---
title: From SBS2008 to Office 365 and Windows 2019
categories:
    - Office365
tags:
    - Windows 2019
    - Office 365
excerpt: Migrate old SBS 2008 workload to Windows 2019 and Office 365
---

# Let me tell you a story...

Once upon a time there was a junior admin with a lot of hopes, willingness to learn and full of joy. He did go on an adventure into Windows world. One path he took lead him to a kingdom called SBS. There were 2000 and 3 castles in that land. He was stubborn, he was fierce and fearless. He did conquer that land. And it prospered for years later. Like a few others in his further journeys. 

![CastleCzocha]({{ site.url }}{{ site.baseurl }}/assets/images/posts/sbs2008-to-windows-2019/picture1.jpg)

This tale is about a similar kingdom, build upon Windows SBS 2008. At that time (2009/2010 years) this was a very good offer for small businesses. In this case we're talking about 10+ users. One physical box with Windows 2008 (not R2!), AD, DNS and DHCP and shares with GPO management. Exchange 2007, WSUS, some Sharepoint functionality and secure RDP through RDP Gateway. Add some SQL Express (2008) to the mix for some finance and LOB apps and Windows Backup to a NAS device. Throw in some Mikrotik devices on the edge and this cocktail was worth its price. In fact, it was working quite good even with Windows 10. It wasn't speed monster but we're talking about 10ish users working mainly on their laptops/desktops. And with proper maintenance everything run smooth. Till last Friday. Not because something crashed - nono. It was just high time to move to a more modern solution. With users familiar with Microsoft offering the choice was rather easy: Office 365 + Windows 2019 for local AD, LOB apps and shares.

# The design

After establishing what features users use the most on a daily basis, what are business owners' requirements, budget and possibilities I've ended up with a design like this:

![Design]({{ site.url }}{{ site.baseurl }}/assets/images/posts/sbs2008-to-windows-2019/picture2.png) 

1. There's the main Hyper-V server 2019 with StorageSpaces and two VMs (Windows Standard licensing):
	- (PDC) Domain Controller running DHCP server and also AAD Connect to sync to AzureAD
	- (APP1) Application server with shares (50GB) and SQL Express 
2. All that is backed up using Veeam to a NAS to an SMB share through alternate credentials. This protects for any cryptolocker attack - creds are stored in Veeam application, not Windows. Even in case of all local drives being encrypted - SMB share stays untouched!
3. VPN (L2TP/IPSec) connection is terminated on a Mikrotik router (CRS125-24G-1S-2HnD)
4. Management desktop with:
	- Windows Admin Center
	- RSAT
	- PowerShell scripts I need in this environment
	- This is my jump-host (through VPN) from which I access all other resources within network
5. Workstations - all Windows 10 1809

Baseline configuration for the environment looks like this:
1. On-Premises Active Directory:
	- Single DC, DNS, DHCP roles
	- AAD Connect with:
		- Password hash sync (no dependency on on-premises environment to access cloud resources)
		- Password writeback
		- Device write-back
		- Hybrid Azure AD Join
		- Single sign-on
	- AD configuration: ![ADConfig]({{ site.url }}{{ site.baseurl }}/assets/images/posts/sbs2008-to-windows-2019/picture3.png) 

    - AAD Connect syncs only specific OUs:
		- Computers, 
		- DomainControllers,
		- RegisteredDevices,
		- COMPANY OU except of SpecialAccounts ![AADConnect]({{ site.url }}{{ site.baseurl }}/assets/images/posts/sbs2008-to-windows-2019/picture4.png) 
        
    - GPO configuration ![GPO]({{ site.url }}{{ site.baseurl }}/assets/images/posts/sbs2008-to-windows-2019/picture5.png) 

2. Shares
	- Using DFS, so all shares are visible as `\\Company\Shares\ShareName` no matter where they are in fact.
	- All managed through AD groups for ReadOnly and FullAccess.
	- Mapped through GPO based on AD group membership
3. Office 365 tenant
	- Users synced from AD, proper license assigned. If P1 license is available within tenant, this is also managed through on-premises AD groups (hence Security Groups\Licenses OU).
	- Shared Mailboxes and Contacts created only in Office 365.
4. Workstation configuration:
	- ActiveDirectory accounts in use
	- LAPS enabled
	- All devices are using Bitlocker
	- Windows Hello for Business configured
	- Outlook connected to Office 365 Exchange Online
	- Known Folder Location enabled backing up all user files to OneDrive (no more - I had a file on my desktop and it's lost....)
	- Software managed through chocolatey
	- Local admins managed through AD groups. Each workstation has a corresponding AD group called NAME-Admins. This way I can easily add/remove local admins if needed. On regular basis users DO NOT have admin rights. For management purpose I use local Administrator account (LAPS password retrieval automated through PowerShell). BUT in case someone needs temporary rights added (you know those pesky legacy apps right?) this is how I do it. It's easier to track later!
5. Server configuration:
	- No user can RDP to any server!
	- If SQL is in use, access to DBs is also managed thru AD groups
	- LAPS enabled

# The Migration!

Most of this is already automated and the process is quite straightforward. In general it looks likes this:

1. Hyper-V host, vanilla VMs, domain creation, App server deployment through PowerShell
2. User migration automated (anybody mentioned PowerShell?:) : 
	- Extracting users from old domain into CSV with all attributes required 
	- Extracting users' group membership into CSV
	- Creation of users  based on CSV file
	- Creation of groups based on CSV file
	- Setting group membership
3. AADConnect installation and some on-premises configuration (like device writeback)
4. Based on JSON proper records are created in CloudFlare and integrated AD DNS
5. SQL installation through PowerShell
6. Windows 10 configuration after vanilla deployment through PowerShell scripts (both OS config and chocolatey). In larger deployments I use temporary WDS server. In this case - 10 PCs - it wasn't worth the hassle.

At the end I'm documenting the environment using my OVF modules for AD/DHCP/DNS/HyperV and Cloudflare ([PS Conf EU 2018](https://www.youtube.com/watch?v=SoBFCEiIps8)) - more about this coming soon!

Now, how the workstation migration process looks like?
1. Backup whole PC using Veeam Free Agent to an external HDD- just in case!
2. Export user's hint list from outlook to contacts (yea, some are using that as an address book!)
3. Export user's mailbox to PST file
4. Copy user files (Documents, Desktop) and PST to another external HDD - be double sure, also used for import later.
5. Vanilla Windows 10 installation with further customization
6. Reboot and GPO kicks in
7. Configure Outlook/OneDrive and copy user files back. Import PST into Outlook - sync begins.

> Each workstation has its own checklist in OneNote or printed:

![CheckList]({{ site.url }}{{ site.baseurl }}/assets/images/posts/sbs2008-to-windows-2019/picture6.png) 

Believe me that after a few hours and few workstations things start to blurry and get messy. This HELPS a lot. And remember we're not talking about Enterprise environment. We're talking about small shop with legacy apps, user habits from past 10 years! 

# Bottom line!

This migration took me about 24h from start to finish - one man job. That means double backup of each workstation (just in case), disconnect current domain, connect new domain (same IP subnet!!!), sync do AzureAD, reimage all workstations, restore data (in total ~100GB of mailboxes, ~100GB of personal files) , migrate SQL DBs (~40GB) , migrate shares (~50GB), double check everything, take care of those old pesky legacy LoB apps that just don't want to migrate properly. Then additional 4h of "health care" for users on Monday - training time, explanations etc.
After last scheduled migrations (of other companies) I hopefully will find some time to share all the PowerShell goodies I'm using! In the meantime more goodies are coming!