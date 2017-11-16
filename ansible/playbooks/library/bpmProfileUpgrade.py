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
            state   = dict(default='dmgr', choices=['dmgr', 'node']),
            wasdir  = dict(required=True),
            profilename    = dict(required=True),
            username = dict(required=False),
            password = dict(required=False),
            targetcluster = dict(required=False)
        )
    )

    state = module.params['state']
    wasdir = module.params['wasdir']
    profilename = module.params['profilename']
    username = module.params['username']
    password = module.params['password']
    targetcluster=module.params['targetcluster']

    # Check if paths are valid
    #if not os.path.exists(wasdir):
    #    module.fail_json(msg=wasdir+" does not exist")
    if not os.path.exists(wasdir + "profiles/" + profilename + "/"):
        module.fail_json(msg=wasdir+ "profiles/" + profilename+ "/" + " path does no exist")
    
    
    if state == 'dmgr':
       x= wasdir + "bin/ws_ant.sh -f " + wasdir + "util/BPMProfileUpgrade.ant -profileName " + profilename + " -Dupgrade=true" 
       child = subprocess.Popen([x],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
       #child = subprocess.Popen([wasdir+"bin/ws_ant.sh -f " + wasdir + "util/BPMProfileUpgrade.ant -profilename " + profilename + " -Dupgrade=true -Dcluster=" + targetcluster],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
       stdout_value, stderr_value = child.communicate()
        #if child.returncode != 0:
       if not stdout_value.find("Profile upgrade was completed successfully") < 0:
         time.sleep(120)

       if child.returncode != 0:
           module.fail_json(msg="Unable to run profile upgrade successfully: ", stdout=stdout_value, stderr=stderr_value)
       else:
           module.exit_json(changed=True, msg=" ran profile upgrade successfully ", stdout=stdout_value)  



    if state == 'node':
       x= wasdir + "bin/ws_ant.sh -f " + wasdir + "util/BPMProfileUpgrade.ant -profileName " + profilename + " -Dupgrade=true -Dcluster=" + targetcluster 
       child = subprocess.Popen([x],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
       #child = subprocess.Popen([wasdir+"bin/ws_ant.sh -f " + wasdir + "util/BPMProfileUpgrade.ant -profilename " + profilename + " -Dupgrade=true -Dcluster=" + targetcluster],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
       stdout_value, stderr_value = child.communicate()
        #if child.returncode != 0:
       if not stdout_value.find("Profile upgrade was completed successfully") < 0:
         time.sleep(120)

       if child.returncode != 0:
           module.fail_json(msg="Unable to run profile upgrade successfully: ", stdout=stdout_value, stderr=stderr_value)
       else:
           module.exit_json(changed=True, msg=" ran profile upgrade successfully ", stdout=stdout_value)  


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
