---
title: Deploy Chromium-Edge PWAs as Start menu tiles 
categories:

    - Intune

tags:

    - Intune
    - Powershell
    - Workstations

excerpt: Adding company crucial websites has never been easier 🤯🔥

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Yesterday colleague of mine sent me interesting video - [How to open "multiple instances" of Microsoft Teams](https://youtu.be/aCWhRtl9JIY?t=77). Which got me thinking, is there a way to customize those apps and attach them for employees to have quick access links on their workstations?? Drum roll...🥁

# Deploy new Edge

This whole solution is based on the newest Chromium-Edge so first thing you should do is to migrate your users to it. With the help of Intune it's a piece of cake 😊. Go to apps and click **Add**, select **Microsoft Edge** and proceed with configuration.

![Apps]({{ site.url }}/assets/images/posts/2020-04-03.jpg)

![Edge]({{ site.url }}/assets/images/posts/2020-04-03_2.jpg)

![EdgeSum]({{ site.url }}/assets/images/posts/2020-04-03_3.jpg)

Now that it is being deployed we can prepare our Start menu Tiles.

# Start menu Tiles

Basically what **installing a site as an app** in Edge is creation of simple shortcut with some **AppID**:

"C:\Program Files (x86)\Microsoft\Edge\Application\msedge_proxy.exe" --profile-directory="Default" --app-id=idedlkepfahmdemmnladahgfmcaapdjg

But what you can do is modify this like that:

"C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge_proxy.exe" --profile-directory="Default" --app=<https://universecitiz3n.tech/>

And you get link to my blog!😆

![Blog]({{ site.url }}/assets/images/posts/2020-04-03_4.jpg)

That's one app but how about creating multiple apps using Powershell! For this project I've created input data file with:

* App Name
* Site link
* App icon

``` json
[
  {
    "Application": "Blog",
    "Link": "https://universecitiz3n.tech/",
    "Icon": "universe-icon.ico"
  },
  {
    "Application": "Fun",
    "Link": "https://9gag.com/",
    "Icon": "9gag-icon.ico"
  },
  {
    "Application": "Teams",
    "Link": "https://teams.microsoft.com/",
    "Icon": "teams-icon.ico"
  },
]

```

This input then goes to this script

``` powershell
$Config = Get-Content .\ConfigJSON.json | ConvertFrom-Json
foreach ($item in $Config) {
    $SourceFileLocation = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge_proxy.exe"
    $Arguments = "--profile-directory=Default --app=$($item.Link)"
    #This is a location of global start menu on workstation
    $ShortcutLocation = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$($item.Application).lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
    $Shortcut.TargetPath = $SourceFileLocation
    #Location of icons on workstation
    $Shortcut.IconLocation = (Get-item ".\icons\$($item.icon)").FullName
    $Shortcut.Arguments = $Arguments
    $Shortcut.Save()
    Write-Output "Adding $($item.Application) to start menu"
}
```

And that is how we created **Start menu** items which work as **Edge PWAs**!

# Start layout deployment

Again thanks to Intune this task couldn't be easier!!
<br>Firstly drag and drop all apps to some group and place group in destined location

![Tiles]({{ site.url }}/assets/images/posts/2020-04-03_5.jpg)

Secondly export created layout to xml with Powershell

``` powershell
Export-StartLayout -Path c:\temp\layout.xml
```

Resulting XML will contain all tiles so you will need to modify it just to leave our configuration

``` powershell
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride LayoutCustomizationRestrictionType="OnlySpecifiedGroups">
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6">
        <start:Group Name="Important">
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Maciej Horbacz.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Fun.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Teams.lnk" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
```

And to block newly created tiles from editing by user you must specify parameter at line:<br>

``` powershell
<DefaultLayoutOverride LayoutCustomizationRestrictionType="OnlySpecifiedGroups">
```

But the rest of the tiles will not be changed.

Such prepared xml can be deployed using Intune. Go to **Configuration profiles**, create **Device restrictions** profile, upload **xml**

![profile]({{ site.url }}/assets/images/posts/2020-04-03_6.jpg)

![profile2]({{ site.url }}/assets/images/posts/2020-04-03_7.jpg)

![profile3]({{ site.url }}/assets/images/posts/2020-04-03_8.jpg)

And no other settings are required!

# Summary

Chromium-Edge PWAs is such great feature! And taking advantage of it is simple a thing!<br>One last thing... **make sure that the icons are somewhere to found the workstation**

See you in next! 😉 🧠
