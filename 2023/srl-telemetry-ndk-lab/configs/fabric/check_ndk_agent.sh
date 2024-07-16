#!/bin/bash
while true;
do
if ! [[  $(sr_cli 'info from state / git-client') ]];
then
    sudo pkill ndk-git
    echo "agent restarted"
    sleep 5
fi
sleep 5
done

