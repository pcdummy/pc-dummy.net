---
date: 2015-06-10T13:00:00+01:00
title: My installation of Ubuntu Mate 15.04 (Vivid)
author: pcdummy
tags:
  - HOWTO
  - Ubuntu
  - My Installation
  - Crypto root
  - BTRFS
  - lxc
---
This is my own documentation of my installation, i assume you have installed
[Ubuntu Mate 14.10](/2015/04/05/install-ubuntu-trusty/) before.

**Grub** + **cryptoroot** + **BTRFS** works a lot better with **Vivid**, yeah!

#### Features

* Latest Ubuntu Mate
* Encrypted disk
* BTRFS root, home and stuff i keep between sys updates.<!--more-->

#### Install Linux from a livecd
* Start from the livecd
* Go to Control Center->Hardware->Keyboard and set the keyboard to german nodeadkeys
* connect to the internet

#### Get root and install BTRFS Tools

    sudo -s -H
    apt-get -y install btrfs-tools

#### Decrypt the root

    cryptsetup --allow-discards luksOpen /dev/sda2 root

#### Create the root subvolume

    mkdir /mnt/btrfs
    mount -o subvolid=0,compress=lzo,recovery,noatime /dev/mapper/root /mnt/btrfs
    btrfs subvolume create /mnt/btrfs/\@ubuntu_15.04

#### Mount the new Subvolume to /target

  	mkdir /target
  	mount -o subvol=@ubuntu_15.04,compress=lzo,recovery,noatime /dev/mapper/root /target
  	mkdir -p /target/var/lib/lxc
  	mkdir -p /target/opt/mono
  	mkdir -p /target/mnt/btrfs

#### Rsync /rofs to /target

    rsync -avP /rofs /target

#### Copy stuff from 14.10 to 15.04

    cp /etc/mtab /target/etc/

    export from='/mnt/btrfs/@ubuntu_14.10'
    cp -a $from/etc/hosts /target/etc/
    cp -a $from/etc/hostname /target/etc/
    cp -a $from/etc/sysctl.conf /target/etc/
    cp -a $from/etc/sudoers /target/etc/
    cp -a $from/etc/crypttab /target/etc/
    cp -a $from/etc/fstab /target/etc/
    sed -i -e's/@ubuntu_14.10/@ubuntu_15.04/' /target/etc/fstab
    cp -a $from/etc/data_luks.key /target/etc/
    cp -a $from/etc/initramfs-tools/modules /target/etc/initramfs-tools
    cp -a $from/etc/NetworkManager/system-connections/* /etc/NetworkManager/system-connections/
    cp -pfra $from/etc/NetworkManager/dnsmasq.d/* /target/etc/NetworkManager/dnsmasq.d/
    cp -a $from/etc/samba/smb.conf /target/etc/samba/
    rsync -avP $from/etc/libvirt/ /target/etc/libvirt/

#### Chroot to /target

    mount -o bind,rw /dev /target/dev
    mount -o bind,rw /proc /target/proc
    mount -o bind,rw /sys /target/sys
    mount -o bind,rw /dev/pts /target/dev/pts
    mount -o bind,rw /run /target/run

    chroot /target /bin/bash

    export TARGET_USERNAME=$SUDO_USER
    rm -f /usr/lib/locale/locale-archive
    locale-gen de_AT.UTF-8 en_US.UTF-8 de_AT en_US
    update-locale LANG=de_AT.UTF-8
    export LANG=de_AT.UTF-8
    dpkg-reconfigure keyboard-configuration
    dpkg-reconfigure tzdata

#### Make sure dhclient never updates resolv.conf
See: http://www.cyberciti.biz/faq/dhclient-etcresolvconf-hooks/

  	cat <<EOF > /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate
    #!/bin/sh
    make_resolv_conf(){
    	:
    }
    EOF
	  cat /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate # check

#### Create your user

	export TARGET_USERNAME="pcdummy"
	adduser --no-create-home ${TARGET_USERNAME}
	usermod -a --groups=sudo,cdrom,floppy,audio,dip,video,plugdev ${TARGET_USERNAME}
	passwd -l root
	usermod -a -G fuse ${TARGET_USERNAME}

#### Update the fresh install (still in chroot)

	sed -i -e's/archive.ubuntu/ch.archive.ubuntu/g' /etc/apt/sources.list
	apt-get update && apt-get -yy dist-upgrade

#### Update grub.

	cat <<'EOF' > /etc/default/grub
	GRUB_DEFAULT=0
	GRUB_TIMEOUT=10
	GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
	GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 kopt=root=/dev/mapper/root quiet splash"
	#GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:root"
	GRUB_ENABLE_CRYPTODISK=y
	GRUB_PRELOAD_MODULES="luks cryptodisk gcry_rijndael gcry_sha1"
	EOF'

	update-grub

#### My favorite console text editor and aptitude.

	apt-get -yy install vim vim-scripts aptitude
	update-alternatives --set editor /usr/bin/vim.basic

#### Remove live installer

	apt-get -yy purge casper ubiquity && apt-get -yy autoremove


#### German Language packs and suggestions

	apt-get -yy install firefox-locale-de libreoffice-l10n-de thunderbird-locale-de hyphen-de libreoffice-help-de mythes-de thunderbird-gnome-support ttf-lyx myspell-de-at


#### Nvidia driver.

	apt-get update
	apt-get -yy install nvidia-settings nvidia-current
	nvidia-xconfig --no-logo

#### Install usefull stuff.
Speed :)

    sudo apt-get -y install readahead-fedora preload nscd

#### Reboot

	reboot


#### Gnome-encfs-manager

	sudo add-apt-repository -y ppa:gencfsm/ppa
	sudo apt-get update
	sudo apt-get -y install gnome-encfs-manager

#### [Atom](https://atom.io/) text editor
[He](http://www.atomtips.com/atom-editor-vs-sublime-text/) explains my reasons to switch to Atom from Sublime quiet good

    sudo add-apt-repository -y ppa:webupd8team/atom
    sudo apt-get update
    sudo apt-get -y install atom nodejs git

#### Geany text editor

sudo aptitude install 'geany-plugins' geany-plugin-py geany-plugin-treebrowser geany-plugin-vc

#### Evernote on Linux

funktioniert nicht
.    sudo add-apt-repository -y ppa:vincent-c/nevernote
.    sudo apt-get update
.    sudo apt-get -y install nixnote

#### Virtual development environment

	sudo add-apt-repository -y ppa:jacob/virtualisation
    sudo add-apt-repository -y ppa:ubuntu-lxc/lxc-stable
    sudo apt-get -y install libvirt-bin virt-manager qemu qemu-kvm qemu-system spice-client python-spice-client-gtk bridge-utils ebtables virt-top
    sudo apt-get -y install lxc cgmanager uidmap lxc-templates
    sudo apt-get -y install system-config-samba # To setup sharing's for windows guests.
    sudo usermod -a -G libvirtd $SUDO_USER

#### Playing with OpenVSwitch

    sudo apt-get -y install openvswitch-switch ethtool

#### Git repository viewer

    sudo apt-get -y install git-cola fldiff

#### KeePass 2: Password manager

    sudo add-apt-repository -y ppa:dlech/keepass2-plugins
    sudo apt-get update
    sudo apt-get -y install keepass2 mono-dmcs mono-complete libmono-system-management4.0-cil keepass2-plugin-rpc xul-ext-keefox xul-ext-keebird keepass2-plugin-keepasshttp

#### Go Development with [gvm](https://github.com/moovweb/gvm)
install deps:

    sudo apt-get install curl git mercurial make binutils bison gcc build-essential

#### Python Development with [PyEnv](https://github.com/yyuu/pyenv-installer)
Nice howto on that from [davebehnke.com](http://davebehnke.com/python-pyenv-ubuntu.html)

    sudo apt-get -y install python3-pip python3-dev python3-wheel python-tox python3-nose python3-coverage make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm

   sudo add-apt-repository -y ppa:ytvwld/syncthing
    sudo add-apt-repository -y ppa:nilarimogard/webupd8
    sudo apt-get update
    sudo apt-get -y install syncthing syncthing-gtk

#### Quassel IRC Client (git/development version!). I have a quassel-core (means server) somewhere in the wild.

    sudo add-apt-repository -y ppa:mamarley/quassel-git
    sudo apt-get update
    sudo apt-get -y install quassel-client

#### Skype

    sudo dpkg --add-architecture i386
    sudo apt-get update
    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
    sudo dpkg -i skype-install.deb; sudo apt-get -f install
    rm -f skype-install.deb

#### Remote desktop (RDP+VNC) clients/managers - i use gnome-rdp and remmina (slowly switching over to remmina).

    sudo apt-get -y install gnome-rdp remmina-plugin-rdp remmina-plugin-vnc libfreerdp-plugins-standard rdesktop xtightvncviewer

#### OpenVPN client

    sudo apt-get -y install network-manager-openvpn-gnome

#### IPSec client

    sudo apt-get -y install network-manager-vpnc-gnome

#### Tranmission Remote (for my apu1d4 :) )

	  sudo apt-get -y install transmission-remote-gtk

#### PHP Dev

    sudo apt-get -y install php5-cli php5-pear php-dev php-apc

#### Java Web start (for Cisco ASDM)

    sudo apt-get -y install icedtea-7-plugin

#### Citrix Receiver

Goto https://receiver.citrix.com and download the .deb version

    pushd .
    cd Downloads
    sudo dpkg -i icaclient_13.1.0.285639_amd64.deb; sudo apt-get install -f
    popd


#### Audiograbber on Linux

    sudo apt-get -y install install sound-juicer

#### Audio file tag editor

    sudo apt-get -y install puddletag

#### Softether VPN

    sudo add-apt-repository -y ppa:paskal-07/softethervpn
    sudo sed -i -e's|vivid|trusty|g' /etc/apt/sources.list.d/paskal-07-ubuntu-softethervpn-vivid.list
    sudo apt-get update
    sudo apt-get -y install softether-vpnclient

    sudo vpnclient start


Create a VPN connection:

    pcdummy@ThinkPad-T410:~$ vpncmd
    vpncmd command - SoftEther VPN Command Line Management Utility
    SoftEther VPN Command Line Management Utility (vpncmd command)
    Version 4.17 Build 9562   (English)
    Compiled 2015/05/30 17:41:38 by yagi at pc30
    Copyright (c) SoftEther VPN Project. All Rights Reserved.

    By using vpncmd program, the following can be achieved.

    1. Management of VPN Server or VPN Bridge
    2. Management of VPN Client
    3. Use of VPN Tools (certificate creation and Network Traffic Speed Test Tool)

    Select 1, 2 or 3: 2

    Specify the host name or IP address of the computer that the destination VPN Client is operating on.
    If nothing is input and Enter is pressed, connection will be made to localhost (this computer).
    Hostname of IP Address of Destination:

    Connected to VPN Client "localhost".

    VPN Client>AccountCreate
    AccountCreate command - Create New VPN Connection Setting
    Name of VPN Connection Setting: pcdummy.lan

    Destination VPN Server Host Name and Port Number: apu1d4.home.pc-dummy.net:8888

    Destination Virtual Hub Name: vpn.pcdummy.lan

    Connecting User Name: jochumr

    Used Virtual Network Adapter Name: 0

    The command completed successfully.


Create a Password:

    VPN Client>Accountpasswordset
    AccountPasswordSet command - Set User Authentication Type of VPN Connection Setting to Password Authentication
    Name of VPN Connection Setting: pcdummy.lan

    Please enter the password. To cancel press the Ctrl+D key.

    Password: ********************
    Confirm input: ********************


    Specify standard or radius: standard

    The command completed successfully.


Connect the newly created "Account":

    AccountConnect pcdummy.lan


#### Wine with 32bit default

    sudo apt-get -y install wine1.7 wine-gecko:i386 wine-mono:i386

    # Set wine to 32bit by default
    cat <<EOF >> ~/.profile

    # Set wine to 32bit
    WINEARCH=win32
    WINEPREFIX=$HOME/.wine32
    EOF

    source $HOME/.profile

#### Filezilla

    sudo apt-get -y install filezilla

#### Google Chrome OpenSource - Chromium

    sudo apt-get -y install chromium-browser chromium-browser-l10n

#### Google Chrome

    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    sudo apt-get -y install google-chrome-stable

#### Salt client

    sudo add-apt-repository -y ppa:saltstack/salt
    sudo apt-get update
    sudo apt-get -qy install salt-minion

#### Misc

    sudo apt-get -y install sshfs unrar screen pwgen whois uuid

#### LXC (Linux Container)

    sudo add-apt-repository -y ppa:ubuntu-lxc/stable
    sudo apt-get update
    sudo apt-get -y install lxc lxctl cgmanager uidmap

Default NAT Bridge:

    sudo sh -c 'cat <<EOF > /etc/default/lxc-net
    USE_LXC_BRIDGE="true"
    LXC_BRIDGE="mlabnatbr0"
    LXC_ADDR="10.167.161.1"
    LXC_NETMASK="255.255.255.0"
    LXC_NETWORK="10.167.161.0/24"
    LXC_DHCP_RANGE="10.167.161.100,10.167.161.254"
    LXC_DHCP_MAX="153"
    LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
    LXC_DOMAIN="mlabnat.pcdummy.lan"
    EOF'


By default other lxc hosts will go over my NAT interface:

    sudo sed -i -e's|lxc.network.link = lxcbr0|lxc.network.link = mlabnatbr0|' /etc/lxc/default.conf

Make `mlabnatbr0` the default for lxc:

    sudo sh -c 'cat <<EOF > /etc/lxc/default.conf
    lxc.network.type = veth
    lxc.network.link = mlabnatbr0
    lxc.network.flags = up
    lxc.network.hwaddr = 00:16:3e:xx:xx:xx
    EOF'

Install and configure radvd and dnsmasq for lxc `mlabnatbr0`:

    sudo apt-get -y install radvd
    sudo sh -c 'cat <<EOF > /etc/radvd.conf
    interface mlabnatbr0
    {
       # Advertise
       AdvSendAdvert on;

       # Maximum time between RAs
       MaxRtrAdvInterval 60;

       AdvManagedFlag on;

       prefix fd57:c87d:f1ee:ee01::1/64
       {
            # We are the only router. If we shut down, nobody else can route
            # this prefix -- tell clients about this.
            DeprecatePrefix on;
       };
    };
    EOF'

    sudo sh -c 'cat <<EOF > /etc/lxc/dnsmasq.conf
    dhcp-range=::add:0:0:100,::add:0:0:1e3, constructor:mlabnatbr0, 12h

    dhcp-option=option:all-subnets-local,1
    dhcp-option=option6:dns-server,[::]
    dhcp-option=option6:ntp-server,[::]
    dhcp-option=option:domain-search,mlabnat.pcdummy.lan
    EOF'

Create the lxd user and give him some permissions:

    sudo useradd -r -d /var/lib/lxd -s /bin/bash lxd # /bin/bash so i can "ssh lxd@localhost"
    sudo usermod -a -G lxd pcdummy
    # Give lxd 99 uid/gid ranges to map.
    for i in {1..99}; do
    	sudo usermod --add-subuids ${i}00000-${i}65536 lxd
    	sudo usermod --add-subgids ${i}00000-${i}65536 lxd
    done # This takes a while
    sudo mkdir /var/lib/lxd
    sudo chown lxd:lxd /var/lib/lxd
    sudo sudo -H -u lxd mkdir -p /var/lib/lxd/.config/lxc/
    sudo sudo -H -u lxd sh -c 'cat <<EOF > /var/lib/lxd/.config/lxc/default.conf
    lxc.include = /etc/lxc/default.conf
    lxc.id_map = u 0 100000 65537
    lxc.id_map = g 0 100000 65537
    EOF'

Allow userspace containers to use the network interfaces:

    echo 'lxd veth mlabnatbr0 100' | sudo tee -a /etc/lxc/lxc-usernet 1>/dev/null
    echo 'lxd veth mlabbr0 100' | sudo tee -a /etc/lxc/lxc-usernet 1>/dev/null

Restart lxc and lxc-net

    sudo service lxc stop
    sudo service lxc-net restart
    sudo service lxc start

For "ssh lxd@localhost"

    sudo apt-get -y install openssh-server
    sudo mkdir /var/lib/lxd/.ssh/
    sudo cp $HOME/.ssh/workkey.pub /var/lib/lxd/.ssh/authorized_keys
    sudo chown -R lxd:lxd /var/lib/lxd/.ssh/

#### Gimp

    sudo apt-get -y install gimp gimp-help-de gimp-plugin-registry

#### Rhythmbox [close on hide](http://askubuntu.com/a/454782)

    pushd .
    mkdir -p ~/.local/share/rhythmbox/plugins
    cd ~/.local/share/rhythmbox/plugins
    git clone https://github.com/fossfreedom/close-on-hide
    popd

  after close rhythmbox and open it again (real close), then enable
  the plugin, have fun.

#### DNS [.local fix](http://www.hexblot.com/blog/resolving-local-domains-linux)

At my employer we use a .local Domain, the above link shows you how to fix it.
