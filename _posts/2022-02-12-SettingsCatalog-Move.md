---
title: How to easily move Settings Catalog profile
categories:

    - Powershell

tags:

    - Intune
    - Powershell
    - MicrosoftEdge

excerpt: With this simple trick, you can save a lot of time 😁

comments: true
toc: true
toc_label: Table of contents
---

# Intro

As the saying goes...do not develop/test on production...so we (IT Pros) work on some kind of sandbox environment.
This comes with **pros** and **cons** but that is not what I particularly want to focus on (though it is kind of connected with cons).

Let me show you how I've leveraged a neat trick that I've learned during one of the Ignite sessions last year! ❤️‍🔥

# Edge DevTools

You may know or not but **Microsoft Endpoint Manager admin center** is heavily dependent on Graph API calls!
When you go to any section, open configuration profile, create new one, wipe device, export report or whatever you name it, underneath you are calling Microsoft Graph API call.

For me it is awesome because I do not need to go to Microsoft Docs to search what Graph Uri I need to do X or Y.
I just need to open **Edge DevTools** and make an action through admin center portal.

To open **DevTools** just press `F12` or `CTRL + SHIFT + I` on your keyboard.
Then go to **Network**

![DevTools]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/1.png)

There you will be able to see traffic that comes and goes but that is not all! 🤔

![DevTools2]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/2.png)

At the beginning it might be all gibberish

![DevTools3]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/3.png)

But use `Filter` bar and all becomes much better

![DevTools4]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/4.png)

Now that we have only request that have some value for us let's pick first one and see what it does.
When you go to request details you can see exact Graph API URL that was sent to get the data for a blade.

![DevTools5]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/5.png)

After you determine which request is the one that you are interested in now it is time for promised trick!!!

`Right click` on request and navigate to `Copy` and there you have it: `Copy as PowerShell` 🚀

![DevTools6]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/6.png)

# PowerShell Request

From now on you are a Intune Microsoft Graph Master 😁

Let's see what hides in copied code...

```powershell
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Safari/537.36 Edg/98.0.1108.50"
Invoke-WebRequest -UseBasicParsing -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('0d15031a-fd95-4202-a43d-da63117070b8')" `
-WebSession $session `
-Headers @{
"x-ms-client-session-id"="97b2957ca94944f1bf9b5990939c04b0"
  "X-Content-Type-Options"="nosniff"
  "Accept-Language"="en"
  "Authorization"="Bearer eyJ0eXAiOiJKV1QiLCJub25jZSI6Im5idkVmeXd2RExnSjJaMG9BdlRna0xMTmFvREZYdHJHSlRLUEZ1cEdEZ00iLCJhbGciOiJSUzI1NiIsIng1dCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20vIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYTUxZDgyNzYtYThjYS00NmEyLTg3NjUtYjE2ZjJmN2U1ZTZhLyIsImlhdCI6MTY0NDY3NjYzMiwibmJmIjoxNjQ0Njc2NjMyLCJleHAiOjE2NDQ2ODE5MzYsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJFMlpnWUJEWWVlYTZXdGlWN01mQ241ZHNXTFNpWlZQeE9nUHVob1ZjQVF6K01UL1pBK0lCIiwiYW1yIjpbInB3ZCJdLCJhcHBfZGlzcGxheW5hbWUiOiJNaWNyb3NvZnQgSW50dW5lIHBvcnRhbCBleHRlbnNpb24iLCJhcHBpZCI6IjU5MjZmYzhlLTMwNGUtNGY1OS04YmVkLTU4Y2E5N2NjMzlhNCIsImFwcGlkYWNyIjoiMiIsImNvbnRyb2xzIjpbImNhX2VuZiJdLCJmYW1pbHlfbmFtZSI6IkhvcmJhY3oiLCJnaXZlbl9uYW1lIjoiTWFjaWVqIiwiaWR0eXAiOiJ1c2VyIiwiaXBhZGRyIjoiODkuNjQuMTE5LjIxNCIsIm5hbWUiOiJNYWNpZWogSG9yYmFjeiIsIm9pZCI6ImNmMWYwNTI1LWQzMjYtNDVmMy1iYTBlLWZkMDhkYjA3OTM0ZSIsInBsYXRmIjoiMyIsInB1aWQiOiIxMDAzMjAwMDk2M0IwMzQ0IiwicmgiOiIwLkFVY0Fkb0lkcGNxb29rYUhaYkZ2TDM1ZWFnTUFBQUFBQUFBQXdBQUFBQUFBQUFCSEFMMC4iLCJzY3AiOiJDbG91ZFBDLlJlYWQuQWxsIENsb3VkUEMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50QXBwcy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRDb25maWd1cmF0aW9uLlJlYWRXcml0ZS5BbGwgRGV2aWNlTWFuYWdlbWVudE1hbmFnZWREZXZpY2VzLlByaXZpbGVnZWRPcGVyYXRpb25zLkFsbCBEZXZpY2VNYW5hZ2VtZW50TWFuYWdlZERldmljZXMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50UkJBQy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRTZXJ2aWNlQ29uZmlndXJhdGlvbi5SZWFkV3JpdGUuQWxsIERpcmVjdG9yeS5BY2Nlc3NBc1VzZXIuQWxsIGVtYWlsIG9wZW5pZCBwcm9maWxlIFNpdGVzLlJlYWQuQWxsIiwic3ViIjoiNkw5Q1hJeTRsckJPMGZ3RGVIaldCMDZUOGtLOXVBT3c2UnhLS0VYLTN0OCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJFVSIsInRpZCI6ImE1MWQ4Mjc2LWE4Y2EtNDZhMi04NzY1LWIxNmYyZjdlNWU2YSIsInVuaXF1ZV9uYW1lIjoibWFjaWVqaG9yYmFjekBkdW5lc2JveC5vbm1pY3Jvc29mdC5jb20iLCJ1cG4iOiJtYWNpZWpob3JiYWN6QGR1bmVzYm94Lm9ubWljcm9zb2Z0LmNvbSIsInV0aSI6ImllckFtVU9WMlVHQUd0c1RwdllQQUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbImUzOTczYmRmLTQ5ODctNDlhZS04MzdhLWJhOGUyMzFjNzI4NiIsIjYyZTkwMzk0LTY5ZjUtNDIzNy05MTkwLTAxMjE3NzE0NWUxMCIsImU4NjExYWI4LWMxODktNDZlOC05NGUxLTYwMjEzYWIxZjgxNCIsImIwZjU0NjYxLTJkNzQtNGM1MC1hZmEzLTFlYzgwM2YxMmVmZSIsIjE5NGFlNGNiLWIxMjYtNDBiMi1iZDViLTYwOTFiMzgwOTc3ZCIsImI3OWZiZjRkLTNlZjktNDY4OS04MTQzLTc2YjE5NGU4NTUwOSJdLCJ4bXNfc3QiOnsic3ViIjoialU1SWVqSGU5MVpjcDlKdHZLNXV3aWJBN0d5SHZfRjUyMzJqa1dZdUFWYyJ9LCJ4bXNfdGNkdCI6MTU3OTI5NzMxNH0.SuWFMS0iGwVZkM_R1zdRMxOIE3N5Mjf2CQOom_0NHh3yKyS_Gl5FxFeeKcsBS8qkWdI7ybBONOLuoebGlLX69PyjTRnlqob8vHSe3h6DiSMwvMAuTE3GQ0yYMM-EMfN96gHIaDargVjknWb48k7CeQuS5b4I8aNuze-yhItZz0jSthucUXmQQtKWEvyh_HvQdcWMOGbYGaBCZDaTSoocek2FUh4bVli_bhfOkBSC2ZNRTXaZ0jvw27Giw3AB8wd70gPjKHKH-RsUmLhdlqdFGxWwX5sYZ_6JY2yTfIIDiZfVN8OpbyosG6XuUDPt02S"
  "x-ms-effective-locale"="en.pl-pl"
  "Accept"="*/*"
  "Referer"=""
  "x-ms-client-request-id"="780cb14a-0c3e-4d6b-9160-45f44f6c6ea4"
  "client-request-id"="780cb14a-0c3e-4d6b-9160-45f44f6c6ea4"
} `
-ContentType "application/json"
```

Not much! But all the juice is there 😎

First of all I always change `Invoke-WebRequest` to `Invoke-RestMethod`.
This makes the request response data easier to handle 😉

So we get Graph API URL, Authorization token and Body (if there is any).
Those three components of this code are the Heros.

# Move Settings Catalog profile

Finally it now the time for you to perform migration of **Settings Catalog** profile from Sandbox to Prod 😝

Until Microsoft adds a action to Export and Import configuration profiles it is the fastest way without installing any additional software!

To be able to move settings catalog profile between tenants we need set of policies and values that are configured in this profile.

So go to the profile that you wish to move and `Edit` profile

![DevTools7]({{ site.url }}/assets/images/posts/2022-02-12-DevTools/7.png)

You do not need to make any changes!

Just click `Review + save` and `Save` to capture request that goes after you click `Save`.

```powershell
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Safari/537.36 Edg/98.0.1108.50"
Invoke-RestMethod -UseBasicParsing -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('0d15031a-fd95-4202-a43d-da63117070b8')" `
-Method "PUT" `
-WebSession $session `
-Headers @{
"x-ms-client-session-id"="97b2957ca94944f1bf9b5990939c04b0"
  "X-Content-Type-Options"="nosniff"
  "Accept-Language"="en"
  "Authorization"="Bearer eyJ0eXAiOiJKV1QiLCJub25jZSI6Im5idkVmeXd2RExnSjJaMG9BdlRna0xMTmFvREZYdHJHSlRLUEZ1cEdEZ00iLCJhbGciOiJSUzI1NiIsIng1dCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20vIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYTUxZDgyNzYtYThjYS00NmEyLTg3NjUtYjE2ZjJmN2U1ZTZhLyIsImlhdCI6MTY0NDY3NjYzMiwibmJmIjoxNjQ0Njc2NjMyLCJleHAiOjE2NDQ2ODE5MzYsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJFMlpnWUJEWWVlYTZXdGlWN01mQ241ZHNXTFNpWlZQeE9nUHVob1ZjQVF6K01UL1pBK0lCIiwiYW1yIjpbInB3ZCJdLCJhcHBfZGlzcGxheW5hbWUiOiJNaWNyb3NvZnQgSW50dW5lIHBvcnRhbCBleHRlbnNpb24iLCJhcHBpZCI6IjU5MjZmYzhlLTMwNGUtNGY1OS04YmVkLTU4Y2E5N2NjMzlhNCIsImFwcGlkYWNyIjoiMiIsImNvbnRyb2xzIjpbImNhX2VuZiJdLCJmYW1pbHlfbmFtZSI6IkhvcmJhY3oiLCJnaXZlbl9uYW1lIjoiTWFjaWVqIiwiaWR0eXAiOiJ1c2VyIiwiaXBhZGRyIjoiODkuNjQuMTE5LjIxNCIsIm5hbWUiOiJNYWNpZWogSG9yYmFjeiIsIm9pZCI6ImNmMWYwNTI1LWQzMjYtNDVmMy1iYTBlLWZkMDhkYjA3OTM0ZSIsInBsYXRmIjoiMyIsInB1aWQiOiIxMDAzMjAwMDk2M0IwMzQ0IiwicmgiOiIwLkFVY0Fkb0lkcGNxb29rYUhaYkZ2TDM1ZWFnTUFBQUFBQUFBQXdBQUFBQUFBQUFCSEFMMC4iLCJzY3AiOiJDbG91ZFBDLlJlYWQuQWxsIENsb3VkUEMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50QXBwcy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRDb25maWd1cmF0aW9uLlJlYWRXcml0ZS5BbGwgRGV2aWNlTWFuYWdlbWVudE1hbmFnZWREZXZpY2VzLlByaXZpbGVnZWRPcGVyYXRpb25zLkFsbCBEZXZpY2VNYW5hZ2VtZW50TWFuYWdlZERldmljZXMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50UkJBQy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRTZXJ2aWNlQ29uZmlndXJhdGlvbi5SZWFkV3JpdGUuQWxsIERpcmVjdG9yeS5BY2Nlc3NBc1VzZXIuQWxsIGVtYWlsIG9wZW5pZCBwcm9maWxlIFNpdGVzLlJlYWQuQWxsIiwic3ViIjoiNkw5Q1hJeTRsckJPMGZ3RGVIaldCMDZUOGtLOXVBT3c2UnhLS0VYLTN0OCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJFVSIsInRpZCI6ImE1MWQ4Mjc2LWE4Y2EtNDZhMi04NzY1LWIxNmYyZjdlNWU2YSIsInVuaXF1ZV9uYW1lIjoibWFjaWVqaG9yYmFjekBkdW5lc2JveC5vbm1pY3Jvc29mdC5jb20iLCJ1cG4iOiJtYWNpZWpob3JiYWN6QGR1bmVzYm94Lm9ubWljcm9zb2Z0LmNvbSIsInV0aSI6ImllckFtVU9WMlVHQUd0c1RwdllQQUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbImUzOTczYmRmLTQ5ODctNDlhZS04MzdhLWJhOGUyMzFjNzI4NiIsIjYyZTkwMzk0LTY5ZjUtNDIzNy05MTkwLTAxMjE3NzE0NWUxMCIsImU4NjExYWI4LWMxODktNDZlOC05NGUxLTYwMjEzYWIxZjgxNCIsImIwZjU0NjYxLTJkNzQtNGM1MC1hZmEzLTFlYzgwM2YxMmVmZSIsIjE5NGFlNGNiLWIxMjYtNDBiMi1iZDViLTYwOTFiMzgwOTc3ZCIsImI3OWZiZjRkLTNlZjktNDY4OS04MTQzLTc2YjE5NGU4NTUwOSJdLCJ4bXNfc3QiOnsic3ViIjoialU1SWVqSGU5MVpjcDlKdHZLNXV3aWJBN0d5SHZfRjUyMzJqa1dZdUFWYyJ9LCJ4bXNfdGNkdCI6MTU3OTI5NzMxNH0.SuWFMS0iGwVZkM_R1zdRMxOIE3N5Mjf2CQOom_0NHh3yKyS_Gl5FxFeeKcsBS8qkWdI7ybBONOLuoebGlLX69PyjTRnlqob8vHSe3h6DiSMwvMAuTE3GQ0yYMM-EMfN96gHIaDargVjknWb48k7CeQuS5b4I8aNuze-yhItZz0jSthucUXmQQtKWEvyh_HvQdcWMOGbYGaBCZDaTSoocek2FUh4bVli_bhfOkBSC2ZNRTXaZ0jvw27Giw3AB8wd70gPjKHKH-RsUmLhdlqdFGxWwX5sYZ_6JY2yTfIIDiZfVN8OpbyosG6XuUDPt02S"
  "x-ms-effective-locale"="en.pl-pl"
  "Accept"="*/*"
  "Referer"=""
  "x-ms-client-request-id"="6e90a57a-1cdd-4bbd-992c-991a561319bb"
  "client-request-id"="6e90a57a-1cdd-4bbd-992c-991a561319bb"
} `
-ContentType "application/json" `
-Body "{`"name`":`"Edge`",`"description`":`"`",`"platforms`":`"windows10`",`"technologies`":`"mdm`",`"roleScopeTagIds`":[`"0`"],`"settings`":[{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSetting`",`"settingInstance`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup`",`"choiceSettingValue`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingValue`",`"value`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup_1`",`"children`":[{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup_restoreonstartup`",`"choiceSettingValue`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingValue`",`"value`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartup_restoreonstartup_4`",`"children`":[]}}]}}},{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSetting`",`"settingInstance`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartupurls`",`"choiceSettingValue`":{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationChoiceSettingValue`",`"value`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartupurls_1`",`"children`":[{`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance`",`"settingDefinitionId`":`"device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~startup_restoreonstartupurls_restoreonstartupurlsdesc`",`"simpleSettingCollectionValue`":[{`"value`":`"google.com`",`"@odata.type`":`"#microsoft.graph.deviceManagementConfigurationStringSettingValue`"}]}]}}}],`"templateReference`":{`"templateId`":`"`",`"templateFamily`":`"none`",`"templateDisplayName`":null,`"templateDisplayVersion`":null}}"
```

Change `Method` to `POST`...
Now with THAT you can create infinite number of this configuration profile anywhere! 🪄

Only one condition must be met

* You need working `Authorization` token for destination tenant

How to get token?
Well that is easy, just sign in to destination tenat and using `DevTools` trick copy token for that environment and make changes to the code.

# Summary

I get shivers thinking that I would have to manualy recreate every single setting I've set 😖

With that I've saved a lot of time moving from simple profile to such that contain dozens of policies!!

See you in next! 😉 🧠