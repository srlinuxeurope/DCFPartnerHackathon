# Nokia SR Linux Ansible Lab

Ansible is one of the leading configuration management frameworks both in the application and networking realms. It provides a quick route to network automation by offering a simple domain-specific language (DSL) and a rich collection of modules written for different platforms and services.

Nokia offers Ansible users the [`nokia.srlinux`](https://learn.srlinux.dev/ansible/collection/) Ansible collection that stores plugins and modules designed to perform automation tasks against Nokia SR Linux Network OS. The modules in `nokia.srlinux` collection are designed in a generic way with universal modules enabling all configuration operations.

This lab provides a playground to sharpen your Ansible skills on Nokia SR Linux devices.

## Lab Topology

The lab topology consists of two Nokia SR Linux devices, `srl1` and `srl2`, and a Linux host running Ansible. The devices are connected to each other via a single link. A simple topology design lets you focus on Ansible and Nokia SR Linux integration.

![pic](https://gitlab.com/rdodin/pics/-/wikis/uploads/1072f8c533eb46fc61acfde56562d159/image.png)

The nodes do not have any configuration applied besides the default config. The JSON-RPC is already enabled on the devices and running over ports 80 and 443, such that the Ansible can communicate with the devices.

## Deploying the Lab

The lab uses [containerlab](https://containerlab.dev) lab emulation tool that is pre-installed on the lab VM.

To deploy the lab, change to the `srl-ansible-lab` directory and run the following command:

```bash
cd $HOME/DCFPartnerHackathon/srl-ansible-lab
sudo clab deploy -c
```

## Accessing the lab nodes

Once the lab is deployed, you can access the network elements via the network management interfaces. The connection can be made from the VM where the lab is running or from the internet using the IP address assigned to the VM.

To access the nodes from the Lab VM, use the addresses presented in the table below:

| Node | SSH (pass: `NokiaSrl1!`)      | HTTP                   | HTTPS                   |
| ---- | ----------------------------- | ---------------------- | ----------------------- |
| srl1 | `ssh admin@clab-ansible-srl1` | `clab-ansible-srl1:80` | `clab-ansible-srl1:443` |
| srl2 | `ssh admin@clab-ansible-srl2` | `clab-ansible-srl2:80` | `clab-ansible-srl2:443` |

If you wish to have direct external access from your machine, use the name of the VM and the external port numbers as per the output of `show-ports` command executed on a lab VM:

| Node | SSH (pass: `NokiaSrl1!`)      | HTTP                         | HTTPS                         |
| ---- | ----------------------------- | ---------------------------- | ----------------------------- |
| srl1 | `ssh -p <ext-port> admin@X.dcfpartnerws.net` | `X.dcfpartnerws.net:<ext-port-for-port-80>` | `X.dcfpartnerws.net:<ext-port-for-port-443>` |
| srl2 | `ssh -p <ext-port> admin@X.dcfpartnerws.net` | `X.dcfpartnerws.net:<ext-port-for-port-80>` | `X.dcfpartnerws.net:<ext-port-for-port-443>` |

In the context of SR Linux's Ansible collection, we are primarily interested in the HTTP(S) ports, as they are used by the collection to communicate with the device.

## Ansible & SR Linux collection

Ansible core (v2.13.8) is already pre-installed on the Lab VM, but you need to download the [SR Linux Ansible collection](https://learn.srlinux.dev/ansible/collection/):
```
ansible-galaxy collection install nokia.srlinux
```

SR Linux Ansible collection docs can be found at [learn.srlinux.dev](https://learn.srlinux.dev/ansible/collection/) portal with a good number of examples and use cases. You will have to refer to the documentation to understand how the modules are composed and complete the lab tasks.

### Inventory

The lab comes with a pre-configured Ansible inventory file that defines the nodes and their connection parameters. The inventory file is located in the `srl-ansible-lab` directory and is named [`inventory.yml`](inventory.yml).

Note that Containerlab also auto-generates an Ansible inventory file for each lab; it can be found under clab-ansible/ansible-inventory.yml

If you want to use Ansible from your machine, you will have to copy the inventory file to your machine and adjust the connection parameters to match the ports and addresses of the nodes given the lab VM DNS name and exposed ports.

## Tasks

### 1. Get to know the collection

Start with reading the [collection documentation](https://learn.srlinux.dev/ansible/collection/) to understand the collection's structure and how it is used. The provided examples will help you to get started.

### 2. Get the nodes' information

The first task is to get the basic system information of the nodes using `state` datastore of SR Linux. You will have to leverage the `get` module.

To identify which path to use to get the system information you can use [the SR Linux'es YANG Browser](https://yang.srlinux.dev).

The result should be an Ansible playbook [`get_sys_info.yml`](get_sys_info.yml) that prints out the versions:
```
ansible-playbook ./get_sys_info.yml -i inventory.yml -v
```

The default output is not easily human-readable, so you can use one of the options:

1- prepend the command with ANSIBLE_STDOUT_CALLBACK=yaml:
```
ANSIBLE_STDOUT_CALLBACK=yaml ansible-playbook ./get_sys_info.yml -i inventory.yml -v
```

2- edit the ansible.cfg file and include the following configuration:
```
sudo vi /etc/ansible/ansible.cfg
------
[defaults]
# Human-readable output
stdout_callback = yaml
```


### 3. Configure IP interfaces

Nodes `srl1` and `srl2` are interconnected over their `ethernet-1/1` interface. The interface is not configured, and the nodes cannot communicate with each other.

```
--{ running }--[  ]--
A:srl1# show interface ethernet-1/1 
=========================================
ethernet-1/1 is up, speed 25G, type None
-----------------------------------------
=========================================
```

Your task is to configure the `ethernet-1/1` interface on both nodes with IPv4 addresses and ensure that nodes can ping each other via this interface.

Create a playbook config_ip.yml with the proper structure for each node and run it:

```
$ ansible-playbook config_ip.yml -i inventory.yml -v
```

Then log into the nodes and confirm that the addresses were configured and they can ping each other:
```
A:srl1# show interface ethernet-1/1
==================================================================================================================================================================
ethernet-1/1 is up, speed 25G, type None
  ethernet-1/1.0 is down, reason no-ip-config
    Network-instances:
    Encapsulation   : null
    Type            : routed
    IPv4 addr    : 1.1.1.1/30 (static, None)
------------------------------------------------------------------------------------------------------------------------------------------------------------------
==================================================================================================================================================================
--{ + running }--[  ]--
A:srl1# ping 1.1.1.2
Using network instance mgmt
PING 1.1.1.2 (1.1.1.2) 56(84) bytes of data.
64 bytes from 1.1.1.2: icmp_seq=1 ttl=57 time=8.34 ms
64 bytes from 1.1.1.2: icmp_seq=2 ttl=57 time=10.1 ms
^C
--- 1.1.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 8.337/9.241/10.145/0.904 ms
```


### 4. Collect version information in a CLI format

As part of the network documentation process, you need to collect the version information from the nodes in a CLI format, i.e. `show version`. Which module would you use for this task? Can you save the output to a file?

Create a playbook show_version_cli.yml with the proper structure for each node and run it:

```
$ ansible-playbook show_version_cli.yml -i inventory.yml -v
Using /etc/ansible/ansible.cfg as config file

PLAY [Execute "show version" CLI command] ************************************************************************************************************************

TASK [Execute "show version" CLI command] ************************************************************************************************************************
ok: [clab-ansible-srl1] => changed=false
  jsonrpc_req_id: 2023-09-22 15:53:25:357090
  jsonrpc_version: '2.0'
  result:
  - basic system info:
      Architecture: x86_64
      Build Number: 163-gd408df6a0c
      Chassis Type: 7220 IXR-D2
      Free Memory: 27787898 kB
      Hostname: srl1
      Last Booted: '2023-09-22T15:35:58.543Z'
      Part Number: Sim Part No.
      Serial Number: Sim Serial No.
      Software Version: v23.7.1
      System HW MAC Address: 1A:A8:00:FF:00:00
      Total Memory: 32091839 kB
ok: [clab-ansible-srl2] => changed=false
  <-----  snip   ----->

```

### 5. Clear interface statistics counters

The `ethernet-1/1` interface on both nodes has some traffic flowing through it after you issue the ping. You need to clear the interface statistics counters. Do you know which module to use for this task?
