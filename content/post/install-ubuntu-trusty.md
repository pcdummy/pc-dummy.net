---
date: 2015-04-05T13:00:00+01:00
title: My installation of Ubuntu Mate 14.10 (Utopic)
author: pcdummy
tags:
  - HOWTO
  - Ubuntu
  - My Installation
  - Crypto root
  - BTRFS
  - lxc
---
This is my own documentation of my installation.

#### Features

* Latest Ubuntu Mate
* Encrypted disk
* BTRFS root, home and stuff i keep between sys updates.<!--more-->

#### General BTRFS stuff to read:

* [btrfs wiki](https://btrfs.wiki.kernel.org/index.php/UseCases)

#### This is based on:

* [archlinux wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system)
* [microhowto](http://www.microhowto.info/howto/create_an_encrypted_swap_area.html)
* [linux mint forums](http://forums.linuxmint.com/viewtopic.php?f=175&t=100659)
* [ubuntusers wiki](http://wiki.ubuntuusers.de/Installieren_auf_Btrfs-Dateisystem)
* [nyeggen blog (google cache)](http://webcache.googleusercontent.com/search?q=cache:WOnzknpei6YJ:nyeggen.com/blog/2014/04/05/full-disk-encryption-with-btrfs-and-multiple-drives-in-ubuntu+btrfs+luks&cd=2&hl=de&ct=clnk&gl=ch)
* [Philip Beck`s blog](http://blog.philippbeck.net/linux/archlinux-install-encryption-lvm-luks-grub2-69)
* [Netzgewitter blog](http://www.netzgewitter.com/2011/09/how-to-install-linux-mint-debian-edition-lmde-on-an-encrypted-hard-drive/)
* [kubuntu forums (google cache)](http://webcache.googleusercontent.com/search?q=cache:TuoJ3OW95wgJ:https://www.kubuntuforums.net/archive/index.php/t-60321.html+&cd=1&hl=de&ct=clnk&gl=at&client=ubuntu)

#### Install Linux from a livecd
* Start from the livecd
* Go to Control Center->Hardware->Keyboard and set the keyboard to german nodeadkeys
* connect to the internet

#### Setup the partition table with gparted like this **TODO insert screnshot here**

#### Encrypt the partitions and format them

    sudo -s -H
    apt-get -y install btrfs-tools

    cryptsetup -c aes-xts-plain64 -y -s 512 luksFormat /dev/sda2
    cryptsetup -c aes-xts-plain64 -y -s 512 luksFormat /dev/sda5

    cryptsetup --allow-discards luksOpen /dev/sda2 root
    cryptsetup --allow-discards luksOpen /dev/sda5 data

    mkfs.ext3 /dev/sda1
    mkfs.btrfs -L root /dev/mapper/root

    mkfs.xfs -L data /dev/mapper/data
    mkswap /dev/sda6

    mount -o subvolid=0,compress=lzo,recovery,noatime /dev/mapper/root /mnt
    # My first crypto-btrfs system to install - Mint 17
    btrfs subvolume create /mnt/\@mint_17
    # For persitant homes across installations.
    btrfs subvolume create /mnt/\@home
    # For persistant lxc across installations.
    btrfs subvolume create /mnt/\@lxc
     For persistant lxd across installations.
    btrfs subvolume create /mnt/\@lxd
    # For persistant monodevelop across installations.
    btrfs subvolume create /mnt/\@mono
    umount /mnt

    swapon /dev/sda6

#### Create btrfs subvolumes and mount them

    mkdir /target
    mount -o subvol=@mint_17,compress=lzo,recovery,noatime /dev/mapper/root /target
    # One /home for all
    mkdir /target/home
    mount -o subvol=@home,compress=lzo,recovery,noatime /dev/mapper/root /target/home
    # One LXC for all.
    mkdir -p /target/var/lib/lxc
    mount -o subvol=@lxc,compress=lzo,recovery,noatime /dev/mapper/root /target/var/lib/lxc
    # One LXD for all.
    mkdir -p /target/var/lib/lxd
    mount -o subvol=@lxd,compress=lzo,recovery,noatime /dev/mapper/root /target/var/lib/lxd
    # One docker for all.
    mkdir -p /target/var/lib/docker
    mount -o subvol=@docker,compress=lzo,recovery,noatime /dev/mapper/root /target/var/lib/docker
    # One /opt/mono for all installations.
    mkdir -p /target/opt/mono
    mount -o subvol=@mono,compress=lzo,recovery,noatime /dev/mapper/root /target/opt/mono
    mkdir -p /target/mnt/btrfs
    # XFS /data for virtualisation images, i've read somewhere that btrfs and images aren't friends.
    mkdir /target/data
    mount /dev/mapper/data /target/data

#### Copy the livecd linux to /target

    rsync -avP /rofs/ /target/

#### Copy stuff from the backup to the /target

    cp /media/mint/Backup_T410/backintime/ThinkPad-T410/root/1/last_snapshot/backup/etc/hosts /target/etc/
    cp /media/mint/Backup_T410/backintime/ThinkPad-T410/root/1/last_snapshot/backup/etc/hostname /target/etc/
    cp /media/mint/Backup_T410/backintime/ThinkPad-T410/root/1/last_snapshot/backup/etc/sysctl.conf /target/etc/
    cp /media/mint/Backup_T410/backintime/ThinkPad-T410/root/1/last_snapshot/backup/etc/sudoers /target/etc/

#### Prepare to chroot into /target

    mount -o bind,rw /dev /target/dev
    mount -o bind,rw /proc /target/proc
    mount -o bind,rw /sys /target/sys
    mount -o bind,rw /dev/pts /target/dev/pts
    mount -o bind,rw /run /target/run

#### Chroot into /target

    chroot /target
    	export TARGET_USERNAME=pcdummy
    	locale-gen de_AT.UTF-8
    	dpkg-reconfigure locales
    	update-locale LANG=de_AT.UTF-8
    	export LANG=de_AT.UTF-8
    	locale-gen --purge --no-archive
    	dpkg-reconfigure keyboard-configuration
    	dpkg-reconfigure tzdata

    	# Update package list
    	apt-get update

    	apt-get -y install vim vim-scripts
    	update-alternatives --set editor /usr/bin/vim.basic

    	# Recent kernel
    	apt-get purge -y linux-image-generic
    	apt-get -y install -y linux-image-generic-lts-utopic linux-headers-generic-lts-utopic

    	# Add another key for "data", to automount it, you can remove your "setup"
    	# password on /dev/sda5 later if you want.
    	tr -dc '0-9a-zA-Z' </dev/urandom | head -c 32 > /etc/data_luks.key
    	chmod 600 /etc/data_luks.key; chown root:root /etc/data_luks.key
    	cryptsetup luksAddKey /dev/sda5 /etc/data_luks.key

    	# Configure /etc/fstab
    	cat <<EOF > /etc/fstab && editor /etc/fstab
    # /etc/fstab: static file system information.
    #
    # Use 'blkid' to print the universally unique identifier for a
    # device; this may be used with UUID= as a more robust way to name devices
    # that works even if disks are added and removed. See fstab(5).
    #
    # <file system>				  				<mount point>   <type>  <options>       <dump>  <pass>
    /dev/mapper/root                               /                btrfs    subvol=@mint_17,compress=lzo,recovery,noatime,user_subvol_rm_allowed    0    0
    /dev/mapper/root                               /home            btrfs    subvol=@home,compress=lzo,recovery,noatime 0    0
    /dev/mapper/root                               /opt/mono        btrfs    subvol=@mono,compress=lzo,recovery,noatime 0    0
    /dev/mapper/root                               /var/lib/lxc     btrfs    subvol=@lxc,compress=lzo,recovery,noatime 0    0
    /dev/mapper/root                               /var/lib/lxd     btrfs    subvol=@lxd,compress=lzo,recovery,noatime,user_subvol_rm_allowed 0    0
    /dev/mapper/root                               /var/lib/docker  btrfs    subvol=@docker,compress=lzo,recovery,noatime 0    0
    /dev/mapper/data                               /data            xfs      noatime,nobootwait     0    0
    /dev/mapper/swap                               none             swap     defaults    0    0

    /dev/mapper/root                               /mnt/btrfs       btrfs    subvolid=0,compress=lzo,recovery,noatime,noauto 0    0
    EOF

    	# You might want to read more about the 'discard' option i use here.
    	# http://asalor.blogspot.co.at/2011/08/trim-dm-crypt-problems.html
    	# https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard.2FTRIM_support_for_solid_state_drives_.28SSD.29
    	cat <<EOF > /etc/crypttab && editor /etc/crypttab
    # <target name> <source device>                 <key file>           <options>
    root UUID=c1a685f1-d614-4694-a14c-f5dd8d646740  none                 luks,discard,tries=10
    data UUID=fa2b8b2a-c59b-4394-9c1d-89665450231d  /etc/data_luks.key   luks,discard
    swap /dev/sda6                                  /dev/urandom         swap,discard
    EOF

    	cat <<EOF > /etc/initramfs-tools/modules && editor /etc/initramfs-tools/modules
    # List of modules that you want to include in your initramfs.
    # They will be loaded at boot time in the order below.
    #
    # Syntax:  module_name [args ...]
    #
    # You must run update-initramfs(8) to effect this change.
    #
    # Examples:
    #
    # raid1
    # sd_mod
    uvesafb mode_option=1024x768-24 mtrr=3 scroll=ywrap
    dm-crypt
    dm-mod
    xts
    aes
    aes-cbc-essiv
    aes-x86_64
    sha256_generic
    sha512_generic
    lvm
    ahci
    usbcore
    uhci_hcd
    ehci_hcd
    usbhid
    EOF

    	# Enable your KEYMAP while entering the crypto password
    	echo "\nKEYMAP=y" >> /etc/initramfs-tools/initramfs.conf

    	# !Dont do that on systems without nvidia/ati cards or if you want opensource drivers!
    	apt-get purge xserver-xorg-video-ati xserver-xorg-video-glamoregl xserver-xorg-video-intel xserver-xorg-video-neomagic xserver-xorg-video-nouveau xserver-xorg-video-radeon xserver-xorg-video-sisusb xserver-xorg-video-trident xserver-xorg-video-vmware xserver-xorg-video-all

    	# Don't do this if this is a vbox guest.
    	apt-get remove --purge virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

    	# Update the fresh install
    	apt-get dist-upgrade

    	# Btrfs tools
    	apt-get -y install btrfs-tools

    	# German Language packs
    	apt-get -y install firefox-l10n-de libreoffice-l10n-de thunderbird-l10n-de

    	adduser ${TARGET_USERNAME}
    	usermod -a --groups=sudo,cdrom,floppy,audio,dip,video,plugdev ${TARGET_USERNAME}
    	passwd -l root
    	usermod -a -G fuse,sambashare ${TARGET_USERNAME}

    	# Nvidia driver.
    	apt-get update
    	apt-get -y install nvidia-settings nvidia-current
    	nvidia-xconfig --no-logo

    	# Make sure dhclient never updates resolv.conf
    	# See: http://www.cyberciti.biz/faq/dhclient-etcresolvconf-hooks/
    	cat <<EOF > /etc/dhcp/dhclient-enter-hooks.d/nodnsupdatele
    #!/bin/sh
    make_resolv_conf(){
    	:
    }
    EOF
    	cat /etc/dhcp/dhclient-enter-hooks.d/nodnsupdate # check

    	editor /etc/default/grub
    		GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory_swapaccount=1"
    		GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:root"

        # Fix troubles with intel powerclamp (unresponsive ui on high load):
        cat <<EOF > /etc/modprobe.d/blacklist-power.conf
        # See: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1389077
        blacklist intel_powerclamp
        blacklist intel_rapl
        EOF

    	update-initramfs -k all -u
    	update-grub

    	grub-install /dev/sda

    	exit

#### Restore latest backintime backup of /home

    export TARGET_USERNAME=pcdummy
    rsync -avP /media/mint/Backup_T410/backintime/ThinkPad-T410/root/1/last_snapshot/backup/home/${TARGET_USERNAME}/ /target/home/${TARGET_USERNAME}/
    mkdir /target/home/${TARGET_USERNAME}/exchange
    chown -R 1000:1000 /target/home/${TARGET_USERNAME}

#### Reboot

    sync
    reboot

#### Install usefull stuff.
Speed :)

    sudo apt-get -y install readahead-fedora preload

#### Mate Desktop
You can savely skip this step if you installed with your system with the ubuntu-mate dvd

    sudo apt-add-repository -y ppa:ubuntu-mate-dev/ppa
    sudo apt-get update
    sudo apt-get install -y ubuntu-mate-desktop
    sudo apt-get install -y synaptic

Mate tool:

     sudo apt-get -y install mate-tweak mate-utils

Mint Menu, [found here](https://webcache.googleusercontent.com/search?q=cache:mBkdLXwuIO0J:linuxg.net/how-to-install-mintmenu-5-5-2-on-ubuntu-mate-14-10-and-ubuntu-mate-14-04/+&cd=4&hl=de&ct=clnk&gl=at&client=ubuntu)

    pushd .
    sudo apt-get -y install gdebi
    cd $HOME/Software
    wget ppa.launchpad.net/eugenesan/ppa/ubuntu/pool/main/m/mintmenu/mintmenu_5.5.2-0~eugenesan~trusty1_all.deb
    sudo gdebi mintmenu_5.5.2-0~eugenesan~trusty1_all.deb
    popd

    sudo apt-get -y install mate-menu

Applets [mate-applets](https://github.com/mate-desktop/mate-applets) and [mate-netspeed](https://github.com/mate-desktop/mate-netspeed)

    sudo apt-get -y install mate-applets mate-netspeed mate-system-monitor

User share(s) (over samba)

    sudo apt-get -y install caja-share

Usefull caja plugins

    sudo apt-get -y install caja-gksu caja-sendto


#### Replace /bin/sh (dash) with /bin/bash so advanced .bash_profile scripts work
I had the problem with "gvm" a while, it's very bash specific and without it i don't have a GOPATH,
which is very bad in conjunction with the Atom plugins i use.

    sudo sed -i -e's|#!/bin/sh|#!/bin/bash --login|' /etc/gdm/Xsession
    sudo sed -i -e's|#!/bin/sh|#!/bin/bash --login|' /etc/mdm/Xsession
    mv $HOME/.profile $HOME/.bash_profile


#### Samba for (caja|nemo)-share [ubuntuusers wiki (german)](http://wiki.ubuntuusers.de/Samba_Server/net_usershare)

    sudo cp /usr/share/samba/smb.conf /etc/samba/

Don't do that if you want samba accessible from other computers (M$ ones as example).
!Let samba listen only on the virt hostonly interface!

    sudo sed -i -e's/interfaces = 127.0.0.0/8 eth0/interfaces = 127.0.0.0/8 192.168.100.1/' /etc/samba/smb.conf
    sudo sed -i -e's/unix password sync = yes/unix password sync = no/' /etc/samba/smb.conf
    sudo sed -i -e's/;   usershare max shares = 100/   usershare max shares = 100/' /etc/samba/smb.conf
    sudo sed -i -e's/;   bind interfaces only = yes/   bind interfaces only = yes/' /etc/samba/smb.conf
    sudo service smbd restart
    sudo service nmbd restart

#### Virtual development environment

    sudo add-apt-repository -y ppa:apparmor-dev/apparmor-backports
    sudo add-apt-repository -y ppa:jacob/virtualisation
    sudo add-apt-repository -y ppa:ubuntu-lxc/daily
    sudo apt-get update
    sudo apt-get -y install libvirt-bin virt-manager qemu qemu-kvm qemu-system spice-client python-spice-client-gtk bridge-utils ebtables virt-top
    sudo apt-get -y install lxc cgmanager uidmap lxc-templates
    sudo apt-get -y install system-config-samba # To setup sharing's for windows guests.
    sudo usermod -a -G libvirtd $SUDO_USER

Playing with OpenVSwitch

    sudo apt-get -y install openvswitch-switch ethtool

Copy configurations of storages,networks and hosts from the backup.

    service libvirt-bin stop
    sudo rsync -avP --delete /media/pcdummy/Backup_T410/backintime/ThinkPad-T410/root/1/last_snapshot/backup/etc/libvirt /etc/libvirt/

Link libvirt images to data

    sudo mkdir /data/libvirt-images
    sudo chown libvirt-qemu:kvm /data/libvirt-images
    sudo chmod 700 /data/libvirt-images
    sudo rm -rf /var/lib/libvirt/images
    sudo ln -s /data/libvirt-images /var/lib/libvirt/images
    service libvirt-bin start

Libvirt optimisations take from [Peter Kieser`s blog](https://peterkieser.com/2014/06/27/new-kvm-deployment-bugs-and-recommendations-ubuntu-14-04-qemu-2-0-libvirt-1-2-4-linux-3-10/)

    sudo cat <<EOF >> /etc/sysctl.conf
    # KVM Tunning, see: https://peterkieser.com/2014/06/27/new-kvm-deployment-bugs-and-recommendations-ubuntu-14-04-qemu-2-0-libvirt-1-2-4-linux-3-10
    kernel.sched_min_granularity_ns=10000000
    kernel.sched_wakeup_granularity_ns=15000000
    vm.dirty_ratio=10
    vm.dirty_background_ratio=5
    vm.swappiness=10
    EOF
    sudo sysctl -f /etc/sysctl.conf

    echo "options vhost_net experimental_zcopytx=0" | tee -a /etc/modprobe.d/vhost-net.conf > /dev/null
    sudo modprobe vhost_net experimental_zcopytx=0

    sudo sed -i -e's|VHOST_NET_ENABLED=0|VHOST_NET_ENABLED=1|' /etc/default/qemu-kvm
    sudo service qemu-kvm restart

Flockport

    pushd .
    cd $HOME/Downloads
    wget http://repo.flockport.com/debian/pool/main/f/flockport/flockport_0.1.0_all.deb
    sudo dpkg -i flockport_0.1.0_all.deb; apt-get -y install -f
    popd

My bridge where i ran all these virtualisation stuff over.

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

Do not start dnsmasq on the mlabnatbr0.

    sudo sed -i -e's|except-interface=lxcbr0|except-interface=mlabnatbr0|' /etc/dnsmasq.d-available/lxc

Make mlabnatbr0 the default for lxc

    sudo sh -c 'cat <<EOF > /etc/lxc/default.conf
    lxc.network.type = veth
    lxc.network.link = mlabnatbr0
    lxc.network.flags = up
    lxc.network.hwaddr = 00:16:3e:xx:xx:xx
    EOF'

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

Bridge for my firewall inside lxc, follow this [guide](https://www.happyassassin.net/2014/07/23/bridged-networking-for-libvirt-with-networkmanager-2014-fedora-21/)

HostOnly bridges for my firewall running inside lxc

    sudo sh -c 'cat <<EOF > /etc/network/interfaces.d/mlablanbr0
    auto mlablanbr0
    iface mlablanbr0 inet static
        address 10.167.162.254
        netmask 255.255.255.0
        broadcast 10.167.162.255
        bridge_ports none
        bridge_fd 0
        bridge_waitport 0
        bridge_stp off
    iface mlablanbr0 inet6 static
        address fd57:c87d:f1ee:ee02:d:e:f:254
        netmask 64
    EOF'
    sudo ifup mlablanbr0
    echo 'lxd veth mlablanbr0 100' | sudo tee -a /etc/lxc/lxc-usernet 1>/dev/null

By default other lxc hosts will go over my firewall inside lxc.

    sudo sed -i -e's|lxc.network.link = lxcbr0|lxc.network.link = mlablanbr0|' /etc/lxc/default.conf

Another HostOnly bridge for testing stuff (basicaly i'm testing OSPF and OSPFv3 over it)

    sudo sh -c 'cat <<EOF > /etc/network/interfaces.d/mlabgwbr0
    auto mlabgwbr0
    iface mlabgwbr0 inet static
        address 10.167.163.254
        netmask 255.255.255.0
        broadcast 10.167.163.255
        bridge_ports none
        bridge_fd 0
        bridge_waitport 0
        bridge_stp off
    EOF'
    sudo ifup mlabgwbr0
    echo 'lxd veth mlabgwbr0 100' | sudo tee -a /etc/lxc/lxc-usernet 1>/dev/null

Restart lxc-net, radvd and lxc itself

    sudo service lxc-net restart
    sudo service radvd restart
    sudo service lxc restart

#### Evernote on Linux

    sudo add-apt-repository -y ppa:vincent-c/nevernote
    sudo apt-get update
    sudo apt-get -y install nixnote

#### Git repository viewer

    sudo apt-get -y install git-cola fldiff

#### KeePass 2: Password manager

    sudo add-apt-repository -y ppa:dlech/keepass2-plugins
    sudo apt-get update
    sudo apt-get -y install keepass2 mono-dmcs mono-complete libmono-system-management4.0-cil keepass2-plugin-rpc xul-ext-keefox xul-ext-keebird keepass2-plugin-keepasshttp

#### Go Development with [gvm](https://github.com/moovweb/gvm)
install deps:

    sudo apt-get install curl git mercurial make binutils bison gcc build-essential

Install gvm (if you have my bashrc.d/) thing:

    GVM_NO_UPDATE_PROFILE=1 bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    echo 'source /home/pcdummy/.gvm/scripts/gvm' > $HOME/.bashrc.d/gvm
    chmod +x $HOME/.bashrc.d/gvm
    source $HOME/.bashrc.d/gvm

else:

    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    source /home/pcdummy/.gvm/scripts/gvm

Get go versions:

    gvm listall

Install a go version with gvm (latest at time of writing):

    gvm install 1.4.1

And "use" it:

    gvm use 1.4.1

Now you can install for example [hugo](https://github.com/spf13/hugo):

    go get -v github.com/spf13/hugo

#### Python Development with [PyEnv](https://github.com/yyuu/pyenv-installer)
Nice howto on that from [davebehnke.com](http://davebehnke.com/python-pyenv-ubuntu.html)

pip3, tox, nose and coverage and two python modules i use

    sudo apt-get -y install python3-pip python3-dev python3-wheel python-tox python3-nose python3-coverage
    sudo pip3 install datadiff
    sudo pip3 install testfixtures

Install pyenv and its requirements

    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm
    curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

Put in ~/.bashrc or if you have my bashrc.d/ thing in ~/.bashrc.d/pyenv

    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

If you have my ~/.bashrc.d/ thing

    chmod +x ~/.bashrc.d/pyenv

Activate pyenv and install the latest python available (at the time of writing)

    source $HOME/.bashrc.d/pyenv
    pyenv install 3.4.2

Use ```pyenv install -l``` to get a list of available versions.

To install pypy with pyenv

    pyenv install pypy3-2.4.0-src

#### Mono development environment

[Binary dist from simendjso.me](http://simendsjo.me/files/abothe/readme.txt)

    wget http://simendsjo.me/files/abothe/MonoDevelop.x64.Master.tar.xz
    sudo tar -xPf MonoDevelop.x64.Master.tar.xz -C /
    rm -f MonoDevelop.x64.Master.tar.xz

#### C++ editors

    sudo apt-get -y install eclipse-cdt qtcreator qtcreator-doc

#### Qt Tools

    sudo apt-get -y install qt4-dev-tools qt4-qmlviewer

#### [Syncthing](http://syncthing.net/)

    sudo add-apt-repository -y ppa:ytvwld/syncthing
    sudo add-apt-repository -y ppa:nilarimogard/webupd8
    sudo apt-get update
    sudo apt-get -y install syncthing syncthing-gtk

#### Encfs for syncthing
Additional security on my syncthing targets.
This is **considered as insecure** ... but better than plain, see [the audit from defuse.ca](https://defuse.ca/audits/encfs.htm)

    sudo add-apt-repository -y ppa:gencfsm/ppa
    sudo apt-get update
    sudo apt-get -y install  gnome-encfs-manager nemo-seahorse

#### ~~Dropbox~~
No more Dropbox, using Syncthing now.


    sudo apt-get -y purge dropbox
    sudo apt-get -y install caja-dropbox

Disable "Lan Sync" (opens port i don't want)

    caja-dropbox lansync n

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

#### SixXS Automatic IPv6 Connectivity Client Utility

    sudo apt-get -y install aiccu

##### NetworkManager + aiccu integration.

Activate the script you will get after for ``eth0``, ``wlan0`` und ``ppp0``

    echo "\n# NetworkManager restart when this interfaces go up/down." | sudo tee -a /etc/default/aiccu 1>/dev/null
    echo 'AICCU_RESTART_INTERFACES="eth0 wlan0 ppp0"' | sudo tee -a /etc/default/aiccu 1>/dev/null

Install the [script](https://gist.githubusercontent.com/pcdummy/71fb385761e8e5be6687/raw/99-aiccu.sh)

    pushd .
    cd $HOME/Downloads
    wget https://gist.githubusercontent.com/pcdummy/71fb385761e8e5be6687/raw/99-aiccu.sh
    sudo mv 99-aiccu.sh /etc/NetworkManager/dispatcher.d/
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-aiccu.sh
    sudo chmod 755 /etc/NetworkManager/dispatcher.d/99-aiccu
    popd

Disabled AICCU for now as i have it on my firewall.

    echo manual | sudo tee /etc/init/aiccu.override

#### OpenVPN client

    sudo apt-get -y install network-manager-openvpn-gnome

#### Remote desktop (RDP+VNC) clients/managers - i use gnome-rdp and remmina (slowly switching over to remmina).

    sudo apt-get -y install gnome-rdp remmina-plugin-rdp remmina-plugin-vnc libfreerdp-plugins-standard rdesktop xtightvncviewer

#### Fancy terminal with transparency.

    sudo apt-get -y install xfce4-terminal

Set xfce4 to the default terminal in gnome and cinnamon,
You can do this also by opening Systemsettings->preferred applicatons and editing "Terminal"

    gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/xfce4-terminal
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg "-x"
    gsettings set org.cinnamon.desktop.default-applications.terminal exec /usr/bin/xfce4-terminal
    gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg "-x"

Change "Ctrl+Shift+A" to "Ctrl+A" for byobu/tmux

    cat <<EOF > ~/.config/xfce4/terminal/accels.scm
    ; gnome-terminal GtkAccelMap rc-file         -*- scheme -*-
    (gtk_accel_path "<Actions>/terminal-window/select-all" "<Primary>a")
    EOF

#### Vagrant + virtualbox (vBox is widely used with vagrant), libvirt and lxc

    sudo apt-get -y install virtualbox-qt
    sudo apt-get -y install build-essential zlib1g-dev git-core
    sudo apt-get -y install bundler # for plugin development.

Download vagrant [here](https://dl.bintray.com/mitchellh/vagrant/)

    pushd .
    mkdir -p ~/Software && cd ~/Software
    curl -LO https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
    sudo dpkg -i vagrant_1.7.2_x86_64.deb; sudo apt-get -y install -f
    popd .

Installs the latest VBox additions to the guest

    vagrant plugin install vagrant-vbguest

Speeds up Vagrant Provisoning

    vagrant plugin install vagrant-cachier

KVM (with libvirt support) Plugin [vagrant-kvm](https://github.com/adrahon/vagrant-kvm/) and [vagrant-kvm issue #258](https://github.com/adrahon/vagrant-kvm/issues/258)

    sudo apt-get -y install apparmor-utils
    sudo aa-complain /usr/lib/libvirt/virt-aa-helper
    pushd .
    mkdir -p ~/Software && cd ~/Software
    git clone https://github.com/adrahon/vagrant-kvm.git
    cd vagrant-kvm
    ./install.rb   # Took ages.
    popd

Box [converter Plugin](https://github.com/sciurus/vagrant-mutate) (using it to convert vbox downloads to libvirt)

    vagrant plugin install vagrant-mutate

LXC Plugin [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc)

    vagrant plugin install vagrant-lxc

#### Moving stuff to the XFS on /data
Vagrant Boxes (its download) and tmp on XFS (you could extend this with ACLs for multi user support)

    sudo mkdir -p /data/vagrant/boxes
    sudo chown -R ${USERNAME}:${USERNAME} /data/vagrant/boxes
    ln -s /data/vagrant/boxes $HOME/.vagrant.d/boxes
    sudo mkdir -p /data/vagrant/${USERNAME}/tmp
    sudo chown -R ${USERNAME}:${USERNAME} /data/vagrant/${USERNAME}
    ln -s /data/vagrant/${USERNAME}/tmp $HOME/.vagrant.d/tmp

VirtualBox on XFS (i have all Hypervisor images on XFS)

    sudo mkdir -p /data/virtualbox/${USERNAME}
    sudo chown -R ${USERNAME}:${USERNAME} /data/virtualbox/${USERNAME}
    # Make a symbolic so you can access your virtualbox home by ~/VirtualBox\ VMs
    ln -s /data/virtualbox/${USERNAME} $HOME/VirtualBox\ VMs

REMEMBER You cannot run libvirt-bin (KVM/Qemu) and Virtualbox at the same time

to switch to virtualbox

    $ sudo service libvirt-bin stop

back to libvirt

    $ sudo service libvirt-bin start

#### Wine with 32bit default

    sudo add-apt-repository -y ppa:ubuntu-wine/ppa
    sudo apt-get update
    sudo apt-get -y install wine1.7

    # Set wine to 32bit by default
    cat <<EOF >> ~/.profile

    # Set wine to 32bit
    WINEARCH=win32
    WINEPREFIX=$HOME/.wine32
    EOF

    source $HOME/.profile

#### Ebook Manager (i use it to categorize my PDF's and sometimes to populate eBook Readers)

    sudo apt-get -y install calibre python-dnspython

#### Yumi: see [pendrivelinux](http://www.pendrivelinux.com/yumi-multiboot-usb-creator/)

* [Advanced YUMI Usage and Intro](https://smyl.es/tutorial-how-to-build-the-ultimate-custom-usb-drive-with-multiple-bootable-installs-for-windows-and-linux-and-portableapps-for-windows/)
* [HOWTO](https://appdb.winehq.org/objectManager.php?sClass=version&iId=31222)
* [Also nice for manual editing](http://techsoncall.wordpress.com/2013/02/21/how-to-create-a-multi-windows-usb-drive/)
I use windows on a VM to create the initial usb stick.

    mkdir $HOME/Software
    cd $HOME/Software
    wget http://www.pendrivelinux.com/downloads/YUMI/YUMI-2.0.1.2.exe

Start YUMI:

    wine $HOME/Software/YUMI-2.0.1.2.exe

#### Google Chrome OpenSource - Chromium

    sudo apt-get -y install chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg chromium-codecs-ffmpeg-extra

#### Proxydriver to set one proxy per network.

    pushd .
    mkdir $HOME/Software; cd $HOME/Software;
    wget https://raw.githubusercontent.com/jimlawton/proxydriver/master/proxydriver.sh
    chmod 755 proxydriver.sh
    sudo cp proxydriver.sh /etc/NetworkManager/dispatcher.d/99-proxydriver.sh
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-proxydriver.sh
    popd

#### Misc

    sudo apt-get -y install apt-rdepends apt-file atop tree ipython ipython3 dconf-editor iperf hashalot ppa-purge pwgen sysstat sysfsutils smbclient
    sudo apt-get -y install automake # for autotools based projects.
    sudo apt-get -y install cu # Serial Console Client

#### For Node.js based tools: https://www.npmjs.com/
Prerequisit for Atom.

    sudo apt-get -y install node npm

#### [Atom](https://atom.io/) editor
[He](http://www.atomtips.com/atom-editor-vs-sublime-text/) explains my reasons to switch to Atom from Sublime quiet good

    sudo add-apt-repository -y ppa:webupd8team/atom
    sudo apt-get update
    sudo apt-get -y install atom
    apm install project-manager
    apm install linter # https://atom.io/packages/linter
    apm install monokai
    apm install autocomplete-plus
    apm install git-control
    apm install merge-conflicts
    apm install clipboard-history
    apm install minimap
    apm install minimap-git-diff
    apm install go-to-line

Go (golang) autocomplete [go-plus](https://atom.io/packages/go-plus)

    go get -u -v github.com/nsf/gocode
    go get -u -v github.com/golang/lint/golint
    go get golang.org/x/tools/cmd/goimports
    apm install go-plus
    go get -u -v code.google.com/p/rog-go/exp/cmd/godef
    apm install godef
    go get code.google.com/p/go.tools/cmd/oracle
    apm install go-oracle

Python Flake8 linter for atom, i'm using the python3 variant as i develop for python 3.x

    sudo pip3 install flake8
    apm install linter-flake8

Python autocomplete for atom

    sudo apt-get -y purge python3-jedi python-jedi
    apm install autocomplete-jedi

Python import sorter
[python-isort](https://github.com/timothycrosley/isort)
[atom python-isor](https://atom.io/packages/python-isort)

    sudo pip install isort
    apm install python-isort

Navigator :)

    apm install atom-ctags

Upgrade all packages from time to time

    apm upgrade

#### Custom DNS for various "internal" Domains
[Found here](http://www.vojcik.net/configure-different-dns-resolvers-for-domains-in-ubuntu/), replace example*.local with your own domain(s).
One domain per entry.

    # First
    echo "server=/example1.local/2001:db8:dead:beef::71" | sudo tee -a /etc/NetworkManager/dnsmasq.d/example1.local 1>/dev/null
    # Second
    echo "server=/example2.local/2001:db8:dead:beef::71" | sudo tee -a /etc/NetworkManager/dnsmasq.d/example2.local 1>/dev/null
    sudo service network-manager restart

#### [LXD](https://github.com/lxc/lxd) Playing
    sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-daily
    sudo apt-get update
    sudo apt-get -y install lxc lxc-dev mercurial git pkg-config golang golang-go.tools

    mkdir -p ~/go
    echo "# Ubuntu GO\nexport GOPATH=~/go" >> $HOME/.profile
    source $HOME/.profile
    go get github.com/lxc/lxd
    cd $GOPATH/src/github.com/lxc/lxd
    go get -v -d ./...
    make

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

For "ssh lxd@localhost"

    sudo apt-get -y install openssh-server
    sudo mkdir /var/lib/lxd/.ssh/
    sudo cp $HOME/.ssh/workkey.pub /var/lib/lxd/.ssh/authorized_keys
    sudo chown -R lxd:lxd /var/lib/lxd/.ssh/

Networking for lxd

    echo 'lxd veth mlabnatbr0 100' | sudo tee -a /etc/lxc/lxc-usernet 1>/dev/null
    sudo service lxc restart

#### Enable .local resolving (for my Employers Network)
[Found here](http://www.hexblot.com/blog/resolving-local-domains-linux)

    set -i -e's/hosts:          files mdns4_minimal \[NOTFOUND=return\] dns/hosts:          files dns mdns4_minimal [NOTFOUND=return]/' /etc/nsswitch.conf

#### Disable gnome-keyring-daemon ssh component, see [this](http://dtek.net/blog/how-stop-gnome-keyring-clobbering-opensshs-ssh-agent-ubuntu-1204)

    sudo mv /etc/xdg/autostart/gnome-keyring-ssh.desktop /etc/xdg/autostart/gnome-keyring-ssh.desktop.disabled

#### IOZone and https://code.google.com/p/iozone-results-comparator

    sudo apt-get -y install iozone python-scipy python-matplotlib python-jinja2
    mkdir $HOME/Software
    cd $HOME/Software
    git clone https://code.google.com/p/iozone-results-comparator/

#### Firefox [Flash+Silverlight](http://www.webupd8.org/2013/08/pipelight-use-silverlight-in-your-linux.html) - Silverlight for Maxdome and other streamers.

    sudo add-apt-repository -y ppa:pipelight/stable
    sudo apt-get update
    sudo apt-get -y install --install-recommends pipelight-multi
    sudo pipelight-plugin --update
    pipelight-plugin --enable silverlight
    pipelight-plugin --enable flash

#### Citrix Receiver

Goto https://receiver.citrix.com and download the .deb version

    pushd .
    cd Downloads
    sudo dpkg -i icaclient_13.1.0.285639_amd64.deb; sudo apt-get install -f
    popd

#### [Bedup](https://github.com/g2p/bedup) testing

    sudo apt-get -y install python-pip
    test -d $HOME/bin || mkdir $HOME/bin
    sudo apt-get -y install libffi-dev
    pip install --user cffi
    cd $HOME/Software
    git clone git@github.com:g2p/bedup.git
    cd bedup/
    git submodule update --init

    # Fixing https://github.com/g2p/bedup/issues/55
    cat <<EOF | patch -p1
    diff --git a/bedup/migrations.py b/bedup/migrations.py
    index a5ddce1..8ef8dda 100644
    --- a/bedup/migrations.py
    +++ b/bedup/migrations.py
    @@ -49,5 +49,5 @@ def upgrade_schema(engine):
         else:
             current_rev = int(current_rev)
             upgrade_with_range(context, current_rev, REV)
    -    context._update_current_rev(current_rev, REV)
    +#    context._update_current_rev(current_rev, REV)
    EOF

    python setup.py install --user
    cp -lt ~/bin ~/.local/bin/bedup

Run it

    sudo ~/bin/bedup dedup


#### New btrfs send/receive backup's, see [btrfs-backup](https://github.com/lordsutch/btrfs-backup))
Make sure you have a copy of /dev/sdb's data, before you format it and change the disks label ``T410-Backup`` to something else.

    sudo cryptsetup -c aes-xts-plain64 -y -s 512 luksFormat /dev/sdb1
    sudo cryptsetup luksOpen /dev/sdb1 backup
    sudo mkfs.btrfs -L T410-Backup /dev/mapper/backup

    sudo mkdir /mnt/backup
    sudo mount -o subvolid=0,compress=lzo,noatime /dev/mapper/backup /mnt/backup
    sudo chown $USERNAME:$USERNAME /mnt/backup
    sudo btrfs subvolume create /mnt/backup/home
    sudo btrfs subvolume create /mnt/backup/utopic

Create a ``autoruns.sh`` backup script

    pushd .
    cd /mnt/backup

    wget https://raw.githubusercontent.com/lordsutch/btrfs-backup/master/btrfs-backup.py
    chmod +x btrfs-backup.py

    cat <<EOF > autorun.sh
    #!/bin/sh
    x-terminal-emulator -e bash -c '
    sudo $PWD/btrfs-backup.py /home $PWD/home
    sudo $PWD/btrfs-backup.py / $PWD/system
    echo "" &&
    echo "" &&
    read -p "Press any key to close this window"'
    EOF

    chmod +x autorun.sh

    popd
    sudo umount /mnt/backup && sudo rm -rf /mnt/backup

unplug, plugin in, mount with nautilus/caja/nemo, press "Execute" and see the backup running :-)


#### Android SDK and fastboot
Thanks to [lifehacker.com](http://lifehacker.com/the-easiest-way-to-install-androids-adb-and-fastboot-to-1586992378)

    sudo add-apt-repository -y ppa:phablet-team/tools
    sudo apt-get update
    sudo apt-get -y install android-tools-adb android-tools-fastboot
