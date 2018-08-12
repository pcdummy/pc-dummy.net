---
date: 2018-04-19T13:55:00+02:00
title: UNOFFICIAL Proxmox with Debian GNU/Linux Buster
author: pcdummy
tags:
  - HOWTO
  - Debian
  - Proxmox
---

**WARNING: This is a playground to test debian/buster with pve NOT PRODUCTION READY**

I have my main Workstation and my Laptop on Debian buster (aka testing!) so I decided to create my own pve packages for this release
as I didn't want to downgrade to Debian stretch (aka stable!).

This wasn't a straight download-compile-upload task, will provide my patches soon and the more of you have fun with testing buster the more patches will come.
<!--more-->

### Known Bugs:

- objtool missing in pve-kernel-4.15
If you have the nvidia blob driver, virtualbox uvm. installed then you need to do some handwork before booting in the pve kernel.

- spice seems not to work.


### Installation:

- Configure /etc/hosts as described on the [wiki](https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_Stretch).

- Add my release key to your trusted keys:

```
sudo wget -O /etc/apt/trusted.gpg.d/lxch-pve-release.gpg http://repo.lxch.eu/~pve/lxch_pve_release.gpg
```

- Add my repo to your sources:

```
echo "deb http://repo.lxch.eu/~pve/debian buster-pvetest/" | sudo tee /etc/apt/sources.list.d/buster-pvetest.list
```

- apt update and apt install proxmox-ve

```
apt update && apt install proxmox-ve
```

### After the install is through you should see the following:

- $ pveversion -v

```
proxmox-ve: 5.1-42 (running kernel: 4.15.15-1-pve)
pve-manager: 5.1-51 (running version: 5.1-51/96be5354)
pve-kernel-4.15: 5.1-3
pve-kernel-4.15.15-1-pve: 4.15.15-6
corosync: 2.4.2-pve4
criu: 3.8.1-1~bpo01
glusterfs-client: 4.0.1-1
ksm-control-daemon: 1.2-2
libjs-extjs: 6.0.1-2
libpve-access-control: 5.0-8
libpve-apiclient-perl: 2.0-4
libpve-common-perl: 5.0-30
libpve-guest-common-perl: 2.0-14
libpve-http-server-perl: 2.0-8
libpve-storage-perl: 5.0-18
libqb0: 1.0.3-1
lvm2: 2.02.176-4.1
lxc-pve: 3.0.0-2
lxcfs: 3.0.0-1
novnc-pve: 0.6-4
proxmox-widget-toolkit: 1.0-15
pve-cluster: 5.0-25
pve-container: 2.0-21
pve-docs: 5.1-17
pve-firewall: 3.0-8
pve-firmware: 2.0-4
pve-ha-manager: 2.0-5
pve-i18n: 1.0-4
pve-libspice-server1: 0.12.8-3
pve-qemu-kvm: 2.11.1-5
pve-xtermjs: 1.0-3
qemu-server: 5.0-25
smartmontools: 6.5+svn4324-1
spiceterm: 3.0-5
vncterm: 1.5-3
```