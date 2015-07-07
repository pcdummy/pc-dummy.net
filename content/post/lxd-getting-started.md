---
date: 2015-07-07T13:00:00+01:00
title: LXD getting started
author: pcdummy
tags:
  - HOWTO
  - Ubuntu
  - BTRFS
  - lxc
  - lxd
---
This is what i do to install and configure lxd.

Install **lxd**:

    sudo apt-add-repository -y ppa:ubuntu-lxc/stable
    sudo apt-get update
    sudo apt-get install lxd

Give root one subuid and subgid:

    sudo usermod --add-subuids 1000000-165536 root
    sudo usermod --add-subgids 1000000-165536 root

OR give root 99 subuid's/subgid's:

    for i in {100..199}; do sudo usermod --add-subuids ${i}00000-${i}65536 root; sudo usermod --add-subgids ${i}00000-${i}65536 root; done # This takes a while

Restart **lxd**:

    sudo service lxd restart

Set the remote authentication password:

    lxc config set core.trust_password &lt;your-password-here&gt;

Change the default profile network interface:

    lxc profile edit default # Change lxcbr0 to your value.

Create an image:

    lxd-images import lxc ubuntu trusty amd64 --alias trusty64 --alias ubuntu/trusty/amd64

Create the container "trusty64" from the image "ubuntu/trusty/amd64" you just made:

    lxc launch ubuntu/trusty/amd64 trusty64

Show the log if the above failed:

    lxc info trusty64 --show-log

Usefull Links:
- [LXD README.md](https://github.com/lxc/lxd#machine-setup)
- [LXD CMD specs](https://github.com/lxc/lxd/blob/master/specs/command-line-user-experience.md)
