---
title: Binding macOS device to Active Directory using Intune
categories:

    - Intune

tags:

    - Intune
    - ActiveDirectory
    - macOS

excerpt: It looks like 🍏 can obey Microsoft 🔥

comments: true

---

# Intro

Catchy title, isn't it? But be sure that it is possible to bind any macOS device to your local (for now) Active Directory using payload profile uploaded to ⚡Intune⚡. Those of you who connected Intune to Jamf might not find this post useful. But if you want to some costless solution you may proceed with reading 😉

# macServer

At the moment when some Mac devices started to appear at my company we decided to implement MDM solution. Back then I've tested Intune but it did not pass all of the requirements...macServer did provide all of the necessary features and it costs only $19.99!

Once you buy it just install it on management device, configure some stuff and you are ready enroll your devices. Customizing management profiles is piece of cake 🍰. Variety of options is astonishing!

![options]({{ site.url }}{{ site.baseurl }}/assets/images/posts/intune-maos-1.jpg)

and many more!

So we did binding to AD using macServer. What is required:

* Service account in AD which has rights to create, rename computer objects in specified OU
* Organizational Unit which will store computer objects
* Connectivity to domain controller from Mac device

This is how it looks:

![bind1]({{ site.url }}{{ site.baseurl }}/assets/images/posts/intune-maos-2.jpg)

and for administrative rights on device configure this tab:

![bind2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/intune-maos-3.jpg)

all set!

But this is not what you came for, right?

# Payload profile

Time came to look into Intune capabilities once again. At first glance I was disappointed but then I had an idea 💡! What are those custom profiles? I need to upload some file... Maybe something like this:

![profile]({{ site.url }}{{ site.baseurl }}/assets/images/posts/intune-maos-4.jpg)

Bingo 🤯
