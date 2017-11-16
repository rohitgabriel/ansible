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
        argument_spec = dict(
            state   = dict(default='present', choices=['present', 'abcent']),
            wasdir  = dict(required=True),
            profilename    = dict(required=True),
            username = dict(required=False),
            password = dict(required=False)
        )
    )

    state = module.params['state']
    wasdir = module.params['wasdir']
    profilename = module.params['profilename']
    username = module.params['username']
    password = module.params['password']

    # Check if paths are valid
    if not os.path.exists(wasdir):
        module.fail_json(msg=wasdir+" does not exist")

    # Run serverStatus.sh
    if state == 'present':
        child = subprocess.Popen([wasdir+"profiles/" + profilename + "/bin/serverStatus.sh -all > /tmp/list.log"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()

        if child.returncode != 0:
            module.fail_json(msg="Unable to run serverStatus.sh successfully", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg=profilename + " ran serverStatus.sh successfully", stdout=stdout_value)


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
