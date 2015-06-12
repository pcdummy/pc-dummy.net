---
date: 2014-12-14T00:00:00+01:00
description: Emulate a Hetzner root with mininet.
tags:
- hetzner
- mininet
- howto
title: Emulate a Hetzner root with mininet
---

I manage some root server from friends at Hetzner, as Hetzner has a &quot;special&quot; setup by blocking unknown Mac Addresses at theier switches, its not that easy to configure that.

The last days i played around with [OpenVSwitch](http://openvswitch.org/ "OpenVSwitch") (A Virtual Switch, featuring VLAN&#39;s, OpenFlow, Switch To Switch Tunnels).<!--more-->

OpenVSwitch would allow me to add features like **Firewall as a Service** or **IDS as a Service** and it also allows me to **link multiple Servers** together.

BUT these servers are all in production, i can&#39;t play on them, this is where [Mininet](http://mininet.org/ "Mininet") comes in use, it allows me to emulate a full network on a single VM, without touching these root Servers.

Have a look at this [Script](https://gist.github.com/pcdummy/9b9d1589289b649d8207 "hetzner.py") if you also need a lab to test your Hetzner Networking.

Setup from start:

1. At first get and install a [Mininet Download and Guide](http://mininet.org/download/ "Mininet Download and Guide") also see this [Guide](http://www.brianlinkletter.com/set-up-mininet/ "Mininet Setup guide by Brian Kletter")
2. Learn howto use Mininet [Sample Workflow.](http://mininet.org/sample-workflow/ "Mininet Sample Workflow")
3. Edit the Script parameters in &quot;[root_network](https://gist.github.com/pcdummy/9b9d1589289b649d8207#file-hetzner-py-L257 "Script root_network")&quot; (get the gw mac with `$ arp -n` on your root.
4. Next copy the [Script](https://gist.github.com/pcdummy/9b9d1589289b649d8207 "Script") to your VM: `$ scp hetzner.py mininet@<vm-ip>:/home/mininet/` (you might want to use sshfs).
5. Run hetzner.py as root `$ sudo ./hetzner.py`
6. Play arround with it: `h1 ping gw`

Have fun and please tell me when you found bugs or you have improvement ideas.
