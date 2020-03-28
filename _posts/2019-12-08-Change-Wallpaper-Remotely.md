---
title: Remote change of wallpaper with Powershell
categories:

    - Powershell

tags:

    - Tips'n'Tricks
    - Workstations

excerpt: It's good to sometimes make a prank on your colleagues

comments: true
toc: true
toc_label: Table of contents
---

# Intro

For me those kind of ideas are the best. While solving such issue I'm learing mysteries of OS which I would normally even won't care about 😋. And playing a trick on someone is my fuel 😈

# How to do it

Windows stores information about wallpaper in registry for every user in their profile hives. In "HKU:\$UserSID\Control Panel\Desktop" there are three string values which you need to maniuplate:

Wallpaper|The path to the wallpaper picture can point to a: .bmp, .gif, .jpg, .png, or .tif file
TileWallpaper| - 0: The wallpaper picture should not be tiled<BR> - 1: The wallpaper picture should be tiled 
WallpaperStyle| - 0:  The image is centered if TileWallpaper=0 or tiled if TileWallpaper=1 <br> - 2:  The image is stretched to fill the screen <br> - 6:  The image is resized to fit the screen while maintaining the aspect ratio. (Windows 7 and later) <br> - 10: The image is resized and cropped to fill the screen while maintaining the aspect ratio. (Windows 7 and later)

That's all the magic.

By default when your are remoting to another device session connects you to profile linked with credentials you used. So to change wallpaper for another user you need to look for SID of his profile. It can be simply done like that:

```powershell
Set-Location 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
$profiles = Get-ChildItem | Where-Object {$PSItem.PSPath -like 'S-1-5-21*'}
$UserName = $profiles | Get-ItemProperty | Select-Object ProfileImagePath,PSChildName
```

User profiles start with **S-1-5-21** so I'm searching only for those. ProfileImagePath stores location of profile folder which contains username and PSChildName stores SID which is needed for locating registry profile hive. With those information you can already go to setting registry values or if you want to change wallpaper for currently logon user use:

```powershell
$Sessions = quser
$LogonUsers = $Sessions -replace  '\s{2,}', ',' | ConvertFrom-Csv
Write-Host 'Logon users (active user has '>'):' -ForegroundColor Yellow
$i=0
Foreach($User in $LogonUsers.USERNAME){
    Write-Host "$i. $User"
    $i++
}
Write-host 'Choose user for which you want to set wallpaper (0,1,2,etc):' -NoNewline
$Choice = Read-Host 
$ActiveUsers =  $LogonUsers[$Choice]
$UserSID = ($UserName | Where-Object {$PSItem.ProfileImagePath -like "*$($ActiveUsers.USERNAME.Replace('>',''))"}).PSChildName
```

If you choose your victim you can proceed with applying your wallpaper.

```powershell
$Scriptblock = {
    param($UserSID)
    $ProfileHive = "HKU:\$UserSID\Control Panel\Desktop"
    Write-Host 'Wallpaper file present: ' -NoNewline
    $NewWallpaperPath = c:\path\to\your\file.jpg
    $TestPath = Test-Path -Path $NewWallpaperPath 
    if ($TestPath -eq 'True') {
        Write-Host $TestPath -ForegroundColor Green
    }
    else {
        Write-Host $TestPath -ForegroundColor Red
        Break
    }
    Write-Host 'Connecting HKEY_USERS'
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | out-null
    Set-location HKU:
    Write-Host 'Old wallpaper file' -ForegroundColor Red
    Get-ItemProperty -Path $ProfileHive | Select-Object WallPaper -ExpandProperty $Value | Out-Default
    Write-Host 'Changing wallpaper' -ForegroundColor Yellow
    Write-Host
    Remove-ItemProperty -path $ProfileHive -name WallPaper 
    set-itemproperty -path $ProfileHive -name WallPaper -value $NewWallpaperPath
    set-itemproperty -path $ProfileHive -name WallPaperStyle -value 2
    #Set-ItemProperty -Path $ProfileHive -Name TileWallpaper -value 0
    Write-Host 'New wallpaper file' -ForegroundColor Green
    Get-ItemProperty -Path $ProfileHive | Select-Object WallPaper -ExpandProperty $Value | Out-Default
    1..3 | ForEach-Object { RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters }
}

Invoke-Command -ComputerName $ComputerName -Scriptblock $Scriptblock -ArgumentList $UserSID
```
There is not much happening this code but I think that last line of **scriptblock** might be misterious. By default new setting are applied on user logon but to speed up changes you can run

```powershell
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters
```

But from my experience and from what I've read online it is the best to run it a few times just to be sure!

# Summary

Prank like that is harmless but be sure that you are not messing with someone who might fight back with even bigger guns 💀. 

See you in next! 😉 🧠
