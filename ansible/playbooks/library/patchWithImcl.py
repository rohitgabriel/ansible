#!/usr/bin/python

#
# Author: Amir Mofasser <amir.mofasser@gmail.com>
#
# This is an Ansible module. Installs/Uninstall IBM WebSphere Application Server Binaries
#
# $IM_INSTALL_DIR/eclipse/tools/imcl install com.ibm.websphere.ND.v85
# -repositories $ND_REPO_DIR
# -installationDirectory $ND_INSTALL_DIR
# -sharedResourcesDirectory $IM_SHARED_INSTALL_DIR
# -acceptLicense -showProgress

import os
import subprocess
import platform
import datetime
import shutil

def main():


    # Read arguments
    module = AnsibleModule(
        argument_spec = dict(
            state     = dict(default='present', choices=['present', 'rollback']),
            ibmim     = dict(required=True),
            dest      = dict(required=True),
            im_shared = dict(required=False),
            repo      = dict(required=True),
            offering  = dict(required=True),
            logdir    = dict(required=False)
        )
    )

    state = module.params['state']
    ibmim = module.params['ibmim']
    dest = module.params['dest']
    im_shared = module.params['im_shared']
    repo = module.params['repo']
    offering = module.params['offering']
    logdir = module.params['logdir']

    # Check if paths are valid
    if not os.path.exists(ibmim+"/eclipse"):
        module.fail_json(msg=ibmim+"/eclipse not found")

    # Installation
    if state == 'present':
        child = subprocess.Popen([ibmim+"/eclipse/tools/imcl install " + offering + " -repositories " + repo + " -installationDirectory " + dest + " -acceptLicense -showProgress "], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()
        if child.returncode != 0:
            module.fail_json(msg="Ifix/fixpack install failed", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg="Ifix/fixpack installed successfully", stdout=stdout_value)

    # Uninstall
    if state == 'rollback':
        child = subprocess.Popen([ibmim+"/eclipse/tools/imcl rollback " + offering + " -repositories " + repo + " -installationDirectory " + dest + " -acceptLicense -showProgress -log " + logdir], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()
        if child.returncode != 0:
            module.fail_json(msg="Ifix/fixpack uninstall failed", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg=" Ifix/fixpack uninstalled successfully", stdout=stdout_value)

# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
