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

    # Run stopServer.sh on all the JVM's that are started
    if state == 'present':
      f = open("/tmp/dmgrlist.log")
      #with open('/tmp/list.log') as f:
      for line in f:
        word="ADMU0508I"
        stop="ADMU0509I"
        if stop in line:
          stopidx=line.split()
          if stopidx[-1].replace('.', '') == "stopped":
            child = subprocess.Popen(["echo JVM-already-stopped"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdout_value, stderr_value = child.communicate()
        if word in line:
          idx=line.split()
          if idx[-1] == "STARTED":
              child = subprocess.Popen([wasdir+"profiles/" + profilename + "/bin/stopServer.sh " + idx[-3].replace('\"', '') + " > /tmp/stop.log"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
              stdout_value, stderr_value = child.communicate()
              if child.returncode != 0:
                 module.fail_json(msg="Unable to run stopServer.sh successfully: " + idx[-3].replace('\"', ''), stdout=stdout_value, stderr=stderr_value)
              else:
                module.exit_json(changed=True, msg=" ran stopServer.sh successfully ", stdout=stdout_value)
      module.exit_json(changed=True, msg="Already stopped nothing to do ")


# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
