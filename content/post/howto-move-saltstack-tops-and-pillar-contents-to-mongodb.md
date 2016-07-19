---
date: 2016-07-09T00:17:00+01:00
description: Detailed explanation on HOWTO move your Saltstack tops and pillar data to MongoDB
tags:
- HOWTO
- Saltstack
title: Howto move Saltstack tops and pillar contents to MongoDB
---

I'm a heavy user of [Saltstack](https://saltstack.com/), on my home network i develop salt states and test new stuff and on my production servers i use the results of
my development at home.

#### My motiviation for this:

- I have a dream of automated deployed [LXD](https://linuxcontainers.org/lxd/introduction/) containers which you can manage with a web interface like [Froxlor](https://www.froxlor.org/).
- I want a database where i can easily modify contents with a script.

#### Prerequisites

- Knowledge of Saltstack
- Knowledge of MongoDB

#### Salt Modules in use

- [salt.tops.mongo](https://docs.saltstack.com/en/latest/ref/tops/all/salt.tops.mongo.html)
- [salt.pillar.mongo](https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.mongo.html)

<!--more-->

### Here comes the step-by-step guide

### 1.) Install MongoDB somewhere and create some users

#### a.) Go to the [MongoDB installation guide](https://docs.mongodb.com/manual/installation/) for install instructions.

#### b.) Create a superadmin user

Open a mongo shell:

```bash
mongo
```

And insert the following (replace the username and password!).
```javascript
use admin;
db.createUser({ user: "<replace with your username>",
  pwd: "<replace with your cleartext password>",
  roles: [
    { role: "clusterAdmin", db: "admin" },
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
  ]
})
quit();
```

#### c.) Configure MongoDB to enforce authentication:

Add this to your **/etc/mongd.conf**:
```yaml
security:
  authorization: enabled
```

And restart MongoDB:
```bash
service mongod restart
```

#### d.) Create a user and Database for your saltmaster:

Open a mongo shell and login
```bash
mongo -u <username from above> --authenticationDatabase admin -p
```

```javascript
use saltstack;
db.createUser({ user: "saltmaster",
  pwd: "<replace with your cleartext password for the saltmaster user>",
  roles: [
    { role: "readWrite", db: "saltstack" },
  ]
})
quit();
```

### 2.) Configure your saltmaster to use salt_tops and salt_pillar with the MongoDB

#### a.) Open /etc/salt/master and insert

```
master_tops:
  mongo:
    id_field: _id
    collection: salt_tops

ext_pillar:
  - mongo: {collection: salt_pillar}

ext_pillar_first: false

#####   mongodb connection settings  #####
##########################################
mongo.db: saltstack
mongo.indexes: true
mongo.host: <your mongo host>
mongo.user: saltmaster
mongo.password: <your saltmaster mongo password>
mongo.port: 27017
```

You can also use the [salt-formula](https://github.com/saltstack-formulas/salt-formula), but you need the latest version with my [PR](https://github.com/saltstack-formulas/salt-formula/pull/241)


#### b.) Restart your salt-master

```bash
service salt-master restart
```

### 3.) Create some tops and pillars

I use [robomongo](https://robomongo.org/) for that, its a Desktop app with functionality like phpMyAdmin.
To convert my old YAML files to JSON i use: [YAML to JSON](http://yamltojson.com/).

#### a.) An example top in the collection **salt_tops**

```json
{
    "_id" : "apu1d4.pcdummy.lan",
    "states" : [
        "roles.base.server",
        "roles.base.lxc",
        "bird",
        "softether.client"
    ],
    "environment" : "pcdummy"
}
```

#### b.) An example pillar entry in the collection **salt_pillar**

This uses my **mongo include patch** which you can optain from [Salt PR #34566](https://github.com/saltstack/salt/pull/34566)

```json
{
    "_id" : "apu1d4.pcdummy.lan",
    "include" : [
        {
            "file" : "roles.base.server",
            "saltenv" : "pcdummy"
        },
        {
            "file" : "roles.base.lxc",
            "saltenv" : "pcdummy"
        },
        {
            "file" : "roles.base.sysctl_container_host",
            "saltenv" : "pcdummy"
        },
        {
            "file" : "roles.base.postfix-relayclient",
            "saltenv" : "pcdummy"
        }
    ],
    "grub" : {
        "lookup" : {
            "config" : {
                "manage" : [
                    "default_config"
                ]
            }
        },
        "default_config" : {
            "content" : "GRUB_DEFAULT=0\nGRUB_TIMEOUT=10\nGRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`\nGRUB_CMDLINE_LINUX_DEFAULT=\"quiet cgroup_enable=memory swapaccount=1\"\nGRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 earlyprint=ttyS0,115200n8\"\nGRUB_TERMINAL=serial\nGRUB_SERIAL_COMMAND=\"serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1\"\n"
        }
    },
    "network" : {
        "hosts" : [
            {
                "name" : "apu1d4.pcdummy.lan",
                "ip" : "fd57:c87d:f1ee:ee00::1"
            }
        ],
        "resolver" : {
            "domain" : "pcdummy.lan",
            "search" : [
                "pcdummy.lan"
            ],
            "nameservers" : [
                "fd57:c87d:f1ee:ee00:f::18"
            ]
        }
    },
    "lxc" : {
        "default_conf" : [
            {
                "lxc.network.type" : "veth"
            },
            {
                "lxc.network.link" : "apubr0"
            },
            {
                "lxc.network.flags" : "up"
            },
            {
                "lxc.network.hwaddr" : "00:16:3e:02:xx:xx"
            }
        ],
        "users" : {
            "lxd" : {
                "interfaces" : {
                    "apubr0" : {
                        "type" : "veth",
                        "count" : 100
                    }
                }
            }
        }
    },
    "softether" : {
        "lookup" : {
            "client_svc_onboot" : true
        },
        "interface" : {
            "enabled" : true,
            "name" : "vpn_gw0",
            "ipv4address" : "10.171.104.160",
            "ipv4netmask" : "255.255.0.0",
            "ipv6enabled" : true,
            "ipv6address" : "fd57:c87d:f1ee:f003::ee00:1",
            "ipv6netmask" : 64
        }
    },
    "bird" : {
        "bird_cfg" : "log syslog { info, remote, warning, error, auth, fatal, bug };\nlog stderr all;\n\nrouter id 10.171.104.160;\n\nprotocol kernel {\n        learn;\n        persist;\n        scan time 20;\n        import all;\n        export all;\n}\n\nprotocol device {\n        scan time 10;           # Scan interfaces every 10 seconds\n}\n\nprotocol ospf main {\n        import all;\n        export all;\n\n        area 0.0.0.0 {\n                interface \"apubr0\";\n                interface \"vpn_gw0\";\n        };\n}\n",
        "bird6_cfg" : "log syslog { info, remote, warning, error, auth, fatal, bug };\nlog stderr all;\n\nrouter id 10.171.104.160;\n\nfunction is_default() { return net ~ [ ::/0 ]; }\n\nprotocol kernel {\n        learn;\n        persist;\n        scan time 20;\n        import all;\n        export all;\n}\n\nprotocol device {\n        scan time 10;           # Scan interfaces every 10 seconds\n}\n\nprotocol ospf main {\n        import all;\n        export filter {\n                if (is_default()) then reject;\n                accept;\n        };\n\n        area 0 {\n                interface \"apubr0\";\n                interface \"vpn_gw0\";\n        };\n}\n\nprotocol radv {\n    interface \"apubr0\";\n    prefix fd57:c87d:f1ee:ee00::/64;\n    prefix 2001:470:b718:ee00::/64;\n\n    rdnss fd57:c87d:f1ee:ee00:f::18;\n\n    dnssl {\n      domain \"pcdummy.lan\";\n    };\n}\n"
    }
}
```

### 4.) Check if your tops and pillar.items are right

On the saltmaster

#### a.) For the **tops**

```bash
salt apu1d4.pcdummy.lan state.show_top
```

#### b.) For the **pillar**

```bash
salt apu1d4.pcdummy.lan pillar.items
```

### 5.) Leave a comment about this HOWTO

Any suggestions? Or did it help you? Please leave a comment.