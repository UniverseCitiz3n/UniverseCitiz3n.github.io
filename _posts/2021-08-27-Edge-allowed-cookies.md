---
title: How to bypass Settings catalog limitation
categories:

    - Intune

tags:

    - Intune
    - MDM
    - MicrosoftEdge

excerpt: I needed to configure quite a long list of allowed urls but then I hit a wall

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Configuring Intune MDM polices sometimes is tricky.
Especially when you are migrating baseline Group Policies.
First of all, do not migrate everything AS IS 😣.
Take a look at the Microsoft Security Baseline, tweak it to your needs, apply it to some pilot group and then build-up.

But what's about Settings catalog limitation?

# List of items

I want to configure `Allow cookies on specific sites` and with help of Settings catalog it seems fairly easy! 😎

![1]({{ site.url }}/assets/images/posts/2021-08-28-Edge/1.png)

![2]({{ site.url }}/assets/images/posts/2021-08-28-Edge/2.png)

![3]({{ site.url }}/assets/images/posts/2021-08-28-Edge/3.png)

There you can enter desired sites or import whole bunch of them.
In my case I'm going to import over 100 dummy sites 😏.

![4]({{ site.url }}/assets/images/posts/2021-08-28-Edge/4.png)

Click Next, assign, create!

Wait what!? 🤨

![5]({{ site.url }}/assets/images/posts/2021-08-28-Edge/5.png)

As you may guess now I know what's the issue but it was not so obvious from the start...
There is a limit of 100 items on that list...

Alright let's create one policy with 100 and then another policy with the rest! 💡

Nope...as soon as policies are digested by the device it reports with `Conflict` status!

What now? 🤔

# Custom policy

It must be possible to implement such long and probably even longer list!
I've started to search for OMA-Uri for that setting.
And found it - `./Vendor/MSFT/Policy/Config/microsoft_edge~Policy~microsoft_edge~ContentSettings/CookiesAllowedForUrls`

Now for creating custom policy

![6]({{ site.url }}/assets/images/posts/2021-08-28-Edge/6.png)

Enter desired name for policy and continue

![7]({{ site.url }}/assets/images/posts/2021-08-28-Edge/7.png)

Now what should I do with `Value` ??

I've created policy with a few urls using `Settings catalog` and applied them to the device.
Then I took a look at the events from DeviceManagement-Enterprise-Diagnostics-Provider and found out that `value` should look like

```html
<enabled/><data id="CookiesAllowedForUrlsDesc" value="1 [*.]cemLT.pl 2 [*.]asdrW.pl"/>
```

Not bad.

But!

This separation between number, link and another item is not SPACE BAR ❗❗
It is special character encoded as `&#xF000;`, and with that it all should be `glued`

```html
<enabled/><data id="CookiesAllowedForUrlsDesc" value="1&#xF000;[*.]cemLT.pl&#xF000;2&#xF000;[*.]asdrW.pl"/>
```

Knowing that, finally I can create my policy with 100 and more items!

# Dummy items

For my dev environment I've created this teeny-tiny script to generate some dummy urls for this policy:

```powershell
$String = for($i=1;$i-lt 104;$i++){
 "$i&#xF000;[*.]$(-join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})).pl&#xF000;"
}
$String -join ''
```

# Summary

I hope that I've helped you with this tip!
You won't find any information in MS Docs about such limitation...

See you in next! 😉 🧠
