---
title: Select-Object filtering simplified
categories:
    - PowerShell
tags:
    - PowerShell
    - Select-Object
---

Just a quickie note.

I needed to get some information about servers' computer objects from AD. Simple query with some properties:

{% gist b8a3b7108a0007e4d0ef172b8eef40f6 %}

What started simple soon became more… complicated:

{% gist 136b3430018f6003a01c13a88d450d35 %}

Somewhere along the way I had to query this from multiple domains using different credentials and finally export it into csv.

Every time I was adding new property or select-object property I had to do it in multiple places. Remember this started as an ad-hoc script, not polished function.
Eventually I moved all properties and select-object into variables. 

> Thing to remember - select-object requires separate elements, not single string.

Now, this is a way better to read through:

{% gist 161bbfc8dd51f7201bbcbe8e46c5d6f9 %}

![Simple](/assets/images/posts/select-object-filtering/picture1.jpg)

# Final touch
Also moved all domains into an array:

{% gist 8b248b77095d79177b63cfea2d8a3843 %}



