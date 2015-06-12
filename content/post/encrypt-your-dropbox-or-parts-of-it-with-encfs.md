---
date: 2014-12-15T00:00:00+01:00
title: Encrypt your Dropbox (or parts of it) on Linux
author: pcdummy

---
#### UPDATE: EncFS is considered to be insecure (see this [Audit](https://defuse.ca/audits/encfs.htm)), i will use eCryptFS instead, see this [manual](https://help.ubuntu.com/community/EncryptedPrivateDirectory). If you still want to use EncFS use [gnome-encfs-manager](http://www.libertyzero.com/GEncfsM/) instead of gnome-encfs below.

I have some sensetive Data on my Laptop i want to sync with other Computers i own, found this [Howto](http://www.makeuseof.com/tag/encrypt-dropbox-data-encfs-linux/ "How To Encrypt Your Dropbox Data With ENCFS [Linux] ") on howto do that. Theres also a Windows &quot;port&quot; of encfs - [safe](http://www.getsafe.org/about "Safe"), didn&#39;t test it tough.<!--more-->

#### This is what i did (on Linux Mint 17 64bit):

<pre><code class="bash">
sudo apt-get install encfs
cd ~/Downloads
wget https://bitbucket.org/obensonne/gnome-encfs/raw/tip/gnome-encfs
mv ~/exchange ~/exchange2
sudo install gnome-encfs /usr/local/bin/
mkdir ~/Dropbox/.encrypted_exchange ~/exchange
encfs ~/Dropbox/.encrypted_exchange ~/exchange/ # answered &quot;p for paranoia mode
gnome-encfs -a ~/Dropbox/.encrypted_exchange/ ~/exchange # enter, then password, then Y
cat /etc/mtab | grep encfs # Should give one line with /home/your_username/exchange
cd ~/exchange &amp;&amp; rsync -avP ~/exchang2/* .
du -sh ~/exchange ~/Dropbox/.encrypted_exchange ~/exchange2 # All 3 folders should be a the same size
# rm -r ~/exchange2 # Do this only if you have a backup!</code></pre>
