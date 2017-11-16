#!/usr/bin/python

#
# Author: Rohit Gabriel <rohit.gabriel@gmail.com>
#
# This is an Ansible module. Lists all the WebSphere JVM's on a target server
#


import os
import subprocess
import platform
import datetime

def main():


    # Read arguments
    module = AnsibleModule(
        argument_spec=dict(
            state=dict(default='present', choices=['present', 'abcent']),
            mqmdir=dict(required=True),
            listqmgrfile=dict(required=True)
        )
    )

    state = module.params['state']
    mqmdir = module.params['mqmdir']
    listqmgrfile = module.params['listqmgrfile']
    # Check if paths are valid
    if not os.path.exists(mqmdir):
        module.fail_json(msg=mqmdir+" does not exist")

    # Run serverStatus.sh
    if state == 'present':
        RunningQmgr = "dspmq | grep Running | awk -F ' ' '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'"
        child = subprocess.Popen([RunningQmgr + " > " + listqmgrfile],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()

        if child.returncode != 0:
            module.fail_json(msg="Unable to run dspmq successfully", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg="dspmq ran successfully", stdout=stdout_value)


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
