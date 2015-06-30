---
date: 2015-06-14T22:54:00+01:00
title: Install the latest salt-minion
author: pcdummy
tags:
  - HOWTO
  - Ubuntu
  - Salt
---

#### This is what i use to install the latest salt-minion on Ubuntu 14.04
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository -y ppa:saltstack/salt
    sudo apt-get update
    sudo apt-get -qy install salt-minion
<!--more-->
