---
title: How long would it take... 
categories:

    - Selenium

tags:

    - 2FA
    - Azure
    - Active Directory
    - Powershell

    - Selenium

excerpt: ... to fix hundreds of users mobile numbers in AzureAD MFA config manually? 😱

comments: true

---

# Intro

Multi-factor authentication (MFA) is great security measure. The most common second factor is probably SMS code sent to your mobile phone. And what could go wrong there? Well I don't know how but at some point recently we had around **150 users** did not receive codes even though they configured **MFA**.

# Issue

A user raised an issue that he does not receive codes for MFA. Is it cellphone carrier issue? Maybe user changed numbers and forgot about it? Or something else? First two where assumptions where ruled out immediately so I focused on configuration of the service itself. For that I went to **user profile** in **Azure AD** and then to **Authentication methods**. There I saw:

![mfa]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-02-25-mfa.jpg)

Duplicated intercalation call prefix 😮. I've removed additional digits - **0048** - and SMS codes began to arrive to user. That was easy! But then question arrived... how many users might have the same issue? 🤔<br>
To check that I've run:

``` powershell
Connect-MsolService
$MSONUSER = Get-MsolUser -All | select DisplayName -ExpandProperty StrongAuthenticationUserDetails |`
select DisplayName,email,phonenumber
```

Some sorting and filtering and I ended up with list of around 150 users which fitted in similar pattern where country prefix was doubled. I won't fix it manually!! Let's use some Powershell of MSGraph 😎.

### **NOPE**

Powershell can't do that and API is (as on 25.0.2020) to be hopefully exposed in (Q1 2020)[https://microsoftgraph.uservoice.com/forums/920506-microsoft-graph-feature-requests/suggestions/18493399-expose-user-authentication-phone-and-authenticatio].<br>
Quick calculations

![mfa2]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-02-25-mfa2.gif)

150 users x 2-5 minutes = 300-750 minutes = **5-12, 5 hours**

![mfa3]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-02-25-mfa3.gif)

There must be some way!! Wait a minute... 💡

# Selenium

If I'm not gonna click it then let's make browser click for me 😁.

# Summary

See you in next! 😉 🧠

