---
title: Binding macOS device to Active Directory using Intune
categories:

    - Intune

tags:

    - Intune
    - Active Directory
    - macOS

excerpt: It looks like 🍏 can obey Microsoft 🔥

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Catchy title, isn't it? But be sure that it is possible to bind any macOS device to your local (for now) Active Directory using payload profile uploaded to ⚡Intune⚡. Those of you who connected Intune to Jamf might not find this post useful. But if you want to some costless solution you may proceed with reading 😉

# macServer

At the moment when some Mac devices started to appear at my company we decided to implement MDM solution. Back then I've tested Intune but it did not pass all of the requirements...macServer did provide all of the necessary features and it costs only $19.99!

Once you buy it just install it on management device, configure some stuff and you are ready enroll your devices. Customizing management profiles is piece of cake 🍰. Variety of options is astonishing!

![options]({{ site.url }}/assets/images/posts/intune-macos-1.jpg)

and many more!

So we did binding to AD using macServer. What is required:

* Service account in AD which has rights to create, rename computer objects in specified OU
* Organizational Unit which will store computer objects
* Connectivity to domain controller from Mac device

This is how it looks:

![bind1]({{ site.url }}/assets/images/posts/intune-macos-2.jpg)

and for administrative rights on device configure this tab:

![bind2]({{ site.url }}/assets/images/posts/intune-macos-3.jpg)

all set!

But this is not what you came for, right?

# Payload profile

Time came to look into Intune capabilities once again. At first glance I was disappointed but then I had an idea 💡! What are those custom profiles? I need to upload some file... Maybe something like this:

![profile]({{ site.url }}/assets/images/posts/intune-macos-4.jpg)

Bingo 🥳

So it looks like I can do everything what macServer allows just by downloading present configuration applied to end device 🤯.

Let's put it to the test and create custom profile which will bind device to Active Directory!

![profile2]({{ site.url }}/assets/images/posts/intune-macos-5.jpg)

This how this xml looks inside. I've made changes so that if you want to use it in you organization just copy it and fill the 'gaps'in keys:

* ADDomainAdminGroupList
* ADOrganizationalUnit
* ADPreferredDCServer
* Password
* PayloadDisplayName
* PayloadIdentifier
* UserName
* HostName
* PayloadOrganization

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>PayloadContent</key>
 <array>
  <dict>
   <key>ADAllowMultiDomainAuth</key>
   <true/>
   <key>ADAllowMultiDomainAuthFlag</key>
   <true/>
   <key>ADCreateMobileAccountAtLogin</key>
   <true/>
   <key>ADCreateMobileAccountAtLoginFlag</key>
   <true/>
   <key>ADDefaultUserShell</key>
   <string>/bin/bash</string>
   <key>ADDefaultUserShellFlag</key>
   <true/>
   <key>ADDomainAdminGroupList</key>
   <array>
    <string>yourdomain.com\RemoteAccess-macOS</string>
    <string>yourdomain.com\{`{serialnumber}}-Admins</string>
   </array>
   <key>ADDomainAdminGroupListFlag</key>
   <true/>
   <key>ADForceHomeLocal</key>
   <true/>
   <key>ADForceHomeLocalFlag</key>
   <true/>
   <key>ADMapGGIDAttributeFlag</key>
   <false/>
   <key>ADMapGIDAttributeFlag</key>
   <false/>
   <key>ADMapUIDAttributeFlag</key>
   <false/>
   <key>ADMountStyle</key>
   <string>smb</string>
   <key>ADNamespace</key>
   <string>domain</string>
   <key>ADNamespaceFlag</key>
   <true/>
   <key>ADOrganizationalUnit</key>
   <string>OU=Workstations,OU=Computers,DC=yourdomain,DC=com</string>
   <key>ADPacketEncrypt</key>
   <string>allow</string>
   <key>ADPacketEncryptFlag</key>
   <true/>
   <key>ADPacketSign</key>
   <string>allow</string>
   <key>ADPacketSignFlag</key>
   <true/>
   <key>ADPreferredDCServer</key>
   <string>yourdomain.com</string>
   <key>ADPreferredDCServerFlag</key>
   <true/>
   <key>ADRestrictDDNSFlag</key>
   <false/>
   <key>ADTrustChangePassIntervalDays</key>
   <integer>14</integer>
   <key>ADTrustChangePassIntervalDaysFlag</key>
   <true/>
   <key>ADUseWindowsUNCPath</key>
   <true/>
   <key>ADUseWindowsUNCPathFlag</key>
   <true/>
   <key>ADWarnUserBeforeCreatingMA</key>
   <false/>
   <key>ADWarnUserBeforeCreatingMAFlag</key>
   <true/>
   <key>ClientID</key>
   <string>%ComputerName%</string>
   <key>HostName</key>
   <string>yourdomain.com</string>
   <key>Password</key>
   <string>PASSWORD</string>
   <key>PayloadDisplayName</key>
   <string>Directory (yourdomain.com)</string>
   <key>PayloadEnabled</key>
   <true/>
   <key>PayloadIdentifier</key>
   <string>com.apple.mdm.yourdomain.com</string>
   <key>PayloadType</key>
   <string>com.apple.DirectoryService.managed</string>
   <key>PayloadUUID</key>
   <string>81d771a0-c8e2-0137-bbba-68fef702cbe7</string>
   <key>PayloadVersion</key>
   <integer>1</integer>
   <key>UserName</key>
   <string>USERNAME</string>
  </dict>
 </array>
 <key>PayloadDisplayName</key>
 <string>Settings for %ComputerName%</string>
 <key>PayloadEnabled</key>
 <true/>
 <key>PayloadIdentifier</key>
 <string>com.apple.mdm.yourdomain.com.6b79c2a0-c8e2-0137-bbb9-68fef702cbe7</string>
 <key>PayloadOrganization</key>
 <string>yourdomain.com</string>
 <key>PayloadRemovalDisallowed</key>
 <false/>
 <key>PayloadScope</key>
 <string>System</string>
 <key>PayloadType</key>
 <string>Configuration</string>
 <key>PayloadUUID</key>
 <string>6b79c2a0-c8e2-0137-bbb9-68fef702cbe7</string>
 <key>PayloadVersion</key>
 <integer>1</integer>
</dict>
</plist>
```

And as a result I got:

![ad]({{ site.url }}/assets/images/posts/intune-macos-6.png)

![ad1]({{ site.url }}/assets/images/posts/intune-macos-7.png)

![ad2]({{ site.url }}/assets/images/posts/intune-macos-8.png)

# Summary

$19.99 was very well spent money! Thanks to that I can prepare desired configuration on macServer, export it to xml file, upload it to Intune. At this moment I've not tested all of the options and how will they apply but I hope high hopes in this method.

Intune allows you to build dynamic strings in configurations - [Configuration Tokens](https://docs.microsoft.com/en-us/intune/apps/app-configuration-policies-use-ios#tokens-used-in-the-property-list).<br>
I've used one in device domain group for administrator privileges<br>
**yourdomain.com\{`{serialnumber}}-Admins**

See you in next! 😉 🧠
