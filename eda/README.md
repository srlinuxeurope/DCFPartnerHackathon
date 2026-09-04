# EDA Onboard Notes

**These commands are for documentation purposes only, everything has been preempted on the cloud instances.**

You may follow this procedure in case you want to run this lab on your own environment. 

> [!WARNING]
> EDA requires a valid license. 
> Reach out your Nokia's representative to request a trial license to run this lab.

## Clone playground

Clone the EDA playground to your home directory (you may choose another one) and enter the `playground` directory:

```shell
cd ~
git clone https://github.com/nokia-eda/playground.git && cd playground
```

## Ensure sysctls are raised

Sysctls needs to be raised to ensure EDA runs smoothly.

While in the `playground` dir call:

```shell
make configure-sysctl-params
```

## Download tools

While in the `playground` dir call:

```shell
make download-tools
```

## Make tools available in PATH

To make the tools available in PATH, run the following command and prepend the path with the directory of the tools:

```shell
export PATH=$(realpath ./tools):$PATH
```

### kubectl completions

> [!NOTE]
> <small>From https://spacelift.io/blog/kubectl-auto-completion#how-to-set-up-kubectl-autocomplete-in-a-linux-bash-shell</small>

Run this once during the setup of the host (should be executed after `bash-completion` is installed):

```shell
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
```

### kubectl alias

During the setup run:

```shell
echo 'alias k=kubectl' >>~/.bashrc
```

Also to enable completions on the alias, run once during setup:

```shell
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

## edactl

To allow users to use `edactl` from the lab host, we need to setup an alias that would use edactl from the EDA's toolbox pod.

This should go into the shell rc file

```shell
alias edactl='kubectl -n eda-system exec -it $(kubectl -n eda-system get pods \
-l eda.nokia.com/app=eda-toolbox -o jsonpath="{.items[0].metadata.name}") \
-- edactl'
```

## Deploy EDA

Run the following command to install EDA:

```shell
SIMULATE=false make try-eda
```

> [!NOTE]
> To manage Containerlab nodes as well as real HW, `SIMULATE` flag **must** be set to `false`.

The installation will take several minutes. You may use the following command in another terminal to monitor the progress and confirm when all pods are running:

```shell
kubectl get pods -A
```

<details>
<summary>Output</summary>

```shell
nokia@g21:~$ kubectl get pods -A
NAMESPACE            NAME                                                 READY   STATUS    RESTARTS   AGE
cert-manager         cert-manager-76b8498f9-lv4zc                         1/1     Running   0          13m
cert-manager         cert-manager-cainjector-6b74fb5dbb-t5rtr             1/1     Running   0          13m
cert-manager         cert-manager-webhook-7c6557d899-mwthj                1/1     Running   0          13m
eda-system           cert-manager-csi-driver-v75q7                        3/3     Running   0          13m
eda-system           eda-ai-engine-6dfcb886dc-hl45p                       1/1     Running   0          10m
eda-system           eda-api-7fc8d47c79-bl7cv                             1/1     Running   0          10m
eda-system           eda-appstore-7c7dc8c8bf-9jsj6                        2/2     Running   0          10m
eda-system           eda-asvr-6cdf49b94f-l6nxj                            1/1     Running   0          10m
eda-system           eda-bsvr-84bfdbbff5-485dd                            1/1     Running   0          10m
eda-system           eda-ce-5585b74657-cjgc9                              1/1     Running   0          12m
eda-system           eda-cert-checker-6b45bb4bcc-dn9vh                    1/1     Running   0          10m
eda-system           eda-cluster-manager-584f875699-vm8h7                 1/1     Running   0          10m
eda-system           eda-fe-7dbcdf6d8c-rzczp                              1/1     Running   0          10m
eda-system           eda-git-754cc59c54-8bs2s                             1/1     Running   0          12m
eda-system           eda-git-replica-5f76d55557-zql7m                     1/1     Running   0          12m
eda-system           eda-keycloak-5b7c96cd7f-65xf8                        1/1     Running   0          10m
eda-system           eda-logoutput-fluentbit-8bvj4                        1/1     Running   0          10m
eda-system           eda-logoutput-fluentbit-collector-78dd4f9bb7-ftfbq   1/1     Running   0          10m
eda-system           eda-metrics-server-7dfb6b88c8-w6clw                  1/1     Running   0          10m
eda-system           eda-pe-77fdbdcd8c-96p7f                              1/1     Running   0          10m
eda-system           eda-postgres-56bdd9c94-ttbbr                         1/1     Running   0          10m
eda-system           eda-sa-784dddd5c8-554bx                              1/1     Running   0          10m
eda-system           eda-sc-6bbb558f89-lngbn                              1/1     Running   0          10m
eda-system           eda-se-847b86f44-gbqn5                               1/1     Running   0          10m
eda-system           eda-toolbox-57dd4f468c-rq526                         1/1     Running   0          12m
eda-system           eda-workflow-1-fk2rc                                 1/1     Running   0          6m
eda-system           trust-manager-5c56b66d89-5fjnt                       1/1     Running   0          13m
kube-system          coredns-589f44dc88-95jq9                             1/1     Running   0          15m
kube-system          coredns-589f44dc88-lz7x4                             1/1     Running   0          15m
kube-system          etcd-eda-demo-control-plane                          1/1     Running   0          15m
kube-system          kindnet-25vls                                        1/1     Running   0          15m
kube-system          kube-apiserver-eda-demo-control-plane                1/1     Running   0          15m
kube-system          kube-controller-manager-eda-demo-control-plane       1/1     Running   0          15m
kube-system          kube-proxy-2jt7x                                     1/1     Running   0          15m
kube-system          kube-scheduler-eda-demo-control-plane                1/1     Running   0          15m
local-path-storage   local-path-provisioner-855c7b7774-qz6pm              1/1     Running   0          15m
metallb-system       controller-658745d67-ds9jg                           1/1     Running   0          14m
metallb-system       speaker-sh8n4                                        1/1     Running   0          14m
```

</details>

## Add EDA License

Put the EDA license in the `/opt/srexperts` folder. The license file must follow this template:

```yaml
apiVersion: core.eda.nokia.com/v1
kind: License
metadata:
  name: eda-license
  namespace: eda-system
spec:
  enabled: true
  data: "<Insert ONLY the license HASH string here>"
```

> [!WARNING]
> Remove any other prefix, suffix or blank spaces within the license data.

Apply the license after EDA is deployed:

```shell
kubectl apply -f /opt/srexperts/eda-license.yaml
```

Check that the license is valid and not expired with:

```shell
kubectl get license eda-license -n eda-system
```

## Accessing EDA UI

EDA UI is automatically exposed when `make try-eda` finishes. No additional steps required to access the UI. It is exposed over HTTPS, port 9443 by default.

To log into EDA UI, use the URL indicated in the latest installation steps (`https://<IP/FQDN>:9443`):

```shell
    service/try-eda created
--> The UI can be accessed using https://<FQDN>:9443
--> HOST: [  OK  ] Found host tools /usr/sbin/ip
--> INFO: The UI can be reached using:
<URL list>
--> INFO: EDA is launched
```

## Store EDA last transaction hash

To enable users to revert to an initial state when EDA was deployed, we need to store the last transaction and its hash after we deployed EDA.

Under `~/DCFPartnerHackathon/` folder, execute the following command:

```shell
bash ./eda/record-init-tx.sh
```

The script that will store the `TX_ID TX_HASH` pair in the `/opt/srexperts/eda-init-tx` file. This file then can be used to revert EDA to this transaction.

> [!Note]
> **This script is not part of EDA's installation.**
> 
> It is provided in the Hackathon repo under `eda` folder. You may execute the following command to view the file content after generating it with the previous command:
> 
> ```shell
> cat /opt/srexperts/eda-init-tx
> ```

## Deploy Containerlab topology

Follow these [steps](../clab/README.md) to deploy the Containerlab topology.

> [!NOTE]
> Currently, the client nodes require the bonding kernel to be loaded to support the bond interfaces:
>
> ```shell
> sudo modprobe bonding mmiimon=100 mode=802.3ad lacp_rate=fast
> ```

## Onboard SRX Topology

As the DC nodes run in Containerlab next to the EDA deployment, we need to onboard them into the EDA cluster.
We've prepared a topology onboard file available at `~/DCFPartnerHackathon/eda/topo-onboard/clab/containerlab-integration-crs.yml`.

Start with substituting `env` vars in the the topo onboard files and run:

```shell
cd ~/DCFPartnerHackathon/ && \
docker run --rm -e \
INSTANCE_ID=$(echo -n $INSTANCE_ID) -e EVENT_PASSWORD="$(echo -n $EVENT_PASSWORD)" -e SSH_PUBLIC_KEY="$(echo -n $SSH_PUBLIC_KEY)" \
-u $(id -u):$(id -g) \
-v $(pwd)/eda/topo-onboard/clab:/work \
ghcr.io/hellt/envsubst:0.2.0
```

Then apply the templated onboarding resources:

```shell
kubectl apply -f $(pwd)/eda/topo-onboard/clab
```

Check how the transactions are being executed and ensure all of them become `published` and the status result is `OK` with the following command:

```shell
edactl transaction
```

If something fails, you may inspect the transaction logs with the following command and follow the recovering procedures in the collapsed notes bellow:

```shell
edactl transaction <ID>
```

<details>
<summary>Onboard rollback</summary>

> ⚠️ **Warning**
> 
> If something goes wrong with the transaction, then you should rollback the topo-onboard with:
>
> ```shell
> kubectl delete -f $(pwd)/eda/topo-onboard/clab
> ```
> 
> Wait for all transactions to be completed by checking their status and re-start the topology onboard again with:
>  
> ```shell
> kubectl apply -f $(pwd)/eda/topo-onboard/clab
> ```

</details>

<details>
<summary>Manually recover the topology</summary>

> ⚠️ **Warning**
> 
> In case something goes wrong and you end up in an inconsitent CLAB topology state, you may mannually remove the container and networks with the commands bellow:
> 
> ```shell
> ## Remove the containers
> docker ps -a --filter "name=clab-srexperts"
> docker rm -f $(docker ps -aq --filter "name=clab-srexperts")
> docker ps -a --filter "name=clab-srexperts"
> 
> ## Remove the docker network
> docker network ls | grep srexperts
> docker network rm srexperts
> docker network ls | grep srexperts
> ```
> 
> You may then deploy the CLAB topology again and start over the EDA onboard process.
 
</details>

You can also monitor the onboarding process by executing the following command, waiting until all nodes appear as `Onboarded` and `Synced`:

```shell
kubectl get toponodes -n eda -w
```

<details>
<summary>Output</summary>

```shell
$ kubectl get toponodes -n eda -w
NAME          PLATFORM       VERSION   OS    ONBOARDED   MODE     NPP         NODE     AGE
g21-leaf11    7220 IXR-D3L   26.7.2    srl   true        normal   Connected   Synced   38m
g21-leaf12    7220 IXR-D3L   26.7.2    srl   true        normal   Connected   Synced   38m
g21-leaf13    7220 IXR-D3L   26.7.2    srl   true        normal   Connected   Synced   38m
g21-pe2       7250 IXR-X1B   26.7.2    srl   true        normal   Connected   Synced   38m
g21-spine11   7220 IXR-D5    26.7.2    srl   true        normal   Connected   Synced   38m
g21-spine12   7220 IXR-D5    26.7.2    srl   true        normal   Connected   Synced   38m
```

</details>

## Deploy Fabric

Before we deploy the fabric, we need to remove some default allocation pools to keep the UI clean and create pools as needed. Execute the following command for that purpose:

```shell
cd ~/DCFPartnerHackathon/ && \
bash ./eda/cleanup-pools.sh
```

Then we need to apply the fabric resources so that the fabric is provisioned on the SRL nodes. When EDA onboards the nodes, it takes control over the config and pushes the config as it is provided in the CRs.

Make sure to export your `LLM_API_KEY` if you want to use `NQL` or `AskEDA` features by running the following command:

```bash
export LLM_API_KEY='<your_value>' 
```

Again, run the substitute `env` vars script over the fabric resources located under `~/DCFPartnerHackathon/eda/fabric`:

```shell
cd ~/DCFPartnerHackathon/ && \
docker run --rm -e INSTANCE_ID=$(echo -n $INSTANCE_ID) -e EVENT_PASSWORD="$(echo -n $EVENT_PASSWORD)" -e LLM_API_KEY="$(echo -n $LLM_API_KEY)" \
-u $(id -u):$(id -g) \
-v $(pwd)/eda/fabric:/work \
ghcr.io/hellt/envsubst:0.2.0
```

and apply them:

```shell
kubectl apply -f $(pwd)/eda/fabric
```

## Restore script

When users need to restore EDA to a well known state, they should use the script called `restore-eda.sh`.

> [!CAUTION]
> **Do not run it now, only when you need to restore EDA!**
>
> The way to restore EDA is by executing the following command:
> 
> ```shell
> bash ./eda/restore-eda.sh
> ```

This script restores the transaction recorded in `/opt/srexperts/eda-init-tx` by the lab provisioning script. The transaction stored in this file is the last transaction of the deployment/onboarding and represents the starting state of the platform.

## Copy files

To copy the files from this repo to a remote system, from `~/DCFPartnerHackathon` execute the following commands (replace the required parameters: `User`, `Destination` and `Remote folder`):

```shell
# RS_DEST=nokia@1.edadev.srexperts.net
# RS_REMOTE_DEST=/home/nokia/eda
RS_DEST=demo1.ohn81
RS_REMOTE_DEST=/root/eda
rsync -avz --delete eda/fabric ${RS_DEST}:${RS_REMOTE_DEST}
```

```shell
# RS_DEST=nokia@1.edadev.srexperts.net
# RS_REMOTE_DEST=/home/nokia/eda
RS_DEST=demo1.ohn81
RS_REMOTE_DEST=/root/eda
rsync -avz --delete eda/topo-onboard ${RS_DEST}:${RS_REMOTE_DEST}
```

This will move the `fabric` and `topo-onboard` dirs to `/root/eda` on the remote system.

## EDA and Ansible

To automate some provisioning tasks we use Ansible collections for EDA.

Install the collections to a local collections tree, executing the following command from `~/DCFPartnerHackathon`:

```shell
uv --directory eda run ansible-galaxy collection install -p ./.ansible/collections -r galaxy-requirements.yml
```

With the collections installed, you can now use `ansible-playbook` to run plays against the EDA cluster using the `inventory.yml` file that defines the connection parameters of the EDA cluster.

> [!Note]
> Edit the file `eda/inventory.yml` and update the `eda_api_url` and other variables as needed.

```shell
uv --directory eda run ansible-playbook -i inventory.yml ./playbooks/users.yaml
```

This will create 2 users (`admin2` and `admin3`) by default.

To create a different number of users you can use the following command:

```shell
uv --directory eda run ansible-playbook -i inventory.yml ./playbooks/users.yaml -e eda_extra_admin_user_count=20
```

## CX on EDA

To support activities around Digital Twin/CX on EDA we spin a single VM that is shared by all attendees. It is configured with many users based on the max number of instances.

This system spins up EDA with `SIMULATE=true` flag and uses the containerized SRL image to create the CX topology.
