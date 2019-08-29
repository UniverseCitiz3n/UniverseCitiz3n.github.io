---
title: First test post
categories:

    - PowerShell

tags:

    - PowerShell
    - Test

excerpt: Test post to check view...
---

# Get-Users

Code is quite simple:

``` powershell
    Foreach($item in $collection){
        Get-ADUser -identity $item
    }
```

