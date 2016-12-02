---
date: 2016-12-02T07:32:00+01:00
title: LXD and live migration / Canoncial needs support for CRIU
author: pcdummy
tags:
  - LXD
  - CRIU
  - Ubuntu
  - Canoncial
---
[LXD](https://linuxcontainers.org/lxd) is a container "hypervisor", its similiar to
XEN, KVM, VirtualBox or VMWare if you use it Linux only.

Lex-dee is a full stack os hypervisor while Docker's main focus lays on app containerisation.
<!--more-->
Some of the main features of LXD are:

  - Live Migrations (Move one container to another Host while its running)
  - Secure by design
  - Scalable
  - Intuitive to use
  - Its image based
  - Supports limits (Max memory, CPU, disk IO)
  - Support for multiple network interfaces, by macvlan or bridges
  - Support for bind mounts and mounting block devices into containers
  - On ZFS and BTRFS containers take only a little space

Nice features, not? But there's a catch, Canoncial isn't supporting the live Migration work anymore:

![Canoncial CRIU Support](/static/content/post/lxd-and-live-migration-criu/canoncial-criu-support.png)

Please tell Canoncial that you need LXD live migrations if your a paying customer of canoncial or if you get one!

P.s.: XEN, KVM, Virtualbox and VMWare is ofc more secure than containers, we should compare it to Docker, OpenVZ, Virtuozzo and FreeBSD jail.
