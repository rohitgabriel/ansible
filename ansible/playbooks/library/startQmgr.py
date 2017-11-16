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
            qmgrname = dict(required=False),
            mqmfiledir= dict(required=True)
        )
    )

    state = module.params['state']
    qmgrname = module.params['qmgrname']
    mqmfiledir = module.params['mqmfiledir']


    # Check if paths are valid
    #if not os.path.exists(wasdir):
    #    module.fail_json(msg=wasdir+" does not exist")
    if not os.path.exists(mqmfiledir):
        module.fail_json(msg=mqmfiledir + " path does no exist")

    # Run stopServer.sh on all the JVM's that are started
    if state == 'present':
      f = open(mqmfiledir)
      #with open('/tmp/list.log') as f:
      for line in f:
        child = subprocess.Popen(["strmqm " + line], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()
        if child.returncode != 0:
            module.fail_json(msg="Unable to start QMGR successfully: " + line, stdout=stdout_value, stderr=stderr_value)
        #else:
    module.exit_json(changed=True, msg=" ran strmqm successfully ", stdout=stdout_value)
    #module.exit_json(changed=True, msg="Already stopped nothing to do ")


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
