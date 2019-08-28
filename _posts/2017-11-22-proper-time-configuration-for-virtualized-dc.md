---
title: Proper time configuration for Virtualized DC
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - Domain Controller
    - Time service
---

# Where's my time

![Emmet]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture1.jpg)

Simple things are sometimes the most tricky.

Once in a while there's a recurring question - how should you set up time in your domain, if all DCs are virtualized. Undying answer is 

> "have one physical box that acts as a primary DC".  

My "virtualize everything" nature opposes this. You can have all DCs virtualized in your environment - you just have to do it right. 

# How it works

I highly recommend these links if you're interested in this subject: 
- [How the Windows Time Works](https://docs.microsoft.com/en-gb/windows-server/identity/ad-ds/get-started/windows-time-service/how-the-windows-time-service-works)
- [Windows Time Configuration - It's simple](https://blogs.technet.microsoft.com/nepapfe/2013/03/01/its-simple-time-configuration-in-active-directory/)
- [Windows Server 2016 Accurate Time](https://docs.microsoft.com/en-gb/windows-server/identity/ad-ds/get-started/windows-time-service/accurate-time)

Just a quick re-cap. When an OS boots up it queries a `'source'` for current time. In case of physical box `'source'` will be system clock. Virtual machine though will ask hypervisor for the current time.

Then, after VM is completely up, in Active Directory environment it will use domain hierarchy (unless configured differently) to synchronize it's clock in regular intervals. 

# Root cause

What is the issue then? Imagine all your DCs are down, or under a heavy load or your Hyper-V host is under heavy load - it may cause time to shift a little bit. Then a VM with DC role starts and synchronizes time with Hyper-V host - changing it's time to inaccurate. Then, suddenly, all machines in your domain have wrong time and bad things happen: Kerberos tickets are out of sync making logins fail, internet services complain about your time, etc. 

To resolve this some advise to disable the Hyper-V integration component of Time Synchronization:

![Nono]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture2.png)

> **but that's not the best idea**. 

Why? Because VM does not have a battery to sustain current clock status when it is powered off. Then, when it starts or resumes its time is not correct. It is desired for a VM to get its time from Hyper-V host. Some people configure Hyper-V hosts as authoritative time source for whole domain, which is violating best practices in Active Directory domain environment. 

# Resolution

How should it be done then?
1. All Domain Controllers should be allowed to use Hyper-V integration components during startup,
2. and only during startup!
3. Domain Controller with FSMO (PDC Emulator) roles should synchronize time with external source,
4. All other Domain Controllers should synchronize from the PDC,
5. All machines should synchronize from any Domain Controller.

![AD]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture3.png)

# I've got not time, show me some code

1. First, let's make sure our DCs have Time synchronization enabled: 

![AD]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture4.png)

If not, we can easily fix that:

![AD]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture5.png)

2. Then add registry entry on all DCs that will stop VM (once booted) from using VM IntegrationComponent Time Provider:

{% gist f3641cdb2c642cf07e558ddf5445f98e %}

3. Configure PDC Emulator to use external source:

{% gist e7acae01be66fb326643b4604c395c2f %}

4. Configure all other DCs to use domain hierarchy:

{% gist 6d758a96d0759ecfcbd9caa4201ac783 %}

Once done you'll get information that your PDC Emulator is synchronizing with external source:

![AD]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture6.png)

And your other DCs will synchronize with your PDC:

![AD]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture7.png)

# And we're back on right time track!

![Emmet2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/time-dc-vm/picture8.jpg)

# Bonus

P.S. Did anyone noticed this little error message?

`"VM Integration Services status reports protocol version mismatch on pre-Windows 10 Version 1607 or Windows Server 2016 VM guests"` ([link](https://support.microsoft.com/en-ca/help/4014894/vm-integration-services-status-reports-protocol-version-mismatch-on-pr))

It just means that my VM is not Windows 2016 running on Windows 2016 Hyper-V Host.