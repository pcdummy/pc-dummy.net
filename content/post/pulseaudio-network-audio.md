---
date: 2015-06-14T00:19:30+01:00
title: Pulseaudio as network audio sender/receiver
author: pcdummy
tags:
  - Howto
  - Linux
  - Pulseaudio
  - Network Audio
---
I use Pulseaudio to send my audio to a different computer where i have a sound system plugged in,
and i switch between computers with sound stations.

This howto will help you to create you'r own OSS Network audio sender and receiver.<!--more-->


#### This is what i do on each receivers (servers)
You might want to change **10.0.0.0/8** to your own IPv4 subnet you want allow to send audio.

    mkdir $HOME/.pulse
    cp /etc/pulse/default.pa $HOME/.pulse
    echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1;10.0.0.0/8" >> $HOME/.pulse/default.pa
    pulseaudio --kill
    sleep 2
    pulseaudio -D

#### On the sender (client)
On the client i create multible configurations, change **<name>** to your name you want. (like home/company/friend).

    mkdir $HOME/.pulse
    cp /etc/pulse/client.conf $HOME/.pulse/client-nonet.conf
    cp /etc/pulse/client.conf $HOME/.pulse/client-<name>.conf
    echo "default-server = 10.167.160.103:4713" >> $HOME/.pulse/client.conf


#### Receiver switch script (on the client)
I use this script to change between receivers, sometimes i need to call it twice to work.

    mkdir $HOME/bin
    source $HOME/.bashrc

    cat << 'EOF' > $HOME/bin/pulseswitch
    #!/bin/sh

    if test -z "$1"; then
      echo "USAGE: pulseswitch [nonet|<your-config>]"
      exit 1
    fi

    echo "Switching to \"$1\"."
    /bin/ln -fs $HOME/.pulse/client-$1.conf $HOME/.pulse/client.conf
    /usr/bin/pulseaudio --kill
    /usr/bin/pulseaudio -D
    if [ "x$1" = "xnonet" ]; then
            echo "Unloading the net module."
            /usr/bin/pactl unload-module module-native-protocol-tcp
    else
            echo "Loading the net module."
            /usr/bin/pactl load-module module-native-protocol-tcp
    fi
    /usr/bin/pulseaudio --kill
    /usr/bin/pulseaudio -D
    EOF'
