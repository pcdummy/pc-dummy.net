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
This is what i do to install and configure lxd.<!--more-->

#### Install and configure it on the container host

Install **lxd**:

    sudo apt-add-repository -y ppa:ubuntu-lxc/stable
    sudo apt-get update
    sudo apt-get install lxd lxd-client

Give root one subuid and subgid:

    sudo usermod --add-subuids 100000-165536 root
    sudo usermod --add-subgids 100000-165536 root

OR give root 99 subuid's/subgid's:

    for i in {1..99}; do sudo usermod --add-subuids ${i}00000-${i}65536 root; sudo usermod --add-subgids ${i}00000-${i}65536 root; done # This takes a while

Restart **lxd**:

    sudo service lxd restart

Set the remote authentication password:

    lxc config set core.trust_password <your-password-here>

Change the default profile network interface:

    lxc profile edit default # Change lxcbr0 to your value.

Create an image:

    lxd-images import lxc ubuntu trusty amd64 --alias trusty64 --alias ubuntu/trusty --alias ubuntu/trusty/amd64

Create the container "trusty64" from the image "ubuntu/trusty/amd64" you just made:

    lxc launch ubuntu/trusty/amd64 trusty64

Show the log if the above failed:

    lxc info trusty64 --show-log

Attach a shell on it:

    lxc exec trusty64 /bin/bash

Delete the container you made:

    lxc delete trusty64

#### On your own box/client

Install lxd-client

    sudo apt-add-repository -y ppa:ubuntu-lxc/stable
    sudo apt-get update
    sudo apt-get install lxd-client

Add a remote for the server you just configured:

    lxc remote add <your-server-here> https://<your-server-fqdn-here>:8443 --accept-certificate # enter the password you've set above here.

See if the remote works:

    lxc list <your-server-here>:

#### Create a image from a container (publish it)

You need to delete the image first if you already have one with one of that aliases:

    lxc delete <server>:ubuntu/trusty/amd64

Now publish your container (make it available as image):

    lxc publish <server>:<container> <server>: --alias ubuntu/trusty --alias ubuntu/trusty/amd64

Delete the image container if needed:

    lxc delete <server>:trusty64

Launch a new container from the image you created:

    lxc launch <server>:ubuntu/trusty <server>:<your-new-container-name>

You can also do:

    lxc init <server>:ubuntu/trusty <server>:<your-new-container-name>
    lxc start <server>:<your-new-container-name>

Start a shell in the new container:

    lxc exec srv01:<new-container-name> /bin/bash

Usefull Links:
- [LXD README.md](https://github.com/lxc/lxd#machine-setup)
- [LXD CMD specs](https://github.com/lxc/lxd/blob/master/specs/command-line-user-experience.md)
- [LXD config specs (all configuration variables)](https://github.com/lxc/lxd/blob/master/specs/configuration.md)
