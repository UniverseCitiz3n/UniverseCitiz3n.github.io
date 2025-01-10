---
title: Built-in Local Administrator Mysteries
categories:
    - Windows
    - Security
    - System Administration

tags:
    - Windows
    - LocalAdmin
    - Intune
    - EntraID
    - PowerShell

excerpt: Explore the mysteries of the built-in Local Administrator account, its quirks, and best practices to secure your Windows devices.

comments: true
toc: true
toc_label: Table of Contents
---

## Introduction

The built-in Local Administrator account on Windows systems is a critical yet often misunderstood feature that plays a key role in system administration. It provides essential system management capabilities, yet its behavior and implications are frequently overlooked. This blog post aims to demystify the Local Administrator account, uncover its hidden quirks, and offer practical tips to manage it effectively.

---

## Background Context

Some time ago, there was an incident at one of my client sites. An IT Admin ran a PowerShell script invoking the MS Graph API to delete certain objects. All would have been fine if they had noticed that they hadn't switched to the test environment while using `Connect-MGGraph`. Unfortunately, the script removed several Intune objects in production. 😵

While mobile devices were impacted (though not too severely), the situation was far worse for Windows devices. These devices were Entra ID-joined.

### What Happens When You Remove an Intune Object from an Entra ID-Joined Device?

The `dsregcmd /leave` command runs locally on a device, it disconnects the device from Entra ID.

⚠️ **Only local accounts on the device will be able to sign in after a reboot!**

### The Incident

The devices had no local accounts available!

Windows LAPS wasn’t implemented (it is now), and no other break-glass accounts were created on the devices.

Attempts to enable the built-in admin account or create a new one from recovery CMD failed. Ultimately, the devices had to be reset.

---

## What Preventive Measures Can Be Implemented?

🛑 Check Your Connected Tenant

Always verify which tenant you are connected to before running scripts. `Connect-MGGraph` caches the auth token on your drive, so ensure you remove it to avoid mistakes:

```powershell
if (Test-Path "$env:USERPROFILE\.mg") {
    Remove-Item "$env:USERPROFILE\.mg" -Recurse -Force
}
```

🔧 **Use Least Privilege Access**

Use the least privileged access account for tasks. If you are running a script as a global admin, triple-check what you are about to execute!

💼 **Implement a Break-Glass Account**

You have two options:

1. Enable the built-in Local Administrator account.&#x20;
2. Create a new account and assign administrator privileges.

Windows LAPS works with both scenarios.

---

## Enabling the Built-in Administrator

There are several ways to enable the built-in administrator account:

- Intune profile
- Group Policy (GPO)
- Script

Each method has its pros and cons.

### Intune Configuration Profile Quirks

Using an Intune configuration profile to enable the Administrator account has limitations:

- Initial policy deployment works but won’t change the account state during sync if manually altered.

![2]({{ site.url }}/assets/images/posts/2025-01-10-Intune-Local-Admin/image2.png)

![1]({{ site.url }}/assets/images/posts/2025-01-10-Intune-Local-Admin/image1.png)

Each event was raised when new value was detected in configuration profile.

- Removing the profile reverts the Administrator account to a disabled state.

💡 **Key Issue:** If the device disconnects from Entra ID, it becomes unenrolled from Intune. All policies are removed, including those enabling the Administrator account, leaving the account disabled. 😱

### Enabling via Script

To overcome this issue, use a script to enable the Administrator account:

```powershell
$AdminSID = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-21-*-500" } | Select-Object -ExpandProperty SID

Enable-LocalUser -SID $AdminSID

$Password = ConvertTo-SecureString "YOUR_TEMP_PASSWORD" -AsPlainText -Force
Set-LocalUser -SID $AdminSID -Password $Password

Write-Output "Built-in local administrator account has been enabled."
```

This ensures you have a break-glass account available in case of an Entra ID disconnection.

Alternatively, you can create a new local account and assign administrator permissions to it. The choice depends on your environment, but having a break-glass local account on Entra ID-joined devices is crucial.

---

## Conclusion

The built-in Local Administrator account is both a blessing and a curse. While it offers essential system management capabilities, it also poses security risks if not handled properly. Understanding its quirks and implementing best practices can help secure your environment against potential threats.



**See you in the next post! 😉 🧠**