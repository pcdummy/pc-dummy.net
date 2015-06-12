---
date: 2013-01-26T00:00:00+01:00
title: Syscp to Foxlor move on Ubuntu 12.10 with high security.
author: pcdummy
tag:
 - howto
---

Today i switched our (mine and my uncles) WebServer from

- [**SysCP**](http://syscp.org "SysCP") (modified by me), **apache2**, **apache2-mpm-itk**, **libapache2-mod-php5**, **proftpd**

To:

- [**Froxlor**](http://www.froxlor.org/ "Froxlor") (git master), **nginx**, **php5-fpm**, **vsftpd** (with libpam-mysql and libnss-mysql-bg)

<!--more-->I had nginx with php5-fpm running as second install, i also have it running on a high volume website. It&#39;s a dream!

This is a shared web Server so i tought a lot about its security (which we had before by mpm-itk).

The main thing to think about was PHP, there are a lot bugs in PHP written Software and &quot;crackers&quot;

love to hack PHP Sites.

The Solution for this was for us to run one php5-fpm for every customer, froxlor makes it easy to do so.

First replace ProFTPd with vsftpd with libpam-mysql ( libpam-ldap for a [bug](http://ubuntuforums.org/showthread.php?t=1937131) ), stolen [here.](http://forum.froxlor.org/index.php?/topic/569-solved-froxlor-0915-vsftpd-moglich/)

    apt-get install vsftpd libpam-mysql libpam-ldap

Replace `/etc/pam.d/vsftpd` (still with the syscp backend):

    auth     required       pam_mysql.so user=syscp passwd=<YOUR_MYSQL-SYSCP_PASSWORD> host=localhost db=syscp table=ftp_users usercolumn=username passwdcolumn=password [where=login_enabled="Y"] crypt=1 verbose=1
    account  required       pam_mysql.so user=syscp passwd=<YOUR_MYSQL-SYSCP_PASSWORD> host=localhost db=syscp table=ftp_users usercolumn=username passwdcolumn=password [where=login_enabled="Y"] crypt=1 verbose=1`

Replace `/etc/vsftpd.conf`:

    listen=YES

    dual_log_enable=YES
    log_ftp_protocol=YES
    xferlog_enable=YES

    anonymous_enable=NO
    local_enable=YES
    check_shell=NO

    virtual_use_local_privs=YES

    connect_from_port_20=YES
    secure_chroot_dir=/var/run/vsftpd/empty
    pam_service_name=vsftpd

    guest_username=www-data
    guest_enable=NO
    chroot_local_user=YES
    hide_ids=YES

    write_enable=YES
    use_localtime=YES
    local_umask=022
    dirmessage_enable=YES

    # local_root=/var/kunden/webs/$USER
    # See: http://www.benscobie.com/fixing-500-oops-vsftpd-refusing-to-run-with-writable-root-inside-chroot/
    # allow_writeable_chroot=YES

    user_sub_token=$USER
    nopriv_user=www-data

Restart vsftpd:

    /etc/init.d/vsftpd restart

Test it with your local ftp client.

Install Froxlor


    apt-get install git
    cd /var/kunden/webs/Server
    git clone https://github.com/Froxlor/Froxlor webadmin.<yourdomain.com>

Create /etc/nginx/sites-available/webadmin.<yourdomain.com> ( i have the "upstream" php5-fpm defined somewhere else ).

    server {
        listen           <your_ip>:80;
        server_name     webadmin.<yourdomain.com>;

        root    /var/kunden/webs/Server/webadmin.<yourdomain.com>;
        index    index.html index.php;

        charset utf-8;

        location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|xls)$ {
            access_log        off;
            expires           30d;
        }

        location / {
            rewrite ^(.*)$ /index.php$1 last;
        }

        location ~ "^(.+\.php)(.*)$" {
            fastcgi_split_path_info ^(.+\.php)(.*)$;
            fastcgi_pass   php5-fpm;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }

Enable the config, test it and restart nginx.

    ln -s /etc/nginx/sites-available/webadmin.<yourdomain.com> /etc/nginx/sites-enabled/001-webadmin.<yourdomain.com>
    nginx -t
    /etc/init.d/nginx restart

See this [guide](http://redmine.froxlor.org/projects/froxlor/wiki/Upgrading_to_or_updating_Froxlor) on howto upgrade from syscp to froxlor:

(i did it my way tm - installed froxlor, then i replaced the db with the one from syscp)

Now go to http://webadmin.yourdomain.com and migrate the syscp data,

after the migration you should configure the webserver to nginx.

Froxlor - nginx settings:

    [![froxlor-nginx-settings](http://rene.jochums.at/wp-content/uploads/2013/01/froxlor-nginx-settings-300x161.jpg)](http://rene.jochums.at/wp-content/uploads/2013/01/froxlor-nginx-settings.jpg)

Froxlor - phpfpm settings:
    [![froxlor-phpfpm-settings](http://rene.jochums.at/wp-content/uploads/2013/01/froxlor-phpfpm-settings-300x137.jpg)](http://rene.jochums.at/wp-content/uploads/2013/01/froxlor-phpfpm-settings.jpg)

Run cron_tasks.php for the first time and check its output for errors:

    /usr/bin/php -q /var/kunden/webs/Server/webadmin.<your-domain.com>/scripts/cron_tasks.php

Create a new MySQL user &quot;**vsftpd**&quot; and give him

    SELECT rights on the tables **froxlor.ftp_users**,** froxlor.ftp_groups**

Replace `/etc/pam.d/vsftpd`  again (now with the froxlor backend)

<pre>
`auth     required       pam_mysql.so user=vsftpd passwd=<YOUR-VSFTPD-MYSQL-PASS> host=localhost db=froxlor table=ftp_users usercolumn=username passwdcolumn=password [where=login_enabled="Y"] crypt=1
account  required       pam_mysql.so user=vsftpd passwd=<YOUR-VSFTPD-MYSQL-PASS> host=localhost db=froxlor table=ftp_users usercolumn=username passwdcolumn=password [where=login_enabled="Y"] crypt=1`</pre>

Restart `vsftpd`:

    /etc/init.d/vsftpd restart

Test with your local ftp client.

Can't remember why but i had to replace `libnss-mysql` with `libnss-mysql-bg`

This is the config `/etc/libnss-mysql.cfg` for it if you need it.

    getpwnam    SELECT username,'x',uid,gid,'MySQL User',homedir,shell \
    FROM ftp_users \
    WHERE username='%1$s' \
    ORDER BY id ASC \
    LIMIT 1

    getpwuid    SELECT username,'x',uid,gid,'MySQL User',homedir,shell \
    FROM ftp_users \
    WHERE uid='%1$u' \
    ORDER BY id ASC
    LIMIT 1

    getspnam    SELECT username,password,'1','0','99999','0','0','-1','0' \
    FROM ftp_users \
    WHERE username='%1$s' \
    ORDER BY id ASC
    LIMIT 1

    getpwent    SELECT username,'x',uid,gid,'MySQL User',homedir,shell \
    FROM ftp_users

    getspent    SELECT username,password,'1','0','99999','0','0','-1','0' \
    FROM ftp_users

    getgrnam    SELECT groupname,'empty',gid \
    FROM ftp_groups \
    WHERE groupname='%1$s' \
    LIMIT 1

    getgrgid    SELECT groupname,'empty',gid \
    FROM ftp_groups \
    WHERE gid='%1$u' \
    LIMIT 1

    getgrent    SELECT groupname,'empty',gid \
    FROM ftp_groups

    memsbygid   SELECT members \
    FROM ftp_groups \
    WHERE gid='%1$u'

    gidsbymem   SELECT gid \
    FROM ftp_groups \
    WHERE groupname='%1$s'

    host        localhost
    database    vsftpd
    username    vsftpd
    password    <your-vsftpd-pass-here>

`/etc/libnss-mysql-root.cfg`

    username    vsftpd password    <your-vsftpd-pass-here>
