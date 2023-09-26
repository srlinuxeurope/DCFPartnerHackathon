# Nokia SR Linux Streaming Telemetry & NDK Lab

This lab represents a small Clos fabric with [Nokia SR Linux](https://learn.srlinux.dev/) switches running as containers. The lab topology consists of a network fabric, plus a Streaming Telemetry stack comprised of [gnmic](https://gnmic.openconfig.net), prometheus and grafana applications.

As part of this Lab, a custom NDK application is installed on Leaf1. This application is a simple GIT client used to save the device configuration in a git repository. The NDK application has specific configuration and state elements exposed in SR Linux CLI and gNMI interfaces.

![pic1](images/lab_setup.png)

In addition to the telemetry stack, the lab also includes a modern logging stack based on Grafana Labs [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) and [loki](https://grafana.com/oss/loki/).

The prepared set of [tasks](#tasks) allows users to explore the world of Streaming Telemetry based on the Nokia SR Linux platform and learn how to configure the relevant components.

**Difficulty**: Intermediate

## Deploying the lab

The lab is deployed with the [containerlab](https://containerlab.dev) project, where [`st.clab.yml`](st.clab.yml) file declaratively describes the lab topology.

```bash
# change into the lab directory
cd $HOME/DCFPartnerHackathon/srl-telemetry-ndk-lab
# and execute
sudo containerlab deploy --reconfigure
```

To remove the lab:

```bash
sudo containerlab destroy --cleanup
```

To redeploy the lab use the same deployment command as above.

## Accessing the lab nodes

Once the lab has been deployed, you can access the network elements and telemetry applications using the DNS name of a VM and the port numbers assigned to the lab's services.

To get the list of ports allocated by containerlab, use the following command:

```bash
$ show-ports
NAMES                PORTS
clab-st-gnmic
clab-st-client2      22/tcp 80/tcp 443/tcp 1180/tcp 11443/tcp
clab-st-spine2       50093->22/tcp 50092->57400/tcp
clab-st-spine1       50091->22/tcp 50090->57400/tcp
clab-st-leaf1        50089->22/tcp 50088->57400/tcp
clab-st-grafana      3000->3000/tcp
clab-st-syslog       6514/tcp 5514/udp 6601/tcp
clab-st-loki         50087->3100/tcp
clab-st-leaf2        50084->22/tcp 50083->57400/tcp
clab-st-prometheus   50082->9090/tcp
clab-st-client1      22/tcp 80/tcp 443/tcp 1180/tcp 11443/tcp
clab-st-client3      22/tcp 80/tcp 443/tcp 1180/tcp 11443/tcp
clab-st-leaf3        50086->22/tcp 50085->57400/tcp
clab-st-promtail

```

Each service exposed on a lab node gets a unique external port number as per the table above. For example, Prometheus's web interface is available on port `50082` of the VM and is mapped to Prometheus's node internal port of `9090`.

Some well-known port numbers:

| Service    | Internal Port number |
| ---------- | -------------------- |
| SSH        | 22                   |
| Netconf    | 830                  |
| gNMI       | 57400                |
| HTTP/HTTPS | 80/443               |
| Grafana    | 3000                 |

So imagine you are assigned a VM with address `gX.dcfpartnerws.net` and the `show-ports` command matches the output above; then you can access `leaf1` via Internet with the following command:

```bash
ssh -p 50034 admin@gX.dcfpartnerws.net
```

For Grafana, we made the external port to be static as 3000 (native Grafana port) so that it can be accessible as well from VSCode interface. However, it can be accessed by pasting `gX.dcfpartnerws.net:3000` in your browser.

For lab nodes that don't have a web management interface or an SSH server, use `docker exec` to access the node's shell executed from a VM.

```bash
# to access the client nodes
sudo docker exec -it clab-st-client1 bash
```

## Fabric configuration

The DC fabric used in this lab consists of three leaves and two spines interconnected as shown in the diagram.

![pic](https://gitlab.com/rdodin/pics/-/wikis/uploads/14c768a04fc30e09b0bf5cf0b57b5b63/image.png)

Leaves and spines use Nokia SR Linux IXR-D2L and IXR-D3L chassis respectively. Each network element of this topology is equipped with a [startup configuration file](configs/fabric/) that is applied at the node's startup.

Once booted, network nodes will come up with interfaces, underlay protocols and overlay service configured. The fabric is running Layer 2 EVPN service between the leaves.

### Verifying the underlay and overlay status

The underlay network runs eBGP, while iBGP is used for the overlay network. The Layer 2 EVPN service is configured as explained in this comprehensive tutorial: [L2EVPN on Nokia SR Linux](https://learn.srlinux.dev/tutorials/l2evpn/intro/).

By connecting via SSH to one of the leaves, we can verify the status of those BGP sessions.

```
A:leaf1# show network-instance default protocols bgp neighbor
------------------------------------------------------------------------------------------------------------------
BGP neighbor summary for network-instance "default"
Flags: S static, D dynamic, L discovered by LLDP, B BFD enabled, - disabled, * slow

+-----------+---------------+---------------+-------+----------+-------------+--------------+--------------+---------------+
| Net-Inst  |     Peer      |     Group     | Flags | Peer-AS  |   State     |    Uptime    |   AFI/SAFI   | Rx/Active/Tx] |
+===========+===============+===============+=======+==========+=============+==============+==============+===============+
| default   | 10.0.2.1      | iBGP-overlay  | S     | 100      | established | 0d:0h:0m:27s | evpn         | [4/4/2]       |
| default   | 10.0.2.2      | iBGP-overlay  | S     | 100      | established | 0d:0h:0m:28s | evpn         | [4/0/2]       |
| default   | 192.168.11.1  | eBGP          | S     | 201      | established | 0d:0h:0m:34s | ipv4-unicast | [3/3/2]       |
| default   | 192.168.12.1  | eBGP          | S     | 202      | established | 0d:0h:0m:33s | ipv4-unicast | [3/3/4]       |
+-----------+---------------+---------------+-------+----------+-------------+--------------+--------------+---------------+
```

### Verifying NDK agent status

You can check the state of the NDK agent by executing an ***info from state git-client***

```
A:leaf1# info from state git-client  
    git-client {
        organization ""
        owner srlinuxeurope
        repo srl-lab-config-store
        filename leaf1-config.json
        author "srlinux demo user"
        author-email srlinux.europe@gmail.com
        branch g10-branch
        oper-state up
        statistics {
            success 0
            failure 0
        }
    }
```



## Telemetry stack

As the lab name suggests, telemetry is at its core. The following telemetry stack is used in this lab:

| Role                | Software                              |
| ------------------- | ------------------------------------- |
| Telemetry collector | [gnmic](https://gnmic.openconfig.net) |
| Time-Series DB      | [prometheus](https://prometheus.io)   |
| Visualization       | [grafana](https://grafana.com)        |

### gnmic

[gnmic](https://gnmic.openconfig.net) is an Openconfig project that allows to subscribe to streaming telemetry data from network devices and export it to a variety of destinations. In this lab, gnmic is used to subscribe to the telemetry data from the fabric nodes and export it to the prometheus time-series database.

The gnmic configuration file - [gnmic-config.yml](gnmic-config.yml) - is applied to the gnmic container at the startup and instructs it to subscribe to the telemetry data and export it to the prometheus time-series database.

### Prometheus

[Prometheus](https://prometheus.io) is a popular open-source time-series database. It is used in this lab to store the telemetry data exported by gnmic. The prometheus configuration file - [configs/prometheus/prometheus.yml](configs/prometheus/prometheus.yml) - has a minimal configuration and instructs prometheus to scrape the data from the gnmic collector with a 5s interval.

Since Prometheus stores all the metrics collected by gNMIc it is quite useful to have a way to explore the collected data. Prometheus provides a web interface that can be accessed via the over internal port `9090`. Use `show-ports` command to identify the external port mapped to prometheus' internal port.

### Grafana

Grafana is another key component of this lab as it provides the visualisation for the collected telemetry data. Lab's topology file includes grafana node and configuration parameters such as dashboards, datasources and required plugins.

Grafana dashboard provided by this repository provides multiple views on the collected real-time data. Powered by [flowchart plugin](https://grafana.com/grafana/plugins/agenty-flowcharting-panel/) it overlays telemetry sourced data over graphics such as topology and front panel views:

![pic3](https://gitlab.com/rdodin/pics/-/wikis/uploads/919092da83782779b960eeb4b893fb4a/image.png)

Using the flowchart plugin and real telemetry data users can create interactive topology maps (aka weathermap) with a visual indication of link rate/utilization.

![pic2](https://gitlab.com/rdodin/pics/-/wikis/uploads/12f154dafca1270f7a1628c1ed3ab77a/image.png)

Grafana is pre-configured with anonymous access enabled so that you can view the dashboards without authentication. To edit the dashboards you have to login with the username `admin` and password `admin`. The login button is in the top right corner of the Grafana UI.

## Traffic generation

When the lab is started, there is no traffic running between the nodes as the clients are sending any data. To run traffic between the nodes, leverage `traffic.sh` control script.

To start the traffic:

* `sudo bash traffic.sh start all` - start traffic between all nodes
* `sudo bash traffic.sh start 1-2` - start traffic between client1 and client2
* `sudo bash traffic.sh start 1-3` - start traffic between client1 and client3

To stop the traffic:

* `sudo bash traffic.sh stop` - stop traffic generation between all nodes
* `sudo bash traffic.sh stop 1-2` - stop traffic generation between client1 and client2
* `sudo bash traffic.sh stop 1-3` - stop traffic generation between client1 and client3

As a result, the traffic will be generated between the clients and the traffic rate will be reflected on the grafana dashboard.

<https://github.com/srl-labs/srl-telemetry-lab/assets/5679861/158914fc-9100-416b-8b0f-cde932895cec>

## Tasks

### 1. Explore the lab

After deploying the lab and starting the traffic as [described above](#traffic-generation), take a look at the provided Grafana Dashboard by opening its Web UI in your browser.

To access the dashboard, use the menu:

`Menu` -> `Dashboards` -> `General` -> `SR Linux Telemetry`

Check which panels are available and what data they show. Try to understand how the data is collected and how it is visualized.

### 2. Explore collected metrics in Prometheus

The telemetry pipeline used in this lab can be depicted as follows:

```
[network nodes] <--gNMI-- [gnmic] <--scrape-- [prometheus] <--query-- [grafana]
```

Prometheus acts as a database for the collected telemetry data. It is accessible via the web interface (internal port `9090`) of the `prometheus` node and can be used to explore the collected metrics. Your next step might be to explore the collected metrics in Prometheus through its Web UI to see which metrics and values Prometheus scraped from gnmic. The metric names are crucial to understanding how data is fetched; make sure it is clear how they are formed.

### 3. Collect `mgmt0` interface statistics

In the panel that reports throughput on the interfaces of the fabric nodes, you can see that the mgmt0 interface is not included in the list of interfaces.

![pic](https://gitlab.com/rdodin/pics/-/wikis/uploads/3373fe2dcc3a24f3fff4138c1216031a/image.png)

Adjust the `gnmic` config to collect statistics for the `mgmt0` interface such that it appears in the panel.

<details>
  <summary>Click here for hints, if you're stuck</summary>
  The panel is already configured to show IN/OUT statistics for the <code>gnmic_srl_if_traffic_rate_in_bps</code> metric, you just need to make sure that a certain gnmic's subscription config includes the <code>mgmt0</code> interface statistics.
<details>
  <summary> Still stuck? Click here</summary>
  The statistic blob in <code>gnmic-config.yml</code> you're looking for is <code>srl_if_traffic_rate</code>.
</details>
</details>

> **Note**  
> When you changed gnmic config, you need to restart the deployment:

>`cd $HOME/DCFPartnerHackathon/srl-telemetry-ndk-lab` <br>
>`sudo clab deploy --reconfigure`

### 4. Fix routing stats panel

Someone did a change on Friday night and removed the routing statistics subscription from gnmic and also cleared the expression in the routing statistics panel in Grafana. Your task is to fix it.

A colleague had a screenshot of how the panel looked like before the change:

![pic](https://gitlab.com/rdodin/pics/-/wikis/uploads/453cdf67033a03134d451d5d8ebd1df2/image.png)

The panel displayed the number of active, total and active ECMP'ed routes for IPv4 AFI. Currently, the panel is empty, and even the expressions to fetch the data are missing...

> **Note**  
> When you changed gnmic config, you need to restart the deployment:

>`cd $HOME/DCFPartnerHackathon/srl-telemetry-ndk-lab` <br>
>`sudo clab deploy --reconfigure`

### 5. Add a new panel with a NDK Git agent stats

If you completed the tasks above, or they weren't your cup of tea, you can add a new panel to the dashboard with the custom NDK git-client stats.

<img src="images/ndk_panel.png" width="180" height="300" />

> **Note**  
> When you changed gnmic config, you need to restart the deployment:

>`cd $HOME/DCFPartnerHackathon/srl-telemetry-ndk-lab` <br>
>`sudo clab deploy --reconfigure`

### 6. NDK Agent -  Save the config. in the Git Repository

You can commit the leaf1 config. into git

On Leaf1 execute:
```
tools git commit "g10 leaf1 group config"
```

Check in the gitlab repository that the configuration was saved under a dedicated branch for your group:

<https://github.com/srlinuxeurope/srl-lab-config-store/branches>

Verify in the newly added grafana panel that the success actions counter get updated:

<img src="images/ndk_panel_stats.png" width="180" height="300" />


### 7. Install a new CLI plugin to provide aditional CLI commands

As a last challange for this lab. we propose the instalation of a CLI plugin to provide aditional CLI reports.

On Leaf1 execute:

```
A:leaf1# bash
[admin@leaf1 ~]$ sudo rpm -ivh srl-cli-plugins-1-0.noarch.rpm 
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:srl-cli-plugins-1-0              ################################# [100%]
```

Initiate a new CLI session from the bash:
```
[admin@leaf1 ~]$ sr_cli
Using configuration file(s): []
Welcome to the srlinux CLI.
Type 'help' (and press <ENTER>) if you need any help using this.
--{ + running }--[  ]--
A:leaf1#  
```

Verify that there're new CLI root commands show ***Demo*** & show ***health***:
```
A:leaf1# show Demo  
  usage: Demo

  Local commands:
    hello             Show Demo greeting
    sysinfo           Show Demo system information

A:leaf1# show health local 
  usage: health

  Show health of this node

  Local commands:
    local             shows local device health status
```
The show ***health local*** report is collecting the state of the Uplinks, Power Suplies, FANs and TCAM.

```
A:leaf1# show health local  
-----------------------------------------
Status: Summary of device heatlh
-----------------------------------------
+---------+-------+------+------+
| Uplinks | Power | Fans | TCAM |
+=========+=======+======+======+
| OK      | OK    | OK   | OK   |
+---------+-------+------+------+
-----------------------------------------
```

Try to disable one of the uplink interfaces in Leaf1 and re-run the show health local

### 8. Change the ***'show Demo hello'*** message

Enter in the SR Linux bash, and change the corresponding CLI report python file:
````
A:leaf1# bash
[admin@leaf1 ~]$ sudo vi /opt/srlinux/python/virtual-env/lib/python3.6/site-packages/srlinux/mgmt/cli/plugins/reports/demo.py
````

Start a new CLI session from the bash and check the ***show Demo hello*** output:
```
admin@leaf1 ~]$ sr_cli
Using configuration file(s): []
Welcome to the srlinux CLI.
Type 'help' (and press <ENTER>) if you need any help using this.
--{ + running }--[  ]--
A:leaf1# show  Demo hello  
Welcome to the SR Linux Partner! This is G1 Demo!
``````

