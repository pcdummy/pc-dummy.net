---
date: 2015-07-14T21:09:00+01:00
title: Atom.io my editor of choice
author: pcdummy
tags:
  - atom
  - markdown
  - sublime
---
I use [atom.io](https://atom.io/) with a bunch of plugins. Atom.io is made by github, it uses the webkit engine underneath so its a browser engine running a extensible editor. :-)

So far theres no debugger for Go and Atom.io.

[atomtips.com](www.atomtips.com/atom-editor-vs-sublime-text/) explains my reasons to switch to Atom from Sublime quiet good.<!--more-->

#### Installation

    sudo add-apt-repository -y ppa:webupd8team/atom
    sudo apt-get update
    sudo apt-get -y install atom nodejs git
    apm install project-manager
    apm install linter # https:// atom.io/packages/linter
    apm install monokai
    apm install git-control
    apm install merge-conflicts
    apm install clipboard-history
    apm install minimap
    apm install minimap-git-diff

#### Go (golang) [autocomplete](https:// atom.io/packages/go-plus)

    go get -u -v github.com/nsf/gocode
    go get -u -v github.com/golang/lint/golint
    go get golang.org/x/tools/cmd/goimports
    apm install go-plus
    go get -u -v code.google.com/p/rog-go/exp/cmd/godef
    apm install godef
    go get code.google.com/p/go.tools/cmd/oracle
    apm install go-oracle

#### Python Flake8 linter for atom, i'm using the python3 variant as i develop for python 3.x

    sudo apt-get -y install python3-pip
    sudo pip3 install flake8
    apm install linter-flake8

#### Python autocomplete for atom

    sudo apt-get -y purge python3-jedi python-jedi
    apm install autocomplete-jedi

#### Python import sorter
[isort](https://github.com/timothycrosley/isort) and [python-isort](https://atom.io/packages/python-isort)

    sudo pip3 install isort
    apm install python-isort

#### Navigator :)

    apm install atom-ctags
