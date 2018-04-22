---
date: 2018-04-22T21:24:00+02:00
title: "vcs-mirrors: Git/Bazaar/SVN mirroring"
author: pcdummy
tags:
  - GIT
  - VCS
  - Bazaar
  - SVN
---

As Gitlab CE (Community Edition) does not support Mirroring people came up with external tools,
one i found fast is: [gitlab-mirrors](https://github.com/samrocketman/gitlab-mirrors/) but i had troubles
with it (it did always prune) so i decided to write my own python-only fork of it.

I came up with [vcs-mirrors](https://git.lxch.eu/pcdummy/vcs-mirrors) which i released on [PyPi](https://pypi.org/project/vcs-mirrors/).
<!--more-->

### Requirements

- Python 3.5+ (Debian Stretch+, Ubuntu Xenial+)
- virtualenv if you don't want to mess with System Python
- [git-remote-bzr](https://github.com/felipec/git-remote-bzr) for Bazaar support

### Features

* Mirror different types of source repositories: Bazaar, Git, Subversion. Mirror all into git.
* GitLab mirror adding.
    * When adding a mirror if the project doesn't exist in GitLab it will be auto-created.
    * Set project creation defaults (e.g. issues enabled, wiki enabled, etc.)
* Github mirror adding.
    * Same as with Gitlab.
* mirror anything to Git (not just Gitlab and Github).
* Update a single mirror.
* Update all known mirrors.