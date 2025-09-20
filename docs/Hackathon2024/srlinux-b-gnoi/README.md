# Using gNOI with SR Linux

| Item | Details |
| --- | --- |
| Short Description | Use gNOI file service for managing files on SR Linux |
| Skill Level | Beginner |
| Tools Used | SR Linux, gNOIc, Programming language of your choice |

The gRPC Network Operations Interface (gNOI) defines a set of gRPC-based micro-services for executing operational commands on network devices. [gNOI service](https://github.com/openconfig/gnoi) is defined by OpenConfig.

gNOI supports Remote Procedure Calls (RPC) that can be used for Device reset, File operations, Hardware health check, Software upgrade and some general services like ping. gNOI like other gRPC services works in a client-server model where the client sends a RPC request to the server which executes the requested action and returns a response.

```
gNOI client (on VM) -------------(Request)-------------> gNOI server (SRLinux)
gNOI client (on VM) <------------(Response)------------- gNOI server (SRLinux)
```

For an easy read on gNOI RPCs and their parameters, visit [gNxI Documentation](https://gnxi.srlinux.dev/) developed by Nokia SR Linux team using the same gNxI RPC information from GitHub.

Refer to [Nokia SR Linux guide](https://documentation.nokia.com/srlinux/24-3/books/system-mgmt/gnoi-system-mgmt.html) for more information on SR Linux implementation of gNOI services.

If you prefer to listen rather than read, take a look at this [NANOG Video](https://www.youtube.com/watch?v=DldQtjPjKDk) by Nokia on gNOI services and a demo of SR Linux software upgrade using gNOI.

There are many clients that support gNOI services, the most common one is [gNOIc](https://gnoic.kmrd.dev/) developed by Nokia.

## DCF Partners Hackathon

As part of this Hackathon, we will be exploring gNOI file services on SR Linux.

## gNOI File Service

In the gNOI file service, OpenConfig defines a generic interface to perform file operational tasks. For information see [gNOI specification](https://github.com/openconfig/gnoi/blob/master/file/file.proto)

SR Linux supports the following gNOI file RPCs:

- Get RPC 
- Put RPC
- Stat RPC
- Remove RPC

## Getting Ready

### SR Linux Configuration for gNOI

Open a new session to `leaf11` and login to this device with:
```bash
ssh admin@clab-dcfpartnerws-leaf11
```
Credentials for SRLinux nodes are: `admin/NokiaSrl1!`

Login to the SR Linux device and configure/verify the following. When deploying a SR Linux container using [Containerlab](https://containerlab.dev/), gRPC and gNOI are enabled by Containerlab by default. It is ready to use.

The below example is provided as a reference for an insecure connection that should only be used in lab environments. By default, Containerlab sets up a secured TLS connection for gRPC services, but it may not be available in your setup as we override CLAB configs for the hackathon. We all replace default port `57400` with `57410`.

```
set / system grpc-server mgmt admin-state enable
set / system grpc-server mgmt network-instance mgmt
set / system grpc-server mgmt services [ gnoi ]

```

To view configuration, use `info from running /system grpc-server mgmt`.
Below is the actual configuration pushed by Containerlab to all SR Linux nodes. Check that this configuration exists in your lab environment.

```
--{ running }--[  ]--
A:leaf11# info system grpc-server mgmt
    system {
        grpc-server mgmt {
            admin-state enable
            rate-limit 65000
            tls-profile clab-profile
            network-instance mgmt
            trace-options [
                request
                response
                common
            ]
            services [
                gnmi
                gnoi
                gribi
                p4rt
            ]
            unix-socket {
                admin-state enable
            }
        }
    }

--{ running }--[  ]--

--{ running }--[  ]--
A:leaf11# info system tls server-profile clab-profile
    system {
        tls {
            server-profile clab-profile {
                key $aes1$ATDdSPG9IXSBnW8=$/IvtXhKLj5l1H9
                certificate "-----BEGIN CERTIFICATE-----
MIID0jCCArqgAwIBAgICBnowDQYJKoZIhvcNAQELBQAwVTELMAkGA1UEBhMCVVMx
ZVmupvtACHHh5GiTgiXO9xXoATYDVA==
-----END CERTIFICATE-----
"
                authenticate-client false
            }
        }
    }

--{ running }--[  ]--
```


### gNOI client

You may install gNOIc in your VM the single command below. Further details on [gNOIc](https://gnoic.kmrd.dev/) page.

```bash
bash -c "$(curl -sL https://get-gnoic.kmrd.dev)"
```

You may test if gNOIc is already installed using `gnoic version`.

```
# gnoic version
version : 0.0.21
 commit : bc327f6
   date : 2024-04-25T00:20:06Z
 gitURL : https://github.com/karimra/gnoic
   docs : https://gnoic.kmrd.dev  
```

## Introduction to gNOI File RPCs

We are going to do a quick review of the gNOI file RPCs supported on SR Linux.

After this review, we will start using gNOI to simulate real world use cases.

### Listing Files on SR Linux Filesystem

We are going to start this exercise by listing the files on the SR Linux filesystem.

The Stat RPC returns metadata about files on the target node.

If the path specified in the StatRequest references a directory, the StatResponse returns the metadata for all files and folders, including the parent directory. If the path references a direct path to a file, the StatResponse returns metadata for the specified file only.

The target node returns an error if:  
- The file does not exist.  
- An error occurs while accessing the metadata.  

Let's go ahead and list files in the /opt/srlinux directory. We will be using the `--skip-verify` flag in gNOIc to indicate that the target should skip the signature verification steps.

```bash
nokia@g6:~$ gnoic -a clab-dcfpartnerws-leaf11:57410 -u admin -p NokiaSrl1! --skip-verify file stat --path /opt/srlinux
+--------------------------------+-------------------------+---------------------------+------------+------------+------+
|          Target Name           |          Path           |       LastModified        |    Perm    |   Umask    | Size |
+--------------------------------+-------------------------+---------------------------+------------+------------+------+
| clab-dcfpartnerws-leaf11:57410 | /opt/srlinux/appmgr     | 2025-08-19T02:09:01+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/bin        | 2025-08-19T02:09:02+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/deviations | 2025-08-19T02:09:02+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/etc        | 2025-08-19T02:09:01+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/eventmgr   | 2025-08-19T02:08:58+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/imm        | 2025-08-19T02:08:59+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/kexec      | 2025-08-19T02:09:01+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/lib        | 2025-08-19T02:09:02+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/mappings   | 2025-08-19T02:09:02+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/models     | 2025-08-19T02:09:04+01:00 | drwxrwxrwx | -----w--w- | 0    |
|                                | /opt/srlinux/osync      | 2025-08-19T02:09:00+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/phy        | 2025-08-19T02:08:57+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/protos     | 2025-08-19T02:09:02+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/python     | 2025-08-19T02:09:00+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/snmp       | 2025-08-19T02:09:03+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/systemd    | 2025-08-19T02:09:03+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/usr        | 2025-08-19T02:08:57+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/var        | 2025-06-05T16:55:53+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/version    | 2025-08-19T02:09:04+01:00 | drwxr-xr-x | -----w--w- | 0    |
|                                | /opt/srlinux/ztp        | 2025-08-19T02:09:04+01:00 | drwxr-xr-x | -----w--w- | 0    |
+--------------------------------+-------------------------+---------------------------+------------+------------+------+
nokia@g6:~$ 

```

Tip - Try adding the `--format json` option at the end to see the above output in json format.

```bash
gnoic -a clab-dcfpartnerws-leaf11:57410 -u admin -p NokiaSrl1! --skip-verify file stat --path /opt/srlinux --format json
```

### Getting Files from SR Linux

Next we are going to transfer a file from the device to our host VM.

The Get RPC reads and streams the contents of a file from a target node to the client using sequential messages, and sends a final message containing the hash of the streamed data before closing the stream.

The target node returns an error if:  

- An error occurs while reading the file.  
- The file does not exist.  

Create a directory on the VM and name it `srl-gnoi-<yourname>`. We will transfer the `srl_boot.log` file from the router to this directory. Verify the file was transferred to the VM.

```
For example, if your name is Chris, the directory will be named srl-gnoi-chris.

# mkdir srl-gnoi-chris
# cd srl-gnoi-chris
```

```bash
nokia@g6:~/srl-gnoi-chris$ sudo gnoic -a clab-dcfpartnerws-leaf11:57410 -u admin -p NokiaSrl1! --skip-verify file get --file /var/log/srlinux/srl_boot.log --dst .
INFO[0000] "clab-dcfpartnerws-leaf11:57410" received 26590 bytes 
INFO[0000] "clab-dcfpartnerws-leaf11:57410" file "/var/log/srlinux/srl_boot.log" saved 
nokia@g6:~/srl-gnoi-chris$ 
```

```bash
nokia@g6:~/srl-gnoi-chris$ tail -f ./var/log/srlinux/srl_boot.log 
[01:46:14.631]:[32_sr_sshkeys_permission.sh]:[17]: executing /opt/srlinux/bin/bootscript/33_sr_login_pamd_fix.sh
[01:46:14.641]:[33_sr_login_pamd_fix.sh]:[17]: executing /opt/srlinux/bin/bootscript/34_sr_pam_limits.sh
[01:46:14.661]:[34_sr_pam_limits.sh]:[17]: executing /opt/srlinux/bin/bootscript/36_sr_ethtool_mgmt.sh
[01:46:14.672]:[36_sr_ethtool_mgmt.sh]:[17]: executing /opt/srlinux/bin/bootscript/37_sr_cpu_performance.sh
[01:46:14.683]:[37_sr_cpu_performance.sh]:[17]: executing /opt/srlinux/bin/bootscript/50_sr_link_squashfs.sh
[01:46:14.693]:[50_sr_link_squashfs.sh]:[17]: /var/run/srldpapps is not a mountpoint
[01:46:14.701]:[50_sr_link_squashfs.sh]:[17]: executing /opt/srlinux/bin/bootscript/51_sr_update_imminittar.sh
[01:46:14.720]:[51_sr_update_imminittar.sh]:[17]: executing /opt/srlinux/bin/bootscript/60_sr_rescue_nsh.sh
[01:46:14.733]:[60_sr_rescue_nsh.sh]:[17]: executing /opt/srlinux/bin/bootscript/85_sr_debug_infos.sh
[01:46:14.749]:[85_sr_debug_infos.sh]:[17]: executing /opt/srlinux/bin/bootscript/89_sr_start_srlinux.sh
^C
nokia@g6:~/srl-gnoi-chris$ 
```

### Putting Files to SR Linux

Now we are ready to transfer a file from our VM to the SR Linux device.

The Put RPC streams data to the target node and writes the data to a file. The client streams the file using sequential messages. The initial message contains information about the filename and permissions. The final message includes the hash of the streamed data.

The target node returns an error if:

- An error occurs while writing the data.
- The location does not exist.

Select or create a file on your VM (in your own directory) to be transferred over to the device. Verify the file transferred on the router.

```
cd /tmp
echo "show interface" > show-int.txt
```

```
nokia@g6:/tmp$ gnoic -a clab-dcfpartnerws-leaf11:57410 -u admin -p NokiaSrl1! --skip-verify file put --file show-int.txt --dst /tmp/show-int.txt
INFO[0000] "clab-dcfpartnerws-leaf11:57410" sending file="show-int.txt" hash 
INFO[0000] "clab-dcfpartnerws-leaf11:57410" file "show-int.txt" written successfully 
```

```bash
On the router:

admin@g6-leaf11:~$ sudo cat /tmp/show-int.txt 
show interface
admin@g6-leaf11:~$
```

Tip: Try executing the file we just transferred using the `source` command in SR Linux.

```bash
--{ + running }--[  ]--
A:admin@g6-leaf11# source /tmp/show-int.txt
Sourcing commands from '/tmp/show-int.txt'
0 lines ================================================================================================================================================================================================================================================================
ethernet-1/1 is up, speed 25G, type None
  ethernet-1/1.1 is up
    Network-instances:
      * Name: macvrf1 (mac-vrf)
    Encapsulation   : vlan-id 1
    Type            : bridged
  ethernet-1/1.101 is up
    Network-instances:
      * Name: macvrf101 (mac-vrf)
    Encapsulation   : vlan-id 101
    Type            : bridged
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

```

### Removing Files from SR Linux

Next we are going to remove or delete the file that we just transferred.

The Remove RPC removes the specified file from the target node.

The target node returns an error if:

- An error occurs during the remove operation (for example, permission denied).
- The file does not exist.
- The path references a directory instead of a file.

```bash
nokia@g6:/tmp$ gnoic -a clab-dcfpartnerws-leaf11:57410 -u admin -p NokiaSrl1! --skip-verify file remove --path /tmp/show-int.txt
INFO[0000] "clab-dcfpartnerws-leaf11:57410" file "/tmp/show-int.txt" removed successfully 
nokia@g6:/tmp$ 
```

```bash
On the router:

--{ + running }--[  ]--
A:admin@g6-leaf11# bash cat /tmp/show-int.txt
cat: /tmp/show-int.txt: No such file or directory

--{ + running }--[  ]--
A:admin@g6-leaf11#
```

## Practical scenarios with gNOI

Now that you are an expert on gNOI, let's start using gNOI for some real world scenarios.

### Configuration Backups

The goal of this hackathon activity is to establish regular configuration backups of your SR Linux device on an external machine.

Try writing a script in the language of your choice that will use gNOI file service to get the configuration file from the device. After the file transfer is completed, rename the file with the current timestamp and copy it to a directory specifically created for backups. Schedule the script to run every 10 minutes on the server.

For ideas and solutions, refer to the [Solutions](./solutions/README.md) page.

### Bulk File Transfers

Your Network Automation team developed a new agent that works similar to ChatGPT for information on the device. You are responsible to transfer the agent package file to all 1000 SR Linux devices in your network.

The goal of this hackathon activity is to use gNOI file service to transfer files to your SR Linux device.

Try writing a script in the language of your choice that will use gNOI file service to run through a list of devices and transfer the agent package file. After the transfer is completed, verify that the file exists on the device using gNOI file service.

For ideas and solutions, refer to the [Solutions](./solutions/README.md) page.

Note - The same use case also applies to file transfer of software images as part of the software upgrade process. SR Linux also supports the gNOI OS service that can be used to transfer the software image and perform the software upgrade.

### Bulk File Deletions

Let's assume we completed a network wide software upgrade 6 months ago and now we can initiate a deletion of the old software files from our devices in order to reduce the flash disk usage.

The goal of this hackathon activity is to use gNOI file service to verify that the file exists on the device and then delete the old software files on all routers in your network.

Try writing a script in the language of your choice that will use gNOI file service to run through a list of devices, list the file and delete file on each device. After the delete operation is completed, verify that the file does not exist anymore on the router.

Since we are using containerlab for this hackathon and there are no software files stored on SR Linux container nodes deployed in this lab, we will be deleting the file we transferred in the previous use case (my-gpt.deb).

For ideas and solutions, refer to the [Solutions](./solutions/README.md) page.

## Summary

In this hackathon activity, we learned about using gRPC gNOI service for file management. We used Get, Put, List and Delete RPCs for real world use cases.

Now that you are an expert in gNOI, start thinking of taking advantage of this service in your network. For any questions, please reach out to any of the members in the Hackathon team or contact your Account team.

Thank you for choosing this use case ! We hope you enjoyed this activity.

