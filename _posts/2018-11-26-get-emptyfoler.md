---
title: Get-EmptyFoler
categories:
    - PowerShell
tags:
    - PowerShell
---

![cleanup](/assets/images/posts/get-empty-folder/picture1.jpg)

# A quicky 

Hyper-V clustered hosts. Storage of some VMs migrated from one host to another. On rare occasions migration failed. Reason is now irrelevant. But after this - there are some empty folders left on Clustered Shared Volumes:

```
\\SomeHVHost\c$.
├───Planned Virtual Machines
├───Snapshots
├───Virtual Hard Disks
 └───Virtual Machines
```

There are also other situation where there are bunch of empty folders left (testing, installations, migrations etc).

I was looking for a neat solution and found this post by Jeffery Hicks - [Link](https://www.petri.com/powershell-problem-solver-delete-empty-folders).

After a few minutes I've got a working function that:
1. Can query local system
2. Can query remote system (using Invoke-Command)
3. Can use Credential parameter for remote sessions
4. And thanks to the above - works also from PS Core:)

## Here's the code:

{% gist 7f4cfb5123cb9e90f51e1d4dd7addd0b %}

And here's the output:
- Local run:

![local run](/assets/images/posts/get-empty-folder/picture2.png)

![local run](/assets/images/posts/get-empty-folder/picture3.png)

- Remote run with credential parameter

![remote run](/assets/images/posts/get-empty-folder/picture4.png)

	
	
	
	
	
