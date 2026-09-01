---
hide:
  - navigation
---

# Welcome to the Nokia NoW DCF Hackathon - Portugal 2026

Welcome to the Nokia NoW DCF Hackathon - Portugal 2026.

We are very glad to welcome you to our annual event, currently the 4th edition of the Hackathon.

Nokia prides itself on the excellent technical products, solutions that we deliver to the market, and this event is no exception.  A large team of engineers,
developers and product managers have been working hard to deliver what, we'll hope you agree, is a challenging and informative set of activities to challenge
you, no matter what your experience level is.

## Open to all and something for everyone

Whether you're a relative novice to Nokia's products, or a seasoned expert, there is something in this event for you!  All you will need is your trusty laptop,
an afternoon of focus and possibly some coffee (supplied!) and you should find something to benefit both you and your organizations.

## Getting started

This page is your starting point into the event, it should get you familiar with the lab environment provided by Nokia, and provide an overview of the suggested sample activities.

**Please read this page all the way through before attempting any of the activities.**

During the afternoon you will work in groups (or alone if you prefer) on any projects that you are inspired to tackle or on one of the pre-provided activities of varying difficulty.

As long as you have a laptop with the ability to SSH and a web browser, we have example activities and a generic lab topology to help you progress if you don’t have something specific already in mind.

Need help, not a problem, pop your hand in the air and an eager expert will be there to guide you.

## Lab Environment

For this event each (group of) participant(s) will receive their own dedicated cloud instance (VM) running a copy of the generic lab topology.  You will see this called "your VM",
"your group's hackathon VM", "your group's event VM", "your instance", "your server" and other similar phrases in the activities.  They all mean the same thing, your own dedicated cloud instance.

If everything went according to plan, you should have received a physical piece of paper which contains:

- a group ID allocated to your group (or to yourself if you're working alone).
- SSH credentials to a public cloud instance dedicated to your group.
- HTTPS URL's for this repository and access to a web based IDE in case you don't have one installed on your operating system.

/// warning
The public cloud compute instances will be destroyed once the event is concluded.</p>
Please make sure to backup any code, config, etc. <u>offline</u> (e.g. onto your laptop) if you'd like to keep it after the hackathon.
///

### Group ID

Please refer to the paper provided by the event session leader. If nothing has been provided, not a problem, pop your hand in the air and someone will allocate you one before you can say "Aequeosalinocalcalinoceraceoaluminosocupreovitriolic".

| Group ID | hostname instance |
| --- | --- |
| 1 | 1.srexperts.net |
| 2 | 2.srexperts.net |
| ... | ... |
| **X** | **X**.srexperts.net |

### SSH

The simplest way to get going is to use your SSH client to connect to your group's event VM instance and work from there.  All tools and applications are pre-installed and you will have direct access to your entire network.

SSH is also important if you want to directly access your network from your laptop but more on that later.

|     |     |
| --- | --- |
| hostname | `refer to the paper provided or the slide presented` |
| username | `refer to the paper provided or the slide presented` |
| password | `refer to the paper provided or the slide presented` |

/// tip
If you're familiar with SSH and wish to setup passwordless access, you can use `ssh-keygen -h` to generate a public/private key pair and then `ssh-copy-id` to copy it towards your group's event instance.
///

### WiFi

WiFi is important here.  Without it your event experience is going to be rather dull.  To connect to the hackathon event's WiFi, refer to the paper provided or the slide presented.

### Topology

When accessing your event VM instance you'll find that the [SReXperts GitHub repository](https://github.com/nokia/srexperts) that contains all of the documentation, examples, solutions and loads of other great stuff, has already been cloned for you.

In this event, every group has their own complete service-provider network at their disposal.  Your network comprises an IP backbone with Provider (P) and Provider Edge (PE) routers, a broadband dial-in network, a peering edge network, an internet exchange point, multiple data-centers and a number of client and subscriber devices.  This network is already deployed, provisioned and is ready to go!

*Don't worry: This is your personal group network, you cannot impact any other groups.*

-{{ diagram(path='./images/srx.clab.drawio', title='Topology', page=0) }}-

The above topology contains a number of functional blocks to help you in areas you might want to focus on, it contains:

- An all-SR Linux network (release 26.3.1):
    - 2x PE / DCGW nodes (pe2 and pe4, 7250 IXR-X1b) directly interconnected
    - WAN core between the PEs: dual-stack OSPF (v2 for IPv4, v3 for IPv6) with LDP-signalled MPLS and iBGP (IPv4/IPv6 + EVPN + VPN-IPv4/IPv6)
    - each PE acts as EVPN route-reflector for its data center
- Data Centers:
    - DC1: a CLOS model - managed by EDA
        - 2x spines (spine11|spine12) and 3 leaf switches (leaf11|leaf12|leaf13)
    - DC2: a CLOS model - standalone
        - 2x spines (spine21|spine22) and 3 leaf switches (leaf21|leaf22|leaf23)
    - IPv6 BGP unnumbered configured in the underlay
    - DCGW Integration:
        - DC1: PE2
        - DC2: PE4
    - a Data Center Interconnect on the PEs: multi-instance ip-vrf "dci" with allow-export
      (EVPN-VXLAN towards the fabric + BGP-IPVPN over MPLS/LDP between the PEs)
- RADIUS and DNS servers attached in-band (PE4 and PE2 respectively)
- a fully working telemetry stack (gNMIc/prometheus/grafana + promtail/loki)
- Linux clients are attached to both the GRT and the DCI ip-vrf allowing a full mesh of traffic.

### Accessing Topology nodes

#### From your group's event instance VM

To access the lab nodes from within the VM, users should identify the names of the deployed nodes using the `sudo containerlab inspect` command.  You will notice they all start with `clab-srexperts-`.  Your entire network is [powered by ContainerLab](https://containerlab.dev).

If you'd like to see the full list of devices, their hostnames and IP addresses in your network use the following command.

/// tab | cmd

``` bash
sudo containerlab inspect
```

///
/// tab | output

``` bash
╭───────────────────────────┬───────────────────────────────────────┬─────────┬────────────────╮
│            Name           │               Kind/Image              │  State  │ IPv4/6 Address │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-client11   │ linux                                 │ running │ 10.128.90.36   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-client12   │ linux                                 │ running │ 10.128.90.37   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-client13   │ linux                                 │ running │ 10.128.90.38   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-client21   │ linux                                 │ running │ 10.128.90.46   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-client22   │ linux                                 │ running │ 10.128.90.47   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-client23   │ linux                                 │ running │ 10.128.90.48   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-dns        │ linux                                 │ running │ 10.128.90.15   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-gnmic      │ linux                                 │ running │ 10.128.90.71   │
│                           │ ghcr.io/openconfig/gnmic:0.43.0       │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-grafana    │ linux                                 │ running │ 10.128.90.73   │
│                           │ grafana/grafana:12.3.3                │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-leaf11     │ nokia_srlinux                         │ running │ 10.128.90.33   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-leaf12     │ nokia_srlinux                         │ running │ 10.128.90.34   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-leaf13     │ nokia_srlinux                         │ running │ 10.128.90.35   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-leaf21     │ nokia_srlinux                         │ running │ 10.128.90.43   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-leaf22     │ nokia_srlinux                         │ running │ 10.128.90.44   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-leaf23     │ nokia_srlinux                         │ running │ 10.128.90.45   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-loki       │ linux                                 │ running │ 10.128.90.76   │
│                           │ grafana/loki:3.5.10                   │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-pe2        │ nokia_srlinux                         │ running │ 10.128.90.22   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-pe4        │ nokia_srlinux                         │ running │ 10.128.90.24   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-prometheus │ linux                                 │ running │ 10.128.90.72   │
│                           │ quay.io/prometheus/prometheus:v2.54.1 │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-promtail   │ linux                                 │ running │ 10.128.90.75   │
│                           │ grafana/promtail:3.5.10               │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-radius     │ linux                                 │ running │ 10.128.90.14   │
│                           │ ghcr.io/srl-labs/network-multitool    │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-spine11    │ nokia_srlinux                         │ running │ 10.128.90.31   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-spine12    │ nokia_srlinux                         │ running │ 10.128.90.32   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-spine21    │ nokia_srlinux                         │ running │ 10.128.90.41   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
├───────────────────────────┼───────────────────────────────────────┼─────────┼────────────────┤
│ clab-srexperts-spine22    │ nokia_srlinux                         │ running │ 10.128.90.42   │
│                           │ ghcr.io/nokia/srlinux:26.3.1          │         │ N/A            │
╰───────────────────────────┴───────────────────────────────────────┴─────────┴────────────────╯
```

///

Using the names from the above output, we can login to a node using the following command:

For example, to access the `clab-srexperts-pe2` node via ssh simply type:

``` bash
ssh admin@clab-srexperts-pe2
```

#### From the Internet

Each public cloud instance has a port-range (`50000` - `51000`) exposed towards the Internet, as lab nodes spin up, a public port is allocated by the docker daemon on the public cloud instance. You can utilize those to access the lab services straight from your laptop via the Internet.

With the `show-ports` command executed on a VM you get a list of mappings between external and internal ports allocated for each node of a lab:
/// tab | cmd

``` bash
show-ports
```

///
/// tab | output

``` bash
clab-srexperts-pe2         {'22': '50022', '57400': '50322'}
clab-srexperts-pe4         {'22': '50024', '57400': '50324'}
clab-srexperts-spine11     {'22': '50031', '57400': '50331'}
clab-srexperts-spine12     {'22': '50032', '57400': '50332'}
clab-srexperts-leaf11      {'22': '50033', '57400': '50333'}
clab-srexperts-leaf12      {'22': '50034', '57400': '50334'}
clab-srexperts-leaf13      {'22': '50035', '57400': '50335'}
clab-srexperts-spine21     {'22': '50041', '57400': '50341'}
clab-srexperts-spine22     {'22': '50042', '57400': '50342'}
clab-srexperts-leaf21      {'22': '50043', '57400': '50343'}
clab-srexperts-leaf22      {'22': '50044', '57400': '50344'}
clab-srexperts-leaf23      {'22': '50045', '57400': '50345'}
clab-srexperts-client11    {'22': '50036'}
clab-srexperts-client12    {'22': '50037'}
clab-srexperts-client13    {'22': '50038'}
clab-srexperts-client21    {'22': '50046'}
clab-srexperts-client22    {'22': '50047'}
clab-srexperts-client23    {'22': '50048'}
clab-srexperts-radius      {'22': '50014'}
clab-srexperts-dns         {'22': '50015'}
clab-srexperts-prometheus  {'9090': '9090'}
clab-srexperts-grafana     {'3000': '3000'}
```

///

Each service exposed on a lab node gets a unique external port number as per the table above. For example, Grafana's web interface is available on port `3000` of the VM which is mapped to the Grafana node's internal port of `3000`.

The following table shows common container internal ports which can assist you to find the correct exposed port for the services.

| Service    | Internal Port number |
| ---------- | -------------------- |
| SSH        | 22                   |
| VSCode     | 80                   |
| gNMI       | 57400                |
| HTTP/HTTPS | 80/443               |
| Grafana    | 3000                 |
| Netbox     | 8000                 |
| EDA        | 9443                 |

Subsequently you can access the lab node on the external port for your given instance using the DNS name of the assigned VM.

| Group ID | hostname instance |
| --- | --- |
| **X** | **X**.srexperts.net |

In the example above, accessing `pe2` would be possible by:

```
ssh admin@X.srexperts.net -p 50022
```

In the example above, accessing grafana would be possible browsing towards **http://X.srexperts.net:3000** (where X is the group ID you've been allocated)

/// details | ssh-config
    type: tip

You can generate `ssh-config` using the `generate-ssh-config` command and store the output on your local laptop's SSH client, in order to connect directly to nodes.
///

### Generate Traffic

In the generic topology, linux clients are attached to a number of routers:

- the PE layer
- the leafs in each data center
- in multiple VRFs: global routing table (grt) and vprn "dci" (vprn.dci)

One can start and/or stop traffic by connecting to the relevant client using SSH, and running `/traffic.sh`, for example:

```
ssh admin@clab-srexperts-client11

client11:~$ /traffic.sh [-a <start|stop>] [-d <dns hostname>]
```

The dns hostname is composed out of the client name and a domain suffix.

| SSH | Client | Global Routing Table suffix | VPRN "DCI" suffix |
| --- | --- | --- | --- |
| clab-srexperts-client01 | client01 | .grt | .vprn.dci |
| clab-srexperts-client02 | client02 | .grt | .vprn.dci |
| clab-srexperts-client03 | client03 | .grt | .vprn.dci |
| clab-srexperts-client04 | client04 | .grt | .vprn.dci |
| clab-srexperts-client11 | client11 | .grt | .vprn.dci |
| clab-srexperts-client12 | client12 | .grt | .vprn.dci |
| clab-srexperts-client13 | client13 | .grt | .vprn.dci |
| clab-srexperts-client14 | client21 | .grt | .vprn.dci |

For example, if you'd like to start a unidirectional traffic flow from `client11` to `client21` in the global routing table:

```
client11:~$ /traffic.sh -a start -d client21.grt
starting traffic to client21.grt, binding on client11.grt, saving logs to /tmp/client21.grt.log
```

Stopping the traffic flow would be achieved by:

```
client11:~$ /traffic.sh -a stop -d client21.grt
stopping traffic to client21.grt
```

However, if you'd like to start a full mesh of traffic between `client11` and the rest of the clients, this could be achieved by executing:

```
client11:~$ /traffic.sh -a start -d all.grt
starting traffic to client01.grt, binding on client11.grt, saving logs to /tmp/client01.grt.log
starting traffic to client02.grt, binding on client11.grt, saving logs to /tmp/client02.grt.log
starting traffic to client03.grt, binding on client11.grt, saving logs to /tmp/client03.grt.log
starting traffic to client04.grt, binding on client11.grt, saving logs to /tmp/client04.grt.log
starting traffic to client12.grt, binding on client11.grt, saving logs to /tmp/client12.grt.log
starting traffic to client13.grt, binding on client11.grt, saving logs to /tmp/client13.grt.log
starting traffic to client21.grt, binding on client11.grt, saving logs to /tmp/client21.grt.log

client11:~$ /traffic.sh -a stop -d all.grt
stopping traffic to client01.grt
stopping traffic to client02.grt
stopping traffic to client03.grt
stopping traffic to client04.grt
stopping traffic to client12.grt
stopping traffic to client13.grt
stopping traffic to client21.grt
```

## FAQ

### My employer/security department locked down my laptop

No worries, we have got you covered! Each instance is running a [**web-based VS Code code-server**](./tools/tools-code-server.md) that, when accessing it at `https://<my group id>.srexperts.net`, should prompt you for a password (which is documented on the physical paper provided), and you should be able to access the topology through the terminal there. Detailed instructions on how to use the code-server are available in the [VS Code server documentation](./tools/tools-code-server.md).

Should code-server prove ineffective for your situation reach out to the staff on-site and we will try to figure out a suitable alternative for you.

### Help! I've bricked my lab, how do I redeploy?

First we destroy the lab:
/// tab | cmd

``` bash
sudo -E clab destroy -t $HOME/SReXperts/clab/srx.clab.yml --cleanup
```

///

/// tab | output

``` bash
16:58:02 INFO Parsing & checking topology file=srx.clab.yml
16:58:02 INFO Destroying lab name=srexperts
16:58:03 INFO Removed container name=clab-srexperts-gnmic
16:58:04 INFO Removed container name=clab-srexperts-promtail
16:58:05 INFO Removed container name=clab-srexperts-loki
16:58:06 INFO Removed container name=clab-srexperts-prometheus
16:58:07 INFO Removed container name=clab-srexperts-grafana
16:58:08 INFO Removed container name=clab-srexperts-radius
16:58:09 INFO Removed container name=clab-srexperts-dns
16:58:10 INFO Removed container name=clab-srexperts-client11
16:58:11 INFO Removed container name=clab-srexperts-client12
16:58:12 INFO Removed container name=clab-srexperts-client13
16:58:13 INFO Removed container name=clab-srexperts-client21
16:58:14 INFO Removed container name=clab-srexperts-client22
16:58:15 INFO Removed container name=clab-srexperts-client23
16:58:16 INFO Removed container name=clab-srexperts-leaf11
16:58:17 INFO Removed container name=clab-srexperts-leaf12
16:58:18 INFO Removed container name=clab-srexperts-leaf13
16:58:19 INFO Removed container name=clab-srexperts-leaf21
16:58:20 INFO Removed container name=clab-srexperts-leaf22
16:58:21 INFO Removed container name=clab-srexperts-leaf23
16:58:22 INFO Removed container name=clab-srexperts-spine11
16:58:23 INFO Removed container name=clab-srexperts-spine12
16:58:24 INFO Removed container name=clab-srexperts-spine21
16:58:25 INFO Removed container name=clab-srexperts-spine22
16:58:26 INFO Removed container name=clab-srexperts-pe2
16:58:27 INFO Removed container name=clab-srexperts-pe4
16:58:28 INFO Removing host entries path=/etc/hosts
16:58:28 INFO Removing SSH config path=/etc/ssh/ssh_config.d/clab-srexperts.conf
```

///
/// tab | alternate
This takes on average 20 min to redeploy, can't wait that long? Pop your hand up and ask for a new instance!

``` bash
sudo reboot
```

///

Secondly, we can deploy the lab again:
/// tab | cmd

``` bash
sudo -E clab deploy -t $HOME/SReXperts/clab/srx.clab.yml --reconfigure
```

///

/// tab | output

``` bash
16:53:13 INFO Containerlab started version=0.78.0
16:53:13 INFO Parsing & checking topology file=srx.clab.yml
16:53:13 INFO Creating docker network name=srexperts IPv4 subnet=10.128.90.0/24 IPv6 subnet="" MTU=0
16:53:13 INFO Creating lab directory path=/home/nokia/DCFPartnerHackathon/clab/clab-srexperts
16:53:13 INFO node "dns" is being delayed for 120 seconds
16:53:13 INFO node "radius" is being delayed for 120 seconds
16:53:13 INFO node "client11" is being delayed for 120 seconds
16:53:13 INFO Creating container name=pe2
16:53:13 INFO Creating container name=pe4
16:53:13 INFO Creating container name=spine11
16:53:13 INFO Creating container name=leaf11
16:53:16 INFO Created link: pe2:e1-1 ▪┄┄▪ pe4:e1-1
16:53:16 INFO Created link: pe2:e1-2 ▪┄┄▪ spine11:e1-32
16:53:17 INFO Created link: pe2:e1-3 ▪┄┄▪ spine12:e1-32
16:53:18 INFO Created link: pe4:e1-2 ▪┄┄▪ spine21:e1-32
16:53:18 INFO Created link: pe4:e1-3 ▪┄┄▪ spine22:e1-32
16:53:18 INFO Created link: spine21:e1-1 ▪┄┄▪ leaf21:e1-31
16:53:19 INFO Running postdeploy actions kind=nokia_srlinux node=spine22
[... one "Creating container" / "Created link" line per remaining node and link ...]
16:55:14 INFO Created link: pe2:e1-4 ▪┄┄▪ dns:eth1
16:55:15 INFO Created link: pe4:e1-4 ▪┄┄▪ radius:eth1
16:55:21 INFO Executed command node=client11 command="bash /client.sh" stdout=""
16:55:21 INFO Adding host entries path=/etc/hosts
16:55:22 INFO Adding SSH config for nodes path=/etc/ssh/ssh_config.d/clab-srexperts.conf
```

///

### Cloning this repository

If you would like to work locally on your personal device you should clone this repository. This can be done using one of the following commands.

HTTPS:

```bash
git clone https://github.com/nokia/SReXperts.git
```

SSH:

```bash
git clone git@github.com:nokia/SReXperts.git
```

GitHub CLI:

```bash
gh repo clone nokia/SReXperts
```

## Useful links

- [Network Developer Portal](https://network.developer.nokia.com/)

- [containerlab](https://containerlab.dev/)
- [gNMIc](https://gnmic.openconfig.net/)

### SR Linux

- [Learn SR Linux](https://learn.srlinux.dev/)
- [YANG Browser](https://yang.srlinux.dev/)
- [gNxI Browser](https://gnxi.srlinux.dev/)

### SR OS

- [SR OS Release 26.3](https://documentation.nokia.com/sr/26-3/index.html)
- [Network Developer Portal](https://network.developer.nokia.com/sr/learn/)

### Misc Tools/Software

#### Windows

- [WSL environment](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701)
- [MobaXterm](https://mobaxterm.mobatek.net/download.html)
- [PuTTY Binary](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe)

#### MacOS

- [Ghostty](https://ghostty.org/)
- [iTerm2](https://iterm2.com/downloads/stable/iTerm2-3_4_19.zip)
- [Warp](https://app.warp.dev/get_warp)
- [Hyper](https://hyper.is/)
- [Terminal](https://support.apple.com/en-gb/guide/terminal/apd5265185d-f365-44cb-8b09-71a064a42125/mac)

#### Linux

- [Ghostty](https://ghostty.org/)
- [Gnome Console](https://apps.gnome.org/en/app/org.gnome.Console/)
- [Gnome Terminal](https://help.gnome.org/users/gnome-terminal/stable/)

#### IDEs

- [VS Code](https://code.visualstudio.com/Download)
- [VS Code Web](https://vscode.dev/)
- [Sublime Text](https://www.sublimetext.com/download)
- [IntelliJ IDEA](https://www.jetbrains.com/idea/download/)
- [Eclipse](https://www.eclipse.org/downloads/)
- [PyCharm](https://www.jetbrains.com/pycharm/download)

<script type="text/javascript" src="https://viewer.diagrams.net/js/viewer-static.min.js" async></script>

## Thanks and contributions

As you can imagine, creating the activities that make up this event is a lot of work.  The event team would like to thank the following team members (in alphabetical order) for their contributions: Alejandro Aguado Martin, Alexandre Nogueira, Asad Arafat, Bhavish Khatri, Conar McGill, Diogo Pinheiro, Emre Cinar, Gordon Gidófalvy, Gustavo Ruggirello, Hans Thienpondt, James Cumming, Jeroen Rommens, João Machado, Kaelem Chandra, Karan Singh Khandelwal, Kleber Yoshiki Sato, Laleh Kiani, Louis Van Eeckhoudt, Maged Makramalla, Mathis Bramkamp, Miguel Redondo Ferrero, Roman Dodin, Saju Salahudeen, Samier Barguil, Siva Sivakumar, Sven Wisotzky, Thomas Hendriks, Tiago Amado, Victor Alenin, Víctor Serrano Bazán, Vijayalakshmi Gangireddy, Vincent Delannoy and Zeno Dhaene.