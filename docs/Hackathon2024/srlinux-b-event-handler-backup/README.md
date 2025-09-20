# Triggering remote backups on commit using SR Linux Event Handler

| Item              | Details                                                            |
| ----------------- | ------------------------------------------------------------------ |
| Short Description | Use SR Linux Event Handler System to perform configuration backups |
| Skill Level       | Beginner                                                           |
| Tools Used        | SR Linux, Event Handler, Python                                    |

When using SR Linux, a smart thing to do is set up an automatic configuration save every time a commit has been made. While this can be achieved with a system configuration setting, there is still an inherent risk of losing all your changes when the router suddenly fails. Following the [3-2-1 rule](https://www.seagate.com/de/de/blog/what-is-a-3-2-1-backup-strategy/), which says that you should maintain:

- 3 copies of the data
- 2 different media types
- 1 copy offsite

We clearly need to do some more work. We should find a way to copy the saved configuration to a remote location.

## Objective

In this lab, you will use the SR Linux [Event Handler](https://documentation.nokia.com/srlinux/24-3/books/event-handler/event-handler-overview.html) system to trigger a copy of the startup configuration file every time a commit is done to a remote location.

## Accessing a lab node

You can run this exercise on any SR Linux device in the topology. For example, on `clab-dcfpartnerws-leaf21` node.  
To login to this device, execute:

```bash
ssh admin@clab-dcfpartnerws-leaf21
```

Credentials for SRLinux nodes are: `admin/NokiaSrl1!`

To perform remote backups You can use `clab-dcfpartnerws-leaf11` to perform remote backups.  
Open a new session to `leaf11` and login to this device with:
```bash
ssh admin@clab-dcfpartnerws-leaf11
```


## Documentation resources

Below are some resources you might find interesting:

- [Event handler documentation](https://documentation.nokia.com/srlinux/24-3/books/event-handler/event-handler-configuration.html?Chandler#event-handler-config)
- [SRLinux YANG browser](https://yang.srlinux.dev/v24.3.2): use this to look for gNMI paths
- [Introduction to operational groups tutorial](https://learn.srlinux.dev/tutorials/programmability/event-handler/oper-group/oper-group-intro/): a different use-case leveraging the Event Handler by shutting down all downlink interfaces when the BGP sessions to both route reflectors fails

## Step 1: creating the backups directory

As the whole purpose of this exercise is to store the device backups outside of the device filesystem, we first need to create a remote backup location that is reachable from an SR Linux device. 

While logged in to the `leaf11` with the standard `admin` user, create a new `nokia` user that we will use for the backups:

/// tab | SR_CLI
```bash
sr_cli 
enter candidate
system aaa 
system aaa authentication user nokia password nokia superuser true
commit stay
```
///
/// tab | Bash
```bash
bash network-instance mgmt
sudo useradd -m -d /home/nokia -s /bin/bash nokia
sudo passwd nokia   
```
///

Test the user nokia and check permissions:
```bash
sudo su - nokia
pwd
sudo ls -al
```

Create the `~/backups` directory.

```bash
sudo chown -R nokia:nokia /home/nokia/
sudo chmod 700 /home/nokia/
sudo mkdir -p /home/nokia/backups
sudo chown nokia:nokia /home/nokia/backups
sudo ls -al /home/nokia/backups
```

Also create the `.ssh` folder and the `authorized_keys` files that will be required later. Ensure that permissions are set correctly:
```bash
sudo mkdir -p /home/nokia/.ssh
sudo chown -R nokia:nokia /home/nokia/.ssh
sudo chmod 700 /home/nokia/.ssh
sudo touch /home/nokia/.ssh/authorized_keys
sudo chmod 600 /home/nokia/.ssh/authorized_keys
sudo chown nokia:nokia /home/nokia/.ssh/authorized_keys
```



## Step 2: Create script file

We need to create our Python event handling script on an SR Linux box, and prepare the event handler configuration context:

Log into the `leaf21` node, go to the linux CLI (by typing `bash network-instance mgmt`) and create the script `remote-backup.py` in the `/etc/opt/srlinux/eventmgr` directory.

```bash
--{ running }--[  ]--
A:leaf21# bash network-instance mgmt
admin@leaf21:~$ cd /etc/opt/srlinux/eventmgr
admin@leaf21:/etc/opt/srlinux/eventmgr$ touch remote-backup.py
admin@leaf21:/etc/opt/srlinux/eventmgr$ chmod +x remote-backup.py
admin@leaf21:/etc/opt/srlinux/eventmgr$ ls -l .
total 4
-rwxrwxrwx+ 1 admin ntwkadmin 728 Sep 18 20:25 remote-backup.py
```

## Step 3: create the Event Handler instance

Using the [documentation](https://documentation.nokia.com/srlinux/24-3/books/event-handler/event-handler-configuration.html?handler#event-handler-config), refer to the python script you created in step 1. The following information should be added to the configuration context:

- The location to the python script you created in step 1
- A path monitoring the last time the configuration was changed (tip: use the [SRL YANG browser](https://yang.srlinux.dev/v24.3.2))
- A static value indicating the target destination (`nokia@10.128.<GID>.33:~/backups`). Replace GID with your group ID.


/// details | Solution
    type: success
Bellow an example of a possible solution

/// tab | Commands
``` bash
sr_cli
enter candidate
system event-handler instance remote-backup
    admin-state enable
    upython-script remote-backup.py
    paths [
        "system configuration last-change"
    ]
    options {
        object target {
            value nokia@10.128.6.33:~/backups
        }
    }
commit stay
```
///
///


///note
To copy files to the remote location, you can use SCP **with the IP address of the leaf21**. To ensure no password needs to be provided to the scp command, it is advised you set up key-authentication first. 
///

Below is a configuration session where this is demonstrated:

- Leave the password blank
- Make sure to test afterwards! This will add the hypervisor to the `known_hosts` file

```bash
--{ running }--[  ]--
A:leaf21# bash network-instance mgmt
admin@leaf21:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/admin/.ssh/id_rsa): /home/admin/id_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/admin/id_rsa
Your public key has been saved in /home/admin/id_rsa.pub
The key fingerprint is:
SHA256:XvotnwqZZoVbfl4seGmoy96GR4t1/RkAw8o2KmmgONE admin@leaf21
The key's randomart image is:
+---[RSA 3072]----+
|          .      |
|           +     |
| .      . . o    |
|. E.     *   .   |
|... . . S =  ..  |
|o.   + o Xoo.o.. |
| .  . . X=+o* o.o|
|       +o==* + ..|
|       .=+++=    |
+----[SHA256]-----+
```



On the `leaf11`: add the contents of the generated `~/.ssh/id_rsa.pub` file on your SRL box to the `/home/nokia/.ssh/authorized_keys` file.

/// tab | leaf21 - SRL pub key
```bash
cat ~/.ssh/id_rsa.pub
```
///
/// tab | Leaf11 - authorized keys
```bash
sudo vi /home/nokia/.ssh/authorized_keys
```
///

Validation (on the SRL box)

///note
**NOTE:** using sudo here is mandatory only at the first time ssh is run to a given host in order to store `known_hosts` file. After that, no need to prefix sudo for running ssh to the same host.
///

```bash
admin@g6-leaf21:~$ sudo ssh -i ~/.ssh/id_rsa nokia@10.128.6.33
Last login: Sat Sep 20 08:11:22 2025 from 10.128.6.41
[nokia@g6-leaf11 ~]$ 
```


///tip
To troubleshoot you may use the `-vvv` debug flag.
```bash
sudo ssh -i ~/.ssh/id_rsa nokia@10.128.6.33
sudo ssh -i ~/.ssh/id_rsa nokia@10.128.6.33 -vvv
```
Most common issues are permissions: home/.ssh/authorized_keys => 700 / 700 / 600
The other common issue is the key mismatch or syntax. The verbose output should give you hints.

///


## Step 4: develop the `remote-backup.py` script

Using the documentation resources above, find a way to achieve the requested backup functionality. A list of intermediary steps can be found below for inspiration:

1) Parse the input paths and print their values  
2) Parse the input options and print their values  
3) Obtain the timestamp of the system's last configuration change  
4) Find the location where your SRL's configuration is being stored (hint, execute `save startup` on your box)  
5) Copy the startup configuration file to the target destination  

///note
**NOTE:**
You can instruct the event handler to run a bash script: the returned `action` list should contain an object with a key `run-script` and a dictionary value containing the key `cmdline`. The cmdline template is provided below. For a hint, closely inspect the returned format by the [oper-group script](https://learn.srlinux.dev/tutorials/programmability/event-handler/oper-group/script/)
///

/// tab | cmdline template
```python
"cmdline": f"sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/id_rsa {startup_config} {target}/config-{timestamp}.json"
```
///

## Step 5 - test

This lab will be completed when the user execute `commit save stay` and the startup file is correctly copied to the target destination. The file must:

- contain the changes that were made (hence the `save` to commit them to the startup file)
- contain the timestamp of when the last change was done (important! the name should be different every time the script is executed)

Two interesting commands:

1) reloading the python file after you've made changes to it: `/ tools system event-handler instance <instance> reload`  
2) checking the execution output of your script: `/ info from state system event-handler instance <instance>`  

Example:

/// tab | Reload
``` bash
A:admin@g7-leaf21# / tools system event-handler instance remote-backup reload
/system/event-handler/instance[name=remote-backup]:
    instance remote-backup reloaded


--{ candidate shared default }--[ system event-handler ]--
```
///
/// tab | Display event-handler instance 
``` bash
A:admin@g7-leaf21# / info from state system event-handler instance remote-backup
    admin-state enable
    upython-script remote-backup.py
    oper-state up
    paths [
        "system configuration last-change"
    ]
    options {
        object target {
            value nokia@10.128.7.33:~/backups/
        }
    }
    last-execution {
        start-time "2025-09-20T11:09:13.560Z (11 seconds ago)"
        end-time "2025-09-20T11:09:15.737Z (9 seconds ago)"
        upython-duration 1
        input "{\"paths\":[{\"path\":\"system configuration last-change\",\"value\":\"2025-09-20T11:02:08.456Z\"}],\"schemas\":[{\"path\":\"system configuration last-change\"}],\"options\":{\"target\":\"nokia@10.128.7.33:~/backups/\"}}"
        output "{\"actions\": [{\"run-script\": {\"cmdline\": \"sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json nokia@10.128.7.33:~/backups/config-2025-09-20T11:02:08.456Z.json\"}}]}"
        stdout-stderr ""
    }
    last-errored-execution {
        oper-down-reason script-action-failed
        oper-down-reason-detail "Script action timed out for command 'sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/.shh/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json nokia@10.128.7.33:~/backups/config-2025-09-20T11:00:20.368Z.json'"
        start-time "2025-09-20T11:01:22.609Z (8 minutes ago)"
        end-time "2025-09-20T11:01:32.902Z (7 minutes ago)"
        upython-duration 0
        input "{\"paths\":[{\"path\":\"system configuration last-change\",\"value\":\"2025-09-20T11:00:20.368Z\"}],\"schemas\":[{\"path\":\"system configuration last-change\"}],\"options\":{\"target\":\"nokia@10.128.7.33:~/backups/\"}}"
        output "{\"actions\": [{\"run-script\": {\"cmdline\": \"sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/.shh/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json nokia@10.128.7.33:~/backups/config-2025-09-20T11:00:20.368Z.json\"}}]}"
        stdout-stderr ""
    }
    statistics {
        upython-duration 180
        execution-count 294
        execution-successes 4
        execution-errors 290
    }

--{ candidate shared default }--[ system event-handler ]--
```
///

/// details | Solution
    type: success
If you did not manage to implement the solution fully, you can find an example solution [here](solution/solution.py)

/// tab | Script
``` bash
# Copyright 2024 Nokia
# Licensed under the BSD 3-Clause License.
# SPDX-License-Identifier: BSD-3-Clause

#--{ candidate shared default }--[ system event-handler instance backup-config-on-changes ]--
#A:leaf21# info
#    admin-state enable
#    upython-script remote-backup.py
#    paths [
#        "system configuration last-change"
#    ]
#    options {
#        object target {
#            value 'nokia@10.128.<GID>.33:~/backups/'
#        }
#    }


import json

def event_handler_main(in_json_str):
    in_json = json.loads(in_json_str)
    paths = in_json["paths"]
    options = in_json["options"]

    target = options.get("target", None)
    timestamp = None
    for p in paths:
        if p['path'] == "system configuration last-change":
            timestamp = p['value']

    if not timestamp:
        timestamp = "undefined"

    response = {
        "actions": [
            {
                "run-script": {
                    "cmdline": f"sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json {target}config-{timestamp}.json"
                }
            }
        ]
    }

    return json.dumps(response)
```
///

/// tab | Test command
You may use the following command from the bash to troubleshoot. Just replace <GID> with your group ID.
```bash
#sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json nokia@10.128.<GID>.33:~/backups/<FILENAME>
sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json nokia@10.128.6.33:~/backups/Test
```
///

///

## Step 5 - and beyond

Try out one of the other labs, or extend this script even further using your own imagination. 

Possible extensions are:

- include the user that committed the changes into the filename



<p align="right">(<a href="#table-of-content">back to top</a>)</p>