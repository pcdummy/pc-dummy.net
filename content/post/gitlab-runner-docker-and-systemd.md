---
date: 2018-04-17T22:54:00+02:00
title: gitlab-runner docker with debian systemd
author: pcdummy
tags:
  - HOWTO
  - Debian
  - Gitlab
  - Docker
---

An howto on systemd with a Debian stretch/buster docker container and Gitlab.
<!--more-->

Find all code on Github [stretch](https://github.com/pcdummy/proxmox-dockerfiles/tree/master/stretch-systemd) and [buster](https://github.com/pcdummy/proxmox-dockerfiles/tree/master/buster-systemd).

### Debian Stretch

This didn't work at all with systemd from Debian stretch, but as i knew from my LXD experience systemd in stretch is buggy with containers,
so i tried systemd from [stretch-backports](https://github.com/pcdummy/proxmox-dockerfiles/blob/master/stretch-systemd/Dockerfile#L18) which worked well.

Now to have systemd finaly working in a stretch container you need to mount a tmpfs into /run and /run/lock else systemd tries to mount those - fails with permission denied and freezes.

Also you need to bind-mount cgroups into the stretch container (doing that as "volume").

This is the full line to run a Debian 9 container with systemd from backports:

```
docker run -d -it --mount type=tmpfs,destination=/run --mount type=tmpfs,destination=/run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro <image>
```

### Debian Buster

It's same as with stretch but no backports.


### Gitlab-runner for both

Ok, so we found out that we need:

- a tmpfs /run
- a tmpfs /run/lock
- cgroup bind-mount

gitlab-runner does volumes which means the bind-mount is easy to solve, but what about the tmpfs mounts?

After a while a found a feature they call [Mounting a directory in RAM](https://docs.gitlab.com/runner/executors/docker.html#mounting-a-directory-in-ram), which is nothing else than a mount of a tmpfs :)

This means we need to add the following to **/etc/gitlab-runner/config.toml**:

```toml
[runners.docker]
    volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:ro", "/cache"]
[runners.docker.services_tmpfs]
    "/run" = "rw"
    "/run/lock" = "rw"
```

Easy, isn't it?