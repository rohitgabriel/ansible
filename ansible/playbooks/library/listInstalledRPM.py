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
            word1=dict(required=True),
            word2=dict(required=False),
            listrpmfile=dict(required=True)
        )
    )

    state = module.params['state']
    word1 = module.params['word1']
    word2 = module.params['word2']
    listrpmfile = module.params['listrpmfile']

    # Check if paths are valid
#    if not os.path.exists(mqmdir):
#        module.fail_json(msg=mqmdir+" does not exist")

    # Run serverStatus.sh
    if state == 'present':
        child = subprocess.Popen(["rpm -a -q | grep -i -e " + word1 + " -e " + word2 + " > " + listrpmfile],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()

        if child.returncode != 0:
            module.fail_json(msg="Unable to run rpm commands successfully", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg="rpm query completed successfully", stdout=stdout_value)


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
