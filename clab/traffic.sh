#!/bin/bash
# Copyright 2020 Nokia
# Licensed under the BSD 3-Clause License.
# SPDX-License-Identifier: BSD-3-Clause


set -e

start() {
    echo "starting traffic on client $1 to $2"
    docker exec clab-dcfpartnerws-$1 bash /traffic.sh -a start -d $2
}

stop() {
    echo "stopping traffic on client $1 to $2"
    docker exec clab-dcfpartnerws-$1 bash /traffic.sh -a stop -d $2
}

usage() {
   echo "syntax: traffic CLIENT <start|stop> DESTINATION[.SUFFIX]"
   echo "where:"
   echo "    CLIENT is one of: [ client01 client02 client11 client12 client13 client21 ]"
   echo "    DESTINATION is one of: [ all client01 client02 client11 client12 client13 client21 ]"
   echo "    SUFFIX is one of: [ .grt .vprn.dci ]   -> if empty .grt will be considered"
}

if [ $# -lt 3 ]; then
   usage

elif [ $2 == "start" ]; then
    start $1 $3

elif [ $2 == "stop" ]; then
    stop $1 $3

else [usage]

fi
