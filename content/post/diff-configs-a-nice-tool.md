---
date: 2015-07-14T21:00:00+01:00
title: Diff-configs.sh a nice tool to get your configuration changes
author: pcdummy
tags:
  - Ubuntu
  - Debian
  - Apt
---
Since some time i use [diff-configs.sh](https://gist.github.com/matthewd/1254787) to
show all my manual config changes, its very nice to transfer them.

#### Installation

    pushd .
    mkdir ~/bin
    wget https://gist.githubusercontent.com/matthewd/1254787/raw/diff-configs.sh -O diff-configs
    chmod +x diff-configs
    popd

#### Usage

    sudo $(which diff-configs)
