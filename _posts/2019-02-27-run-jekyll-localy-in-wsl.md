---
title: Run Jekyll localy in WSL
categories:
    - Blog
tags:
    - Jekyll
    - WSL
excerpt: Running a Jekyll in WSL on your Windows 10 machine
toc: true
toc_label: Jekyll on WSL
last_modified_at: 2019-03-01T15:00:00+01:00
---

# Down the Rabbit Hole

Some time ago I've started a blog! That was huge for me, although it was only a few click on [wordpress.com](https://wordpress.com/) and [Cloudflare](https://www.cloudflare.com/) to set it up it took me a few hours to select a template. Yes, I've started a technical blog just to spend time selecting layout! 
Well, anyway, first post surfaced on 7th May of 2017 ([New Module helper function](https://arconnetblog.wordpress.com/2017/05/07/new-module-helper-function/)). Not that I'm very proud of it. I had a lot of better topics to write about - I just didn't know how! 

Almost two years later I've decided to move the blog to GitHub. This is VERY easy and the blogs I mentioned [here](https://www.mczerniawski.pl/random/A-new-start) should help with the process. If you'd have any questions though, or wanted to ask anything - reach out!

I started simple - took [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) template, edited _config.yml file and pushed everything to GitHub. There's nothing wrong with it but after each commit I had to wait for GitHub to build it (or not - and notify me via email about errors in files) just to spot my mistakes - wrong image path, wrong markdown syntax, etc.:

![Ups]({{ site.url }}{{ site.baseurl }}/assets/images/posts/run-jekyll-localy/picture1.png)

> Time has come to set up Jekyll localy!

As I'm running Windows 10 I did want to try out WSL and set it up using Ubuntu flavor. IF everything would go smooth - I wouldn't have the experience to share here :grin:

# WSL - here we go

Installation is pretty straightforward (and well documented on [docs.microsoft.com](https://docs.microsoft.com/en-us/windows/wsl/install-win10)):

- Enable optional feature

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

- install it from Windows Store
![Store]({{ site.url }}{{ site.baseurl }}/assets/images/posts/run-jekyll-localy/picture2.png) 
- Initialize new distro instance (just follow [this](https://docs.microsoft.com/en-us/windows/wsl/initialize-distro) article)

One thing to remember - my account is not local administrator. I have another account for this purpose. I was unable to initialize Ubuntu using my regular account or `Run As Other User`. I had to grant myself admin rights, initialize Ubuntu and then revoke admin rights.

# Jekyll

## UPDATED 2019-03-01

Thanks to Damien Solodow ( [Web](https://t.co/6MrDuO8gjY?amp=1) [Twitter](https://twitter.com/DSolodow)) for pointing out that Jekyll has tutorial docs regarding WSL - [Jekyll on Windows](https://jekyllrb.com/docs/installation/windows/#installation-via-bash-on-windows-10).

This code would prevent me from having all those issues described below:

```bash
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install ruby2.5 ruby2.5-dev build-essential dh-autoreconf
```

---

I hoped that this would be as simple as installing WSL. GitHub has a great [tutorial](https://help.github.com/en/articles/setting-up-your-github-pages-site-locally-with-jekyll) as well how to do it but probably WSL comes into play here.

Anyway - my Ubuntu flavor had no ruby installed. That's easily fixable. 

```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install ruby
```

After that installing Bundler was easy:

```bash
sudo gem install bundler
```

Now, according to the tutorial I need to modify my gemfile and make sure it has specific entries. As minimal-mistakes template is using additional plugins my `gemfile` looks like this:

```bash
source "https://rubygems.org"
gem "github-pages", group: :jekyll_plugins
gem "jekyll-include-cache"
gem "jekyll-paginate"
gem "jekyll-sitemap"
gem "jekyll-gist"
gem "jekyll-feed"
gem "jemoji"
```

Now, switch to the directory where my blog repository exists and run `bundle install`:

```bash
cd /mnt/c/repos/Private-GIT/mczerniawski.pl
bundle install
```

Not so fast:

```bash
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    current directory: /tmp/bundler20190227-9824-1pzfeiycommonmarker-0.17.13/gems/commonmarker-0.17.13/ext/commonmarker
/usr/bin/ruby2.5 -r ./siteconf20190227-9824-ben4j7.rb extconf.rb
mkmf.rb can't find header files for ruby at /usr/lib/ruby/include/ruby.h

extconf failed, exit code 1

Gem files will remain installed in /tmp/bundler20190227-9824-1pzfeiycommonmarker-0.17.13/gems/commonmarker-0.17.13 for
inspection.
Results logged to
/tmp/bundler20190227-9824-1pzfeiycommonmarker-0.17.13/extensions/x86_64-linux/2.5.0/commonmarker-0.17.13/gem_make.out

An error occurred while installing commonmarker (0.17.13), and Bundler cannot continue.
Make sure that `gem install commonmarker -v '0.17.13' --source 'https://rubygems.org/'` succeeds before bundling.

In Gemfile:
  github-pages was resolved to 196, which depends on
    jekyll-commonmark-ghpages was resolved to 0.1.5, which depends on
      jekyll-commonmark was resolved to 1.2.0, which depends on
        commonmarker
```

Let's fix it by adding ruby headers and then commonmarker

```bash
sudo apt-get install ruby-all-dev zlib1g-dev libxslt1-dev libxml2-dev
sudo gem install commonmarker
bundle install
```

aaaand it's not working either. This time it hangs on nokogiri gem. Only after `CTRL+C` it outputs the error:

```bash
Installing nokogiri 1.10.1 with native extensions
^C
Errno::ENOTEMPTY: Directory not empty @ dir_s_rmdir - /tmp/bundler20190227-16048-ygkmeynokogiri-1.10.1
An error occurred while installing nokogiri (1.10.1), and Bundler cannot continue.
Make sure that `gem install nokogiri -v '1.10.1' --source 'https://rubygems.org/'` succeeds before bundling.

In Gemfile:
  github-pages was resolved to 196, which depends on
    jekyll-mentions was resolved to 1.4.1, which depends on
      html-pipeline was resolved to 2.10.0, which depends on
        nokogiri
```

Let's build it with local libraries and finish install with `bundle install` again:

```bash
sudo gem install nokogiri -- --use-system-libraries --with-xml2-include=/usr/include/libxml2 --with-xml2-lib=/usr/lib/
bundle install
```

# Success

Finally, let's run the blog with `jekyll serve`

```bash
Configuration file: /mnt/c/repos/Private-GIT/mczerniawski.pl/_config.yml
            Source: /mnt/c/repos/Private-GIT/mczerniawski.pl
       Destination: /mnt/c/repos/Private-GIT/mczerniawski.pl/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       Jekyll Feed: Generating feed for posts
   GitHub Metadata: No GitHub API authentication could be found. Some fields may be missing or have incorrect data.
                    done in 28.328 seconds.
                    Auto-regeneration may not work on some Windows versions.
                    Please see: https://github.com/Microsoft/BashOnWindows/issues/216
                    If it does not work, please upgrade Bash on Windows or run Jekyll with --no-watch.
 Auto-regeneration: enabled for '/mnt/c/repos/Private-GIT/mczerniawski.pl'
    Server address: http://127.0.0.1:4000
  Server running... press ctrl-c to stop.
```

> Success

![Success]({{ site.url }}{{ site.baseurl }}/assets/images/posts/run-jekyll-localy/picture3.png)

# Summary

Wish it was a little bit more... straightforward. At the same time, great `kudos` to GitHub for doing the heavylifting!

:smile: