---
title: The Hidden Pitfall of Windows Autopilot - Avoiding Device Duplication
categories:

    - Intune

tags:

    - Intune
    - Autopilot
    - EntraID

excerpt: Discover a hidden challenge that could derail your Windows Autopilot deployments—duplicate device entries. Learn how to navigate this pitfall with expert tips on managing Entra ID objects to ensure a smooth and streamlined deployment process.

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Windows Autopilot deployments can occasionally face a challenging issue where a disabled Entra ID Autopilot device object can lead to unintended complications. This often-overlooked problem can result in mismatches in device management, potentially affecting the success of deployments.

# Issue Explanation and Discovery

Typically, when registering a device for Autopilot deployment, an Entra ID object is created to identify and manage the device throughout its deployment lifecycle. However, if this object becomes disabled, the system fails to reuse the disabled object and treats the device as new, leading to the creation of a duplicate object. This issue was uncovered when investigating why certain applications were missing from a newly set up device, as reported by a client. It turned out that the device was omitted from an essential Entra ID dynamic group due to not being recognized as the previously registered object.

The issue:

![iamge1]({{ site.url }}/assets/images/posts/2024-04-18-Intune-Autopilot-EntraID/image1.png)

Correct configuration:

![iamge2]({{ site.url }}/assets/images/posts/2024-04-18-Intune-Autopilot-EntraID/image2.png)

# The Solution and Proactive Measure

To prevent such issues, the best practice is to either re-enable any disabled Autopilot Entra ID device objects or, if the issue has already occurred, remove the device from the Autopilot service. Luckily, as of 2024, it is possible to remove a device from Autopilot without the need to also remove it from Intune. After removal, the device can then be reenrolled in Autopilot.

The easiest way to reenroll the device is to create and assign a deployment profile with 'Convert to Autopilot' enabled.

Furthermore, setting up a dynamic Entra ID group can help in automatically detecting such discrepancies. The recommended criteria for such a group are:

```
(device.devicePhysicalIDs -all (eq $null)) -and (device.deviceManagementAppid -contains "0000") and (device.deviceOwnership -eq "Company") and (device.enrollmentProfileName -eq "Autopilot Deployment Profile")
```

This configuration helps identify devices that have not been correctly registered, allowing for quick administrative action. Remember to change (device.enrollmentProfileName -eq "**Autopilot Deployment Profile**") to indicate you profile or profiles name.


# Summary

Efficient management of Autopilot device objects is pivotal to achieving seamless device deployments. By effectively addressing issues related to the reuse of Entra ID objects, you can mitigate complications and ensure comprehensive setups. It's vital to stay vigilant and implement proactive measures to maintain accurate device registrations.

See you in next! 😉 🧠