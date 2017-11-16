#!/usr/bin/python

#
# Author: Rohit Gabriel <rohit.gabriel@gmail.com>
#
# This is an Ansible module. Starts all the previously running WebSphere JVM's on a target server for a particular profile
#


import os
import subprocess
import platform
import datetime
import time

def main():

    # Read arguments
    module = AnsibleModule(
        argument_spec = dict(
            state   = dict(default='present', choices=['present', 'abcent']),
            wasdir  = dict(required=True),
            profilename    = dict(required=True),
            username = dict(required=False),
            password = dict(required=False),
            backupdir = dict(required=True)
        )
    )

    state = module.params['state']
    wasdir = module.params['wasdir']
    profilename = module.params['profilename']
    username = module.params['username']
    password = module.params['password']
    backupdir = module.params['backupdir']

    # Check if paths are valid
    #if not os.path.exists(wasdir):
    #    module.fail_json(msg=wasdir+" does not exist")
    if not os.path.exists(wasdir + "profiles/" + profilename + "/"):
        module.fail_json(msg=wasdir+ "profiles/" + profilename+ "/" + " path does no exist")

    # Run backupConfig.sh with nostop
    if state == 'present':
      child = subprocess.Popen([wasdir+"profiles/" + profilename + "/bin/backupConfig.sh " + "-profileName " + profilename + " " + backupdir+"/"+profilename+time.strftime("%d-%m-%Y")+".zip" + " -nostop"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
      stdout_value, stderr_value = child.communicate()
      if child.returncode != 0:
        module.fail_json(msg="Unable to perform profile backup successfully ", stdout=stdout_value, stderr=stderr_value)
      else:
        module.exit_json(changed=True, msg="Profile backed up successfully ", stdout=stdout_value)


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
