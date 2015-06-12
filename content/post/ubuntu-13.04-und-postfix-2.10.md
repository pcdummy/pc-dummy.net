---
date: 2013-08-13T00:00:00+01:00
title: Ubuntu 13.04 und Postfix 2.10
author: pcdummy

---

Nachdem ich jetzt einen Tag nach einer L&ouml;sung gesucht warum mein Postfix immer ein 5.7.1 Relay Access Denied ausspuckt... hier die L&ouml;sung:

[https://bbs.archlinux.org/viewtopic.php?id=158020](https://bbs.archlinux.org/viewtopic.php?id=158020)

Aus `smtpd_recipient_restrictions` wird `smtpd_relay_restrictions`<!--more-->
