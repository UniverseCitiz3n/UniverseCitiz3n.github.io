---
title: Remote Get-Counter issues
header:
    image: /assets/images/posts/remote-get-counter/picture_header.jpg
categories:
    - PowerShell
tags:
    - PowerShell
    - Counter
---

# Fun!

Today was a happy day. One of my co-workers asked me if I can help him with a little PowerShell. I never say 'no' to this. 

![Panda]({{ site.url }}{{ site.baseurl }}/assets/images/posts/remote-get-counter/picture1.jpg) 

# The Story

So what's the story? He needed to get some performance counters from a bunch of remote servers. Those are in different domain so Get-Counter won't work - no Credential parameter. He wrapped it up in Invoke-Command, but then got some errors. Basicaly this was the 'problematic' part:

{% gist 1c857021924bfd604ce847ecf5f89de7 %}

He wanted to generate counters on the endpoint, get the results through Invoke-Command and export them locally on his machine to further investigate. This is what he got:

![Error1]({{ site.url }}{{ site.baseurl }}/assets/images/posts/remote-get-counter/picture2.png)

The issue here is, that data returned through Invoke-Command is deserialized, which is not the original `object`:

![Fixed]({{ site.url }}{{ site.baseurl }}/assets/images/posts/remote-get-counter/picture3.png)

So, I came up with a little bit different idea:
1. Create a number of PowerShell Sessions to destination computers (based on xml input)
2. Create an array of hashtables defining which counters are processed by which computer (different roles like SQL, IIS etc)
3. Use Invoke-Command to:
    - Generate destination file name based on computer name, date and other needed parameters
	- Get Counters and export them on the machine directly
	- Return object with computer name and destination file location
4. Then, once the Invoke finishes, use foreach on processed computers to copy those files to his local machine using Copy-Item -FromSession (luckily we're working on Windows 10/2016 machines here)
5. And finally clean up all PowerShellSessions created.

This is (nearly) the code we've end up:

{% gist c6de35cd2ca9a4b7c47265f7417fa32b %}




