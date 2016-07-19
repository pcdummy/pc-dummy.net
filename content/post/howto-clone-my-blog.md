---
date: 2016-04-05T00:17:00+01:00
description: Detailed explanation on HOWTO clone this Plone5 based blog
tags:
- HOWTO
- Plone
- Blog
- Markdown
title: Howto clone my blog
---
I open sourced all components of my blog, this post is for anyone who want's the same blog or build one on top of mine.
It's a **step by step guide even for newcomers to Plone**.<!--more-->

### Requirements

- GNU/Linux or Mac OS
- Windows users can use [Vagrant](http://docs.plone.org/manage/installing/installation.html#microsoft-windows)

### The components of this blog

- [collective.blog](https://github.com/collective/collective.blog) - A blog for Plone 5.

    Ideas have been take from [ftw.blog](https://github.com/4teamwork/ftw.blog) and [plone.app.event](https://github.com/plone/plone.app.event).

    I've written it to learn Plone.

- [plonetheme.persona](https://github.com/collective/plonetheme.persona) - Port of the clean and well-readable Persona theme to Plone 5.

    - First ported by [@aries1980](https://github.com/aries1980/hugo-theme-persona) to [hugo](https://github.com/spf13/hugo)
    - Then improved by [@pcdummy](https://github.com/pcdummy/hugo-theme-persona)
    - Now ported to Plone 5 by [@pcdummy](https://github.com/pcdummy/)

- [mockup-highlightjs](https://github.com/collective/mockup-highlightjs) - [highlightjs](https://highlightjs.org/) for plonetheme.persona.

- [rj.site](https://github.com/pcdummy/rj.site) - A simple integration package

    Currently a very simple integration package that installs `collective.blog` and `plonetheme.persona`.

    I plan to extend this via an Upgrade Step to set some options on the site i currently manualy set.

- [rj.buildout](https://github.com/pcdummy/rj.buildout)

    A buildout based on `starzel/buildout` to generate a Plone site, named last but the root to build
    your clone.

### Step by step guide

1.) Install the required packages as documented [here](http://docs.plone.org/manage/installing/installation.html#ubuntu-debian)

```bash
sudo apt-get -y install python-setuptools python-dev build-essential libssl-dev libxml2-dev libxslt1-dev libbz2-dev libjpeg62-dev virtualenv python-tk python-gdbm
sudo apt-get -y install libreadline-dev wv poppler-utils
sudo apt-get -y install git pwgen
```

2.) Create a clone of rj.buildout into a folder named `plone`

```bash
git clone https://github.com/pcdummy/rj.buildout.git plone
```

3.) Create a virtualenv for the buildout (a Python environment inside "plone")
```bash
cd plone
virtualenv -p /usr/bin/python2.7 --no-site-packages .
```

4.) Install zc.buildout in your new python environment.
```bash
./bin/pip install -r requirements.txt
```

5.) Symlink `local_develop.cfg` to `local.cfg`
```bash
ln -s local_develop.cfg local.cfg
```

6.) Generate a `secret.cfg` for the plone superadmin.
```bash
echo -e "[buildout]\nlogin = admin\npassword = $(pwgen -B -1 15)\n" > secret.cfg
cat secret.cfg
```

**Remember** the **username** and **password** here, you need it later to login to your plone site.

7.) Run "buildout" to download the dependencies, install and compile everything together.
```bash
./bin/buildout -N
```

This will take a while, go get a coffee :)


8.) Run the ZEO Server (the Database server)
```bash
./bin/zeoserver start
```

9.) Run your ZOPE site.
```bash
RELOAD_PATH=src/ ./bin/zeoclient_debug fg
```

10.) Go with a browser to [localhost:8084](http://localhost:8084)

11.) Click on `Create a new Plone site`

12.) Set the "Path identifier" to "Plone" and fill everything else as wanted.

13.) Goto the [Add-ons configurator](http://localhost:8084/Plone/prefs_install_products_form)

And install `rj.site`

14.) Next goto the [Markup controlpanel](http://10.167.161.14:8084/Plone/@@markup-controlpanel)

And enable the markups you want to write your blog posts in (i personaly prefer Markdown).


### Thanks

This blog and its clone guide wouldn't be possible without:

- [The Plone Community](https://plone.org/community): Its a great community!
- [The Plone Training](http://training.plone.org/5/): A good place to look for howto do stuff in Plone.
- [Webmeisterei](http://webmeisterei.com/): My employer where i learn every day new stuff around Plone.
- [Starzel](http://www.starzel.de/): For [starzel/buildout](https://github.com/starzel/buildout/).
- [ftw.blog](https://github.com/4teamwork/ftw.blog): Code and idea for collective.blog have been taken from it.