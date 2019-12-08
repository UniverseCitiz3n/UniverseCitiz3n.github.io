---
title: Remote change of wallpaper with Powershell
categories:

    - Powershell

tags:

    - Tips'n'Tricks
    - Workstations

excerpt: It's good to sometimes make a prank on your colleagues

comments: true

---

# Intro

# How to do it

Windows stores information about wallpaper in registry for every user in their profile hives. In "HKU:\$UserSID\Control Panel\Desktop" there are three string values which you need to maniuplate:

Wallpaper|The path to the wallpaper picture can point to a: .bmp, .gif, .jpg, .png, or .tif file
TileWallpaper| - 0: The wallpaper picture should not be tiled<BR> - 1: The wallpaper picture should be tiled 
WallpaperStyle| - 0:  The image is centered if TileWallpaper=0 or tiled if TileWallpaper=1 <br> - 2:  The image is stretched to fill the screen <br> - 6:  The image is resized to fit the screen while maintaining the aspect ratio. (Windows 7 and later) <br> - 10: The image is resized and cropped to fill the screen while maintaining the aspect ratio. (Windows 7 and later)

That's all the magic.
