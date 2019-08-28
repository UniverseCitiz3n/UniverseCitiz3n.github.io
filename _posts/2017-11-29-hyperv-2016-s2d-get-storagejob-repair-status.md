---
title: Hyper-V 2016 S2D Get-StorageJob repair status
categories:
    - HyperV
tags:
    - PowerShell
    - Hyper-V
    - S2D
    - StorageJob
---

# The need

So here's the deal. 

We're performing some regular maintenance on our Hyper-V 2016 S2D - i.e. patching. This includes rebooting nodes. While node is not online, Cluster performs storage repair jobs to keep our 3 way healthy. It's not good to reboot another node while repair job is in progress. To check the state of CSVs I can either use GUI:

![CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-storagejob/picture1.png)

or PowerShell:

![CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-storagejob/picture2.png)

With this I will see which drive is in degradaded state or repairing. 
I can use another cmdlet to get the status of the job: 

![CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-storagejob/picture3.png)

This on the other hand shows me how's the repair going, how long tasks are running or how much data is already processed. Which I don't get from here is which job relates to which drive. This can be usefull. Imagine you've got one repair job that is stuck or taking a long time. I'd like to know which CSV (Virtual Drive) is affected.

# The Search

Both objects returned by either `Get-StorageJob` or `Get-VirtualDisk` have an object called ObjectID, which looks like this:

![CSV]({{ site.url }}{{ site.baseurl }}/assets/images/posts/get-storagejob/picture4.png)

Seems like the thing I'm looking. Now I just need to parse the string to get the last guid-like string between `{` and `}` and match it with `Get-VirtualDisk`'s output same position. 

Let's use some regex. As I'm new in this area I've used [this site](https://regexr.com/) to get my regex right. Just paste your string and try different matching till you get it right.

Seems like this will do the trick:

`([A-Za-z0-9]{8}\-?){1}([A-Za-z0-9]{4}\-?){3}([A-Za-z0-9]{12})`

Got it - Let's try it:

{% gist 355c812acba6fb1c9498a2a669bd9af5 %}

And nothing. No output. Verifying both objects, and it seems they differ with one char. StorageJob seems to have +1 on `18th` position comparing to VirtualDisk.

Ok, let's adjust my regex to match new condition:

([A-Za-z0-9]{8}\-?){1}([A-Za-z0-9]{4}){1}

# The resolution

Now I know I can corelate repair job to specific CSV. Let's get some additional date from both commands. I'd like to know which drive is being repaired, the status, percent complete and ammount of data. 
It's now just a matter of creating a custom object in a foreach loop:

{% gist 42606920821c93ab64fe98c3998e3219 %}

Running it localy on a cluster node though is not a way I like it. Let's use Invoke-Command and target the Cluster Owner node for information. Also, let's add Credential parameter - so I can query cluster from my own workstation without admin privileges. I'll end up with a function like this:

{% gist efb648293cc5be1868767febb707571a %}

