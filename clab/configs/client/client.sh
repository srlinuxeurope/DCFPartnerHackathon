#!/bin/bash
# Copyright 2024 Nokia
# Licensed under the BSD 3-Clause License.
# SPDX-License-Identifier: BSD-3-Clause

ifup -a

adduser --disabled-password -s /bin/bash nokia
cp /home/admin/.bash* /home/nokia
mkdir -p /home/nokia/.ssh
touch /home/nokia/.ssh/authorized_keys
chmod 600 /home/nokia/.ssh/authorized_keys
cat /tmp/authorized_keys > /home/nokia/.ssh/authorized_keys
chown -R nokia:nokia /home/nokia/.ssh

echo "nokia ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "nokia:$USER_PASSWORD" | sudo chpasswd

# Start iperf3 server
iperf3 -s -p 5201 -D 
