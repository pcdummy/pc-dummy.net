---
date: 2015-02-08T13:00:00+01:00
title: First hugo post
author: pcdummy
tags:
  - howto
  - hugo
  - atom
  - markdown
  - sublime
---
Today i moved my wordpress blog to hugo, it will allow me to **post faster** use **less resources** and i can **share** my content **on [github](https://github.com/pcdummy/pc-dummy.net)**.

I've been using Markdown a lot recently to document my own stuff,
now i'm able to just copy it to my blog and publish it.

<!--more-->[Hugo](gohugo.io/) is a open source tool written by [@spf13](https://github.com/spf13) in [go](http://golang.org/) that converts [Markdown](https://en.wikipedia.org/wiki/Markdown) documents into static pages or serves them as server.

#### Tools i've been using while converting:

- [Ubuntu GNU/Linux MATE](https://ubuntu-mate.org/) - The [MATE](http://mate-desktop.org/) flavor of Ubuntu GNU/Linux.

- [Atom.io](https://atom.io/) - I use Atom since some weeks, it has been a nice replacement for the shareware and closed source [Sublime](http://www.sublimetext.com/).

- [To-Markdown](https://domchristie.github.io/to-markdown/) - A useful HTML-to-Markdown converter, which I've been using while switching to Hugo.

- [gohugo.io source](https://github.com/spf13/hugo/tree/master/docs/) - gohugo.io runs trough Hugo and its source helped me alot to build this blog.

- On-liner to test trough all themes, **run in your sites root**:

    for i in $(find themes/ -maxdepth 2 -iname 'theme.toml'); do \
        echo -e "\nCurrent Theme: $(expr match "$i" 'themes\/\(.*\)\/theme.toml')\n"; \
        hugo server --buildDrafts --watch \
            --theme=$(expr match "$i" 'themes\/\(.*\)\/theme.toml'); \
    done

#### This blog uses:

- [Ubuntu GNU/Linux Server](http://www.ubuntu.com/download/server) - Yes its a download link for a fully featured Server OS.

- [Nginx](https://en.wikipedia.org/wiki/Nginx) - A lightweight, fast and stable web server from [Igor Sysoev](https://en.wikipedia.org/wiki/Igor_Sysoev).

- Of course [Hugo](gohugo.io/) i also have a live preview of my whole site with it.

- [Purehugo theme](https://github.com/dplesca/purehugo) - A little modified.

- Client Side [Syntax highlighting](http://gohugo.io/extras/highlighting/) with [hightlight.js](https://highlightjs.org/)

- [Atom.io](https://atom.io/) - To create the pages/entries
