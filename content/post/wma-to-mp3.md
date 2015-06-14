---
date: 2015-06-14T00:15:30+01:00
title: Mass convert WMA to mp3
author: pcdummy
tags:
  - Howto
  - Linux
  - WMA
  - MP3
---
This is what i did to convert all my wma soundfiles to mp3's.<!--more-->

#### 1.) Install libav-tools

    sudo apt-get install libav-tools

#### 2.) Convert WMA to mp3

    cd <your musik path>;
    find . -iname '*.wma' -exec /bin/bash -c "avconv -i '{}' -acodec libmp3lame -ab 320k '{}.mp3'" \;

#### 3.) Remove WMA's

    cd <your musik path>;
    find . -iname '*.wma' -exec rm -f {} \;

#### 4.) Use Puddltag to change tags and rename files

    sudo apt-get install puddletag;
    puddletag <your musik path>

#### 4. Remove empty Directories

    find <your musik path> -type d -empty -exec rm -rf {} \;
