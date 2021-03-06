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
            password = dict(required=False)
        )
    )

    state = module.params['state']
    wasdir = module.params['wasdir']
    profilename = module.params['profilename']
    username = module.params['username']
    password = module.params['password']

    # Check if paths are valid
    #if not os.path.exists(wasdir):
    #    module.fail_json(msg=wasdir+" does not exist")
    if not os.path.exists(wasdir + "profiles/" + profilename + "/"):
        module.fail_json(msg=wasdir+ "profiles/" + profilename+ "/" + " path does no exist")
    
    # Start the nodeagent first
#    if state == 'present':
    child = subprocess.Popen([wasdir+"profiles/" + profilename + "/bin/startServer.sh nodeagent" + " > /tmp/start.log"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout_value, stderr_value = child.communicate()
        #if child.returncode != 0:
    if not stdout_value.find("e-business") < 0:
      time.sleep(120)

#     if child.returncode != 0:
#           module.fail_json(msg="Unable to run start nodeagent successfully: ", stdout=stdout_value, stderr=stderr_value)
#       else:
#           module.exit_json(changed=True, msg=" ran startServer.sh nodeagent successfully ", stdout=stdout_value)  

    # Run startServer.sh on all the JVM's that are previously started
    if state == 'present':
      f = open("/tmp/list.log")
      #with open('/tmp/list.log') as f:
    for line in f:
      word="ADMU0508I"
      if word in line:
        idx=line.split()
        if idx[-1] == "STARTED":
          if idx[-3].replace('\"', '') != "nodeagent":
            if idx[-3].find("Mess") == 1:
              x=wasdir+"profiles/" + profilename + "/bin/startServer.sh " + idx[-3].replace('\"', '')
              child = subprocess.Popen([x + " > /tmp/start.log"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
              stdout_value, stderr_value = child.communicate()
              if not stdout_value.find("e-business") < 0:
                time.sleep(120)
            elif idx[-3].find("Supp") == 1:
              x=wasdir+"profiles/" + profilename + "/bin/startServer.sh " + idx[-3].replace('\"', '')
              child = subprocess.Popen([x + " > /tmp/start.log"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
              stdout_value, stderr_value = child.communicate()
              if not stdout_value.find("e-business") < 0:
                time.sleep(120)
            elif idx[-3].find("App") == 1:
              x=wasdir+"profiles/" + profilename + "/bin/startServer.sh " + idx[-3].replace('\"', '')
              child = subprocess.Popen([x + " > /tmp/start.log"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
              stdout_value, stderr_value = child.communicate()
              if child.returncode != 0:
                 module.fail_json(msg="Unable to run startServer.sh successfully: " + idx[-3].replace('\"', ''), stdout=stdout_value, stderr=stderr_value)

    module.exit_json(changed=True, msg=" ran startServer.sh successfully ", stdout=stdout_value)


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
