---
title: Have a cake and eat it too
categories:

    - Intune

tags:

    - Intune
    - Workstations
    - Endpoint
    - Security

excerpt: Bluetooth restrictions done right 🐱‍👤

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Let's say you wish to restrict users from sending files via bluetooth 📡 but without disable bluetooth itself, also allowing to use headset 🎧.
You can archive it using wide variety of tools but here you shall learn how to do it using Intune!

# Attack surface reduction

Even using Intune you can apply restrictions through two different blades.
Thou you can do it through **Devices->Windows->Configuration Profiles** you should start to get used to using **Endpoint Security** tab 'cause #MEMTeam is heavily investing into that area.

To create bluetooth (and more) restrictions policies go to MEM console =

![bt1]({{ site.url }}/assets/images/posts/2021-05-12/bt1.png)

Enter name and description for your policy

![bt2]({{ site.url }}/assets/images/posts/2021-05-12/bt2.png)

Scroll down to the bluetooth settings.
At first sigh there are 5 switches to toy with but at the very end you can see `Bluetooth allowed services`.
That's where the magic ✨ happens!

![bt3]({{ site.url }}/assets/images/posts/2021-05-12/bt3.png)

On that list you specify UUIDs of allowed bluetooth protocol services.
These UUIDs all use the same base UUID with the profile identifiers added to the beginning of the base UUID.
For example

```
Hands Free Profile UUID = base UUID + 0x111E to the beginning = 0000111E-0000-1000-8000-00805F9B34FB
```

To discover all services please refer to [service discovery](https://www.bluetooth.com/specifications/assigned-numbers/service-discovery).

Your list allowing to use headsets with microphones, mice and keyboard will look like:

```
00001108-0000-1000-8000-00805F9B34FB
0000110B-0000-1000-8000-00805F9B34FB
0000110E-0000-1000-8000-00805F9B34FB
0000110F-0000-1000-8000-00805F9B34FB
0000110c-0000-1000-8000-00805f9b34fb
00001112-0000-1000-8000-00805f9b34fb
0000111E-0000-1000-8000-00805F9B34FB
0000111f-0000-1000-8000-00805f9b34fb
00001124-0000-1000-8000-00805F9B34FB
00001131-0000-1000-8000-00805F9B34FB
00001200-0000-1000-8000-00805F9B34FB
00001203-0000-1000-8000-00805F9B34FB
00001800-0000-1000-8000-00805F9B34FB
00001801-0000-1000-8000-00805F9B34FB
0000180A-0000-1000-8000-00805F9B34FB
00001812-0000-1000-8000-00805F9B34FB
00001813-0000-1000-8000-00805F9B34FB
```

It contains all services UUIDs related to voice & music and keyboards and mice.
Save that list as an .csv file and click **Import**.

![bt4]({{ site.url }}/assets/images/posts/2021-05-12/bt4.png)

![bt5]({{ site.url }}/assets/images/posts/2021-05-12/bt5.png)

Now you can apply policy to your test machine and see if it works 😉.

# Find more UUIDs

When restriction such as above is applied there is always slight chance that you missed something or there are thing that you were not aware of!

To find devices that are blocked by policy you can simply open `Device manager` on the device and search for items with ⚠ next to the icon.
When you go into details you might see something like:

![bt6]({{ site.url }}/assets/images/posts/2021-05-12/bt6.png)

Then go to details and search for service UUID. Seems like a few steps...
Worry not, `PowerShell` will help you with fetching required data.
Just run:

```powershell
$Devices = Get-PnpDevice | where {$psitem.status -eq 'Error'} | sort friendlyname
```

And you will get immediately full list of the devices.
On that list you are interested in property **InstanceId**.

![bt7]({{ site.url }}/assets/images/posts/2021-05-12/bt7.png)

That ID contains bluetooth service UUID which can be added to Intune policy which will lead to resolving issue with this device.

# Summary

Such approach to handling bluetooth restrictions looks to me to be very clever.

Having possibility to use unique identifiers to tweak policies (and don't bother is it ABC3000 or XYZ9000) makes life easier!

Thanks IEEE 802.15 and Microsoft

See you in next! 😉 🧠
