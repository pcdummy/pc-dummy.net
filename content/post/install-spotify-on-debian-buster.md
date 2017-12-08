---
date: 2017-12-08T09:30:00+01:00
title: Install spotify on Debian Buster/Testing
author: pcdummy
tags:
  - Debian
  - Buster
  - Spotify
---

On Debian >Jessie you need to install libssl1.0.0 manualy, in this post I show you how to do so.
<!--more-->

#### Install the required libssl1.0.0 from Debian Jessie

Download libssl1.0.0 from Debian Jessie from [packages.debian.org](https://packages.debian.org/jessie/libssl1.0.0)

After that install it with **dpkg**:

    sudo dpkg -i ~/Downloads/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb

As of today it was:

    pushd .
    cd ~/Downloads/
    wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb
    sudo dpkg -i ~/Downloads/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb

#### Install Spotify

1.) Add the Spotify repository signing keys to be able to verify downloaded packages
    
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

2.) Add the Spotify repository
    
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

3.) Update list of available packages
    
    sudo apt-get update

4.) Install Spotify
    
    sudo apt-get install spotify-client