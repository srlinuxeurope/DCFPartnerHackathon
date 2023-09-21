# Welcome at the hackathon @ DC Fabric Partner Workshop!

This README is your starting point into the hackathon, it should get you familiar with the lab environment provided by Nokia, and provide an overview of the suggested sample labs.

During the morning you will work in groups (or alone if you prefer) on any project that you are inspired to tackle or on one of the pre-provided projects of varying difficulty.

As long as you have a laptop with the ability to SSH we have example projects and lab topologies to help you progress if you don’t have something specific already in mind.   

Need help, not a problem, pop your hand in the air and an eager expert will be there to guide you!

## Lab Environment
If everything went according to plan, you should have received a physical piece of paper which contains:
- a group ID allocated to your group (or to yourself if you're working alone)
- SSH credentials to a VM instance (hosted in Nokia Local Lab.) dedicated to your group. 
- HTTP URL's towards this repo and access to a web based IDE (vs-code) in case you don't have one installed on your operating system.

> <p style="color:red">!!! Make sure to backup any code, config, ... <u> offline (e.g your laptop)</u>. 
> The VM instances might be destroyed once the hackathon is concluded.</p>

### Group ID

Please refer to the paper provided by the hackathon session leader. If nothing has been provided, not a problem, pop your hand in the air and an eager expert will be there to allocate one for you. 

There will be 6 VM instances available and the allocation is the following:
| Group ID | hostname instance | ip address |
| --- | --- | ---|
| **1** | **1**.dcfpartnerws.net | 10.11.0.2***1*** |
| **2** | **2**.dcfpartnerws.net | 10.11.0.2***2*** |
| ... | ... | ...|
| **6** | **6**.dcfpartnerws.net | 10.11.0.2***6*** |

### SSH

hostname: `refer to the paper provided `

username: `refer to the paper provided or the slide presented`

password: `refer to the paper provided or the slide presented`

To enable passwordless access to an instance, use `ssh-keygen -h` to generate a public/private key pair and then `ssh-copy-id` to copy it over.

### WiFi

Details provided in the session.

### Overview of pre-provided projects
During this hackathon you can work on any problem/project you are inspired to tackle or on one of the pre-provided projects of varying difficulty.
Below you can find a table with links towards those pre-provided project which you can use as a baseline for the problem/project you might want to tackle or perform the tasks we've set up for you.

If you have your own project in mind then we would suggest to use the [Standard SR Linux lab](./srl-generic-lab/).

Each pre-provided project comes with a README of it's own, please click the pre-provided projects for more information.

| Link to pre-provided project | Difficulty |
| --- | --- |
| [Standard SR Linux](./srl-generic-lab/) | # |
| [SR Linux Streaming Telemetry](./srl-telemetry-lab/) | ## |
| [SR Linux JSON-RPC with Ansible](./srl-ansible-lab/) | ## |
| [Config Management with gNMI](./srl-sros-gnmi-config-lab/) | ### |
| [SRLinux and k8s Metal LB integration](./srl-k8s-anycast-lab/) | ### |

### Deploying a project
When accessing your hackathon VM instance you'll see the following bootstrapped environment.
the DCFPartnerHackathon directory is a git clone of this repository.

``` 
~$ ls
DCFPartnerHackathon

~$ cd DCFPartnerHackathon/

~/DCFPartnerHackathon$ ls -1
README.md
srl-ansible-lab
srl-generic-lab
srl-sros-gnmi-config-lab
srl-telemetry-lab
~/DCFPartnerHackathon$
```

For explanatory purposes, suppose we want to deploy the srl-generic-lab:

Change directories
```
cd $HOME/DCFPartnerHackathon/srl-generic-lab
```
Execute the `containerlab deploy` command
```
sudo containerlab deploy --reconfigure
```

> As CPU cores and memory are a finite resource, please destroy the deployed labs once your objective has been concluded by executing the `containerlab destroy` command.
```
sudo containerlab destroy --cleanup
```

### Credentials & Access
#### Accessing the lab from within the VM
To access the lab nodes from within the VM, users should identify the names of the deployed nodes using the `sudo containerlab inspect` command:

```
sudo containerlab inspect
INFO[0000] Parsing & checking topology file: sros-generic-lab.clab.yml
INFO[0000] Parsing & checking topology file: srl-generic.clab.yml 
+----+-------------------------+--------------+------------------------------+---------------+---------+----------------+--------------+
| #  |          Name           | Container ID |            Image             |     Kind      |  State  |  IPv4 Address  | IPv6 Address |
+----+-------------------------+--------------+------------------------------+---------------+---------+----------------+--------------+
|  1 | clab-srl-generic-h1     | 2be75127cd0f | ghcr.io/srl-labs/alpine      | linux         | running | 172.20.0.31/24 | N/A          |
|  2 | clab-srl-generic-h2     | 8d96d3078599 | ghcr.io/srl-labs/alpine      | linux         | running | 172.20.0.32/24 | N/A          |
|  3 | clab-srl-generic-h3     | 7d8c71ad7434 | ghcr.io/srl-labs/alpine      | linux         | running | 172.20.0.33/24 | N/A          |
|  4 | clab-srl-generic-h4     | 180a2abb7958 | ghcr.io/srl-labs/alpine      | linux         | running | 172.20.0.34/24 | N/A          |
|  5 | clab-srl-generic-leaf1  | 085498a8fba0 | ghcr.io/nokia/srlinux:23.7.1 | nokia_srlinux | running | 172.20.0.11/24 | N/A          |
|  6 | clab-srl-generic-leaf2  | 0d6afcf5cd72 | ghcr.io/nokia/srlinux:23.7.1 | nokia_srlinux | running | 172.20.0.12/24 | N/A          |
|  7 | clab-srl-generic-leaf3  | d5794eb6b404 | ghcr.io/nokia/srlinux:23.7.1 | nokia_srlinux | running | 172.20.0.13/24 | N/A          |
|  8 | clab-srl-generic-leaf4  | 6b3bf9ba8949 | ghcr.io/nokia/srlinux:23.7.1 | nokia_srlinux | running | 172.20.0.14/24 | N/A          |
|  9 | clab-srl-generic-spine1 | c92c00cb95f0 | ghcr.io/nokia/srlinux:23.7.1 | nokia_srlinux | running | 172.20.0.21/24 | N/A          |
| 10 | clab-srl-generic-spine2 | bfcdb9f31e22 | ghcr.io/nokia/srlinux:23.7.1 | nokia_srlinux | running | 172.20.0.22/24 | N/A          |
+----+-------------------------+--------------+------------------------------+---------------+---------+----------------+--------------+
```
Using the names from the above output, we can login to the a node using the following command:

For example to access node `clab-srl-generic-leaf1` via ssh simply type:
```
ssh admin@clab-srl-generic-leaf1
```

#### Accessing the nodes via the WiFi network

Each VM instance has a port-range (50000 - 51000) exposed towards the public network, as lab nodes spin up, a public port is dynamically allocated by the docker daemon on the VM instance.
You can utilize those to access the lab services straight from your laptop via the public network.

With the `show-ports`(*) command executed on a VM you get a list of mappings between external and internal ports allocated for each node of a lab:

```
~$ show-ports
NAMES                PORTS
clab-st-spine2       50012->22/tcp 50010->57400/tcp
clab-st-leaf1        50011->22/tcp 50008->57400/tcp
clab-st-leaf2        50009->22/tcp 50007->57400/tcp
clab-st-leaf3        50006->22/tcp 50005->57400/tcp
clab-st-syslog       6514/tcp 5514/udp 6601/tcp
clab-st-grafana      50004->3000/tcp
clab-st-client1      22/tcp 80/tcp 443/tcp 1180/tcp 11443/tcp
clab-st-loki         50002->3100/tcp
clab-st-client2      22/tcp 80/tcp 443/tcp 1180/tcp 11443/tcp
clab-st-prometheus   50003->9090/tcp
clab-st-promtail
clab-st-gnmic
clab-st-client3      22/tcp 80/tcp 443/tcp 1180/tcp 11443/tcp
clab-st-spine1       50001->22/tcp 50000->57400/tcp
```
(*) `show-ports` is actualy an alias on bash that provides a more user-friendly output for the docker command line

Each service exposed on a lab node gets a unique external port number as per the table above. 
In the given case, Grafana's web interface is available on port 50004 of the VM which is mapped to Grafana's node internal port of 3000.

The following table shows common container internal ports and is meant to help you find the correct exposed port for the services.

| Service    | Internal Port number |
| ---------- | -------------------- |
| SSH        | 22                   |
| Netconf    | 830                  |
| gNMI       | 57400                |
| HTTP/HTTPS | 80/443               |
| Grafana    | 3000                 |

Subsequently you can access the lab node on the external port for your given instance using the DNS name of the assigned VM.

| Group ID | hostname instance |
| --- | --- |
| **X** | **X**.dcfpartnerws.net |

In the example above, accessing Leaf1 on group 1 would be possible by: 
```
ssh admin@1.dcfpartnerws.net -p 50104
```

In the example above, accessing grafana would be possible browsing towards **http://X.dcfpartnerws.net:50004** (where X is the group ID you've been allocated)

Optional:
> You can generate `ssh-config` using the `generate-ssh-config` command and store the output on your local laptop's SSH client, in order to connect directly to nodes.

## clone this repo
If you would like to work locally on your personal device you should clone this repository. This can be done using one of the following commands.

> HTTPS
```
git clone https://github.com/srlinuxeurope/DCFPartnerHackathon.git
```
> SSH
```
git clone git@github.com:srlinuxeurope/DCFPartnerHackathon.git
```
> GH CLI
```
gh repo clone srlinuxeurope/DCFPartnerHackathon
```
## Useful links

* [Network Developer Portal](https://network.developer.nokia.com/)
* [containerlab](https://containerlab.dev/)
* [gNMIc](https://gnmic.openconfig.net/)

### SR Linux
* [Learn SR Linux](https://learn.srlinux.dev/)
* [YANG Browser](https://yang.srlinux.dev/)
* [gNxI Browser](https://gnxi.srlinux.dev/)

### SR OS
* [pySROS](https://network.developer.nokia.com/static/sr/learn/pysros/latest/index.html)

### Misc Tools/Software
#### Windows

* [WSL environment](https://learn.microsoft.com/en-us/windows/wsl/install)
* [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701)
* [MobaXterm](https://mobaxterm.mobatek.net/download.html)
* [PuTTY Installer](https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.78-installer.msi)
* [PuTTY Binary](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe)


#### MacOS

* [iTerm2](https://iterm2.com/downloads/stable/iTerm2-3_4_19.zip)
* [Warp](https://app.warp.dev/get_warp)
* [Hyper](https://hyper.is/)
* [Terminal](https://support.apple.com/en-gb/guide/terminal/apd5265185d-f365-44cb-8b09-71a064a42125/mac)

#### Linux

* [Gnome Console](https://apps.gnome.org/en/app/org.gnome.Console/)
* [Gnome Terminal](https://help.gnome.org/users/gnome-terminal/stable/)

#### IDEs

* [VS Code](https://code.visualstudio.com/Download)
* [VS Code Web](https://vscode.dev/)
* [Sublime Text](https://www.sublimetext.com/download)
* [IntelliJ IDEA](https://www.jetbrains.com/idea/download/)
* [Eclipse](https://www.eclipse.org/downloads/)
* [PyCharm](https://www.jetbrains.com/pycharm/download)



