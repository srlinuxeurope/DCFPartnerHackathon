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
#            value 'srlinux@10.128.1.1:/home/srlinux/backups/'
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
                    "cmdline": f"sudo ip netns exec srbase-mgmt /usr/bin/scp -i ~/id_rsa -o StrictHostKeyChecking=no /etc/opt/srlinux/config.json {target}config-{timestamp}.json"
                }
            }
        ]
    }

    return json.dumps(response)
