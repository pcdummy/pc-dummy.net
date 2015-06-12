---
date: 2014-12-15T00:00:00+01:00
title: Restore lost data with Photorec
author: pcdummy

---

A friend of mine lost his NTFS Partition (think it was a power outage). As he has some data on it he needs, i tought about restoring it.
<!--more-->
Helpful Links:

*   [Authors Step-by-Step Guide](http://www.cgsecurity.org/wiki/PhotoRec_Step_By_Step)
*   [German Ubuntu wiki article on Data Recovery](http://wiki.ubuntuusers.de/Datenrettung)

This is what i came out with:

1.  Downloaded[ TestDisk (with Photorec)](http://www.cgsecurity.org/wiki/TestDisk_Download "TestDisk download")
2.  Extracted it.
3.  Made store directory on other disk: $ mkdir /media/&lt;username&gt;/&lt;my_usb_disk&gt;/&lt;friends_name&gt;
4.  run it as root: sudo photorec_static /media/&lt;username&gt;/&lt;friends_disk&gt;/the_dd_image_we_made_before.img
5.  I set it &quot;whole&quot; and &quot;NTFS&quot;, after about 18 Hours it was over that 300GB.

To split the files up in **one directory per extension**:

<pre><code class="bash">
cd /media/&lt;username&gt;/&lt;my_usb_disk&gt;;

# Create a list of Extensions found: http://stackoverflow.com/questions/1842254
find &lt;friends_name&gt;/ -type f | perl -ne &#39;print $1 if m/\.([^.\/]+)$/&#39; | sort -u &gt; found_extensions.txt

#
# You might want to edit the &quot;found_extensions.txt&quot; file you just generated,
# - filter out crap
# - remove duplicated extensions, the script below is case insensetive
#

# Create the directory where we copy these files in one folder per extension.
mkdir &lt;friends_name&gt;_extensions/
cd &lt;friends_name&gt;_extensions/

# Now mkdir one directory per extension and copy of all files of this extension into it.

#!/bin/sh
for i in $(cat ../found_extensions.txt); do
    count=$(find ../&lt;friends_name&gt;/ -type f -iname &quot;*.$i&quot; | wc -l)
    echo &quot;Copying \&quot;$count\&quot; files for extension: $i...&quot;
    mkdir -p $i
    for src in $(find ../&lt;friends_name&gt;/ -type f -iname &quot;*.$i&quot;); do
        dest=$i/$(basename $src)
        if [ ! -f "$dest" ]; then
            echo &quot;Copying \&quot;$src\&quot; to \&quot;$dest\&quot;&quot;
            cp $src $dest # Use mv here instead of cp if you known what you do.
        elif ! $(cmp -s $src $dest); then
            echo &quot;Overwriting \&quot;$dest\&quot; with \&quot;$src\&quot;&quot;
            cp $src $dest
        fi
    done
done
</code></pre>
