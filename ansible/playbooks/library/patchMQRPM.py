#!/usr/bin/python

#
# Author: Rohit Gabriel <rohit.gabriel@gmail.com>
#
# This is an Ansible module. Stops all the running WebSphere JVM's on a target server
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
            mqmdir  = dict(required=True),
            installedrpmfile= dict(required=True),
            installscript= dict(required=True)
        )
    )

    state = module.params['state']
    mqmdir = module.params['mqmdir']
    installedrpmfile = module.params['installedrpmfile']
    installscript = module.params['installscript']

    # Check if paths are valid
    #if not os.path.exists(wasdir):
    #    module.fail_json(msg=wasdir+" does not exist")
    if not os.path.exists(mqmdir):
        module.fail_json(msg=mqmdir + "path does no exist")
    if not os.path.exists(installedrpmfile):
        module.fail_json(msg=installedrpmfile + "path does no exist")
    if not os.path.exists(installscript):
        module.fail_json(msg=installscript + "path does no exist")

    # Run stopServer.sh on all the JVM's that are started


    if state == 'present':
        child = subprocess.Popen([installscript],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()

        if child.returncode != 0:
            module.fail_json(msg="Unable to install successfully", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg="Installed successfully", stdout=stdout_value)


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
