# How to run this CLAB topology on your own environment?

## Environment variables

This is a templated lab and relies on a number of environment variables to be exposed in your shell.

Assuming bash/zsh, export/append these variables to your rc files.

```bash
# any number between 1-99
export INSTANCE_ID=99
export EXT_INSTANCE_ID=$(printf '%04d' ${INSTANCE_ID})
# Password you want to set when accessing the nodes in the topology
export EVENT_PASSWORD=iWantToRunThisLabOnMyOwn

# specifically to run the codeserver image, which is part of the topology
export NOKIA_UID=$(id -u)
export NOKIA_GID=$(getent group docker | cut -d: -f3)

# SSH public key can be set to the available pub key in users home dir for local testing
export SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
```

Once these variables are exposed, one can run this lab by executing:
(assuming this repo has been checked out in $HOME/DCFPartnerHackathon)

``` bash
CLAB_LABDIR_BASE=$HOME sudo -E clab deploy -t $HOME/DCFPartnerHackathon/clab/srx.clab.yml --reconfigure
```

## EDA deployment

This lab topology includes two DCs as illustrated in the picture below, DC2 on the left that is pre-configured and DC1 on the right that is managed by EDA. The EDA Managed DC1, including the PE2 (that is acting as DC-GW), are not pre-configured, and rely on EDA to deploy the configurations. As such, when you deploy the CLAB topology, only the DC2 nodes (including PE4 DC-GW) will load their start-up configs.
To install EDA and onboard DC1 nodes refer to the [EDA Readme](/eda/README.md)


![Topology](/docs/images/srx.clab.png)
