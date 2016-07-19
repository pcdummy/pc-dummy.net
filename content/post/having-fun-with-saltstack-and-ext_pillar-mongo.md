---
date: 2016-07-12T13:00:00+01:00
title: Having fun with Saltstack and ext_pillar mongo
author: pcdummy
tags:
  - HOWTO
  - saltstack
---
Today i have written another [Patch](https://github.com/saltstack/salt/pull/34566) for [salt.pillar.mongo](https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.mongo.html),
this patch allows us to include pillar entries from previous files/includes in the current one.

This is usefull when you want to calculate for example network data with/or without defaults.

<!--more-->

### Code

This is my **defaults** file which i have stored in **pillar/pcdummy/roles/base/common_pcdummy**:

```yaml
include
 :l - users.pcdummy
  - roles.base.common
  - roles.base.mongodb_client

_data:
  domain: pcdummy.lan
  aptcacher:
    address: "http://aptcacher.pcdummy.lan:3142"
  mail:
    relayserver: "mx0.lxch.lan"
    rootalias: "rene@jochums.at"

  check_mk:
    ipv6: True
    only_from: '::1 fd57:1:see:bad:c0de::14'

  network:
    managed: False
    pubinterface: eth0 # Take hosts entries from this interface.
    intinterface: eth0

    interfaces:
      eth0:
        enabled: True
        configure: True
        type: eth
        noifupdown: True
        ipv4netmask: 255.255.255.0
        ipv4gateway: 10.167.160.1
        ipv6netmask: 64
        ipv6gateway: 'fe80::1'

    resolver:
      nameservers:
          - fd57:1:see:bad:c0de::18
      search:
          - pcdummy.lan
```

This is the **host definition** for the host `srv01.pcdummy.lan` which is stored in the mongodb and
which will be retrieved over ext_pillar mongo.

```json
{
    "_id" : "srv01.pcdummy.lan",
    "include" : [
        {
            "file" : "roles.base.common_pcdummy",
            "saltenv" : "pcdummy"
        },
        {
            "file" : "global.generator",
            "saltenv" : "pcdummy"
        },
        {
            "file" : "roles.base.server",
            "saltenv" : "pcdummy"
        },
        {
            "file" : "roles.base.postfix-relayclient",
            "saltenv" : "pcdummy"
        }
    ],
    "_data" : {
        "network" : {
            "managed" : true,
            "pubinterface" : "lanbr0",
            "intinterface" : "lanbr0",
            "interfaces" : {
                "eth0" : {
                    "configure" : false,
                    "bridge" : "lanbr0"
                },
                "lanbr0" : {
                    "enabled" : true,
                    "configure" : true,
                    "type" : "bridge",
                    "ipv4address" : "10.167.160.14",
                    "ipv4netmask" : "255.255.255.0",
                    "ipv4gateway" : "10.167.160.1",
                    "ipv6address" : "fd57:1:see:bad:c0de::14",
                    "pubipv6address" : "2001:1:see:bad:c0de::14",
                    "ipv6addresses" : [
                        "2001:1:see:bad:c0de::14/64"
                    ],
                    "ipv6netmask" : "64",
                    "ipv6gateway" : "fe80::1",
                    "ports" : "eth0",
                    "stp" : "off",
                    "delay" : "0",
                    "maxwait" : 0,
                    "fd" : 0
                }
            }
        }
    }
}
```

And this is the generator stored in **pillar/pcdummy/global/generator.sls** which generates
pillar data from the above merged data.

```yaml
#!jinja|yaml
# vi: set ft=yaml.jinja :

{% set data = pillar.get('_data', {'network': {'managed': False}}) %}

{% if data.get('network', False) and data.network.get('managed', False)  %}
network:
  {%- if salt['grains.get']('os_family') == 'Debian' %}
  pkgs:
    purged:
      - resolvconf
  {% endif -%}

  interfaces:
{% for name, interface in data.network.interfaces.items() %}
  {% if 'configure' in interface and interface.configure %}
    - name: {{ name }}
      enabled: {{ interface.get('enabled', False) }}
      proto: static
      type: {{ interface.type }}
      {% if 'noifupdown' in interface %}
      noifupdown: {{ interface.noifupdown }}
      {% endif %}
      {% if 'ipv4address' in interface %}
      ipaddr: {{ interface.ipv4address }}
      netmask: {{ interface.ipv4netmask }}
      {% endif %}
      {% if 'ipv4gateway' in interface %}
      gateway: '{{ interface.ipv4gateway }}'
      {% endif %}
      {% if 'pointopoint' in interface %}
      pointopoint: '{{ interface.pointopoint }}'
      {% endif %}
      {% if 'ipv6address' in interface %}
      enable_ipv6: True
      ipv6proto: static
      ipv6ipaddr: '{{ interface.ipv6address }}'
      ipv6netmask: {{ interface.ipv6netmask }}
        {% if 'ipv6gateway' in interface %}
      ipv6gateway: '{{ interface.ipv6gateway }}'
        {% endif %}
      {% endif %}
      {% if 'bridge' in interface %}
      bridge: {{ interface.bridge }}
      {% endif %}
      {% if 'delay' in interface %}
      delay: {{ interface.delay }}
      {% endif %}
      {% if 'ports' in interface %}
      ports: {{ interface.ports }}
      {% endif %}
      {% if 'stp' in interface %}
      stp: {{ interface.stp }}
      {% endif %}
      {% if 'maxwait' in interface %}
      maxwait: {{ interface.maxwait }}
      {% endif %}
      {% if 'fd' in interface %}
      fd: {{ interface.maxwait }}
      {% endif %}

      {% if 'pre_up_cmds' in interface %}
      pre_up_cmds:
          {%- for cmd in interface.pre_up_cmds %}
        - {{ cmd }}
          {% endfor %}
      {% endif %}

      {% if 'ipv4routes' in interface or
        'ipv6routes' in interface or
        'ipv6addresses' in interface or
        'up_cmds' in interface %}
      up_cmds:
        {%- if 'ipv4routes' in interface %}
          {%- for route in interface.ipv4routes %}
        - /sbin/ip -4 route add {{ route }} dev $IFACE
          {% endfor %}
        {% endif %}
        {%- if 'ipv6routes' in interface %}
          {%- for route in interface.ipv6routes %}
        - /sbin/ip -6 route add {{ route }} dev $IFACE
          {% endfor %}
        {% endif %}
        {%- if 'ipv6addresses' in interface %}
          {%- for address in interface.ipv6addresses %}
        - /sbin/ip -6 addr add {{ address }} dev $IFACE
          {% endfor %}
        {% endif %}
        {%- if 'up_cmds' in data.network %}
          {%- for cmd in data.network.up_cmds %}
        - {{ cmd }}
          {% endfor %}
        {% endif %}
      {% endif %}
  {% endif %}
{% endfor %}

  resolver:
    domain: {{ data.domain }}
    search:
    {%- for search in data.network.resolver.search %}
      - {{ search }}
    {% endfor %}
    nameservers:
    {%- for nameserver in data.network.resolver.nameservers %}
      - {{ nameserver }}
    {% endfor %}

{% else %}
network:
{% endif %}

  hostsfile:
    fqdn: {{ salt['grains.get']('fqdn') }}
    hostname: {{ salt['grains.get']('host') }}


{% if 'check_mk' in data %}
check_mk:
  agent:
    ipv6: {{ data.check_mk.ipv6 }}
    only_from: {{ data.check_mk.only_from }}
{% endif %}

{% if data.get('aptcacher', False) and data.aptcacher.get('address', False) %}
apt:
  configs:
    01proxy:
      content: |
        # This file managed by Salt, do not edit by hand!
        Acquire::http::Proxy "{{ data.aptcacher.address }}";
        Acquire::https { Proxy "false"; };
{% endif %}
```

This uses the following states:

- [apt](https://github.com/pcdummy/saltstack-apt-formula)
- [network](https://github.com/pcdummy/saltstack-network-formula)
- check_mk - not available to public yet.


### The result

```yaml
   network:
        ----------
        hostsfile:
            ----------
            fqdn:
                srv01.pcdummy.lan
            hostname:
                srv01
        interfaces:
            |_
              ----------
              delay:
                  0
              enable_ipv6:
                  True
              enabled:
                  True
              fd:
                  0
              gateway:
                  10.167.160.1
              ipaddr:
                  10.167.160.14
              ipv6gateway:
                  fe80::1
              ipv6ipaddr:
                  fd57:1:see:bad:c0de::14
              ipv6netmask:
                  64
              ipv6proto:
                  static
              maxwait:
                  0
              name:
                  lanbr0
              netmask:
                  255.255.255.0
              ports:
                  eth0
              proto:
                  static
              stp:
                  False
              type:
                  bridge
              up_cmds:
                  - /sbin/ip -6 addr add 2001:1:see:bad:c0de::14/64 dev $IFACE
        pkgs:
            ----------
            purged:
                - resolvconf
        resolver:
            ----------
            domain:
                pcdummy.lan
            nameservers:
                - fd57:1:see:bad:c0de::18
            search:
                - pcdummy.lan

```

### So how does this work

1. salt.pillar.mongo retrieves the **host definition** from the mongodb.
2. It includes the **defaults** file and merges the host definition over the defaults.
3. It includes the **generator** with the current data stored in the **pillar** variable.
4. The generator generates the pillar data.


### Thanks ...

Thanks for reading, please leave a comment about this.