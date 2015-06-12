---
date: 2014-12-15T00:00:00+01:00
title: Froxlor + Nginx + WordPress iThemes Rules
author: pcdummy
tag:
  - howto
---
A short howto on setting up Wordpress iThemes Security with Froxlor and nginx.

<!--more-->Assuming you have this directory layout:

    /var/customers/webs/[customer-name]/[domain-name]/htdocs

This is what i did to make it work on my froxlor installation:

1.  Login to Froxlor as Administrator
2.  Impersonate your wordpress customer by clicking on Customers -&gt; [his username]
3.  As Customer click on Domain -&gt; Settings -&gt; [the small edit pensil to edit this domain]
4.  Change &quot;Openbasedir-Path&quot; to &quot;Homefolder&quot; - this will **allow** PHP to **access** all files **from this customer**!
5.  Wait for the froxlor crontask or run it manually
6.  Login to your wordpress backend.
7.  Goto Security-&gt;Settings and search for nginx, change the nginx config path to &quot;/var/customers/webs**/[customer-name]**/**[domain-name]**/nginx.conf&quot; and save, it should give a message about a sucessfull write of the nginx.conf!
8.  Go back to the Froxlor Administrator Panel
9.  Go to Domains -&gt; [small edit pensil to edit your customers domain]
10.  Insert &quot;include /var/customers/webs/[customer-name]/[domain-name]/nginx.conf;&quot; to his &quot;Own vHost-Settings&quot;
11.  Wait for the froxlor contask again.
12.  Voila, now you have improved yours/your customers wordpress installation even more.

### Deprecated Method:

Took me a while to convert the Nginx rules from iThemes to "plain" Text so i could past them into froxlor.

This is what came out.

<pre class="brush:plain;">
    # BEGIN iThemes Security
    # BEGIN Tweaks
    # Rules to block access to WordPress specific files and wp-includes
    location ~ /\.ht { deny all; }
    location ~ wp-config.php { deny all; }
    location ~ readme.html { deny all; }
    location ~ readme.txt { deny all; }
    location ~ /install.php { deny all; }
    location ^wp-includes/(.*).php { deny all; }
    location ^/wp-admin/includes(.*)$ { deny all; }

    # Rules to prevent php execution in uploads
    location ^(.*)/uploads/(.*).php(.?){ deny all; }

    # Rules to block unneeded HTTP methods
    if ($request_method ~* &quot;^(TRACE|DELETE|TRACK)&quot;){ return 403; }

    # Rules to block suspicious URIs
    set $susquery 0;
    if ($args ~* &quot;\.\./&quot;) { set $susquery 1; }
    if ($args ~* &quot;\.(bash|git|hg|log|svn|swp|cvs)&quot;) { set $susquery 1; }
    if ($args ~* &quot;etc/passwd&quot;) { set $susquery 1; }
    if ($args ~* &quot;boot.ini&quot;) { set $susquery 1; }
    if ($args ~* &quot;ftp:&quot;) { set $susquery 1; }
    if ($args ~* &quot;http:&quot;) { set $susquery 1; }
    if ($args ~* &quot;https:&quot;) { set $susquery 1; }
    if ($args ~* &quot;(&lt;|%3C).*script.*(&gt;|%3E)&quot;) { set $susquery 1; }
    if ($args ~* &quot;mosConfig_[a-zA-Z_]{1,21}(=|%3D)&quot;) { set $susquery 1; }
    if ($args ~* &quot;base64_encode&quot;) { set $susquery 1; }
    if ($args ~* &quot;(%24&amp;x)&quot;) { set $susquery 1; }
    if ($args ~* &quot;(127.0)&quot;) { set $susquery 1; }
    if ($args ~* &quot;(globals|encode|localhost|loopback)&quot;) { set $susquery 1; }
    if ($args ~* &quot;(request|insert|concat|union|declare)&quot;) { set $susquery 1; }
    if ($args !~ &quot;^loggedout=true&quot;){ set $susquery 0; }
    if ($args !~ &quot;^action=jetpack-sso&quot;){ set $susquery 0; }
    if ($args !~ &quot;^action=rp&quot;){ set $susquery 0; }
    if ($http_cookie !~ &quot;^.*wordpress_logged_in_.*$&quot;){ set $susquery 0; }
    if ($http_referer !~ &quot;^http://maps.googleapis.com(.*)$&quot;){ set $susquery 0; }
    if ($susquery = 1) { return 403; }

    # Rules to help reduce spam
    location /wp-comments-post.php {
        valid_referers jetpack.wordpress.com/jetpack-comment/ *.smile4.at;
        set $rule_0 0;
        if ($request_method ~ &quot;POST&quot;){ set $rule_0 1$rule_0; }
        if ($invalid_referer) { set $rule_0 2$rule_0; }
        if ($http_user_agent ~ &quot;^$&quot;){ set $rule_0 3$rule_0; }
        if ($rule_0 = &quot;3210&quot;) { return 403; }
    }
    # END Tweaks
    # END iThemes Security</pre>
