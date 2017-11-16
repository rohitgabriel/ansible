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

    responsefiles = [
        'installWAS.txt',
        'installIHS.txt',
        'installPLG.txt',
        'installPLG2.txt',
        'uninstall.txt',
    ]

    # Read arguments
    module = AnsibleModule(
        argument_spec = dict(
            state     = dict(default='present', choices=['present', 'rollback']),
            updi_package_path     = dict(required=True),
            install_dir      = dict(required=True),
            maintenance_dir      = dict(required=True),
            fixpack_name  = dict(required=True),
            responsefiles  = dict(default='installWAS.txt', choices=responsefiles),
        )
    )

    state = module.params['state']
    updi_package_path = module.params['updi_package_path']
    install_dir = module.params['install_dir']
    maintenance_dir = module.params['maintenance_dir']
    fixpack_name = module.params['fixpack_name']
    responsefiles = module.params['responsefiles']

    # Check if paths are valid
    if not os.path.exists(install_dir):
        module.fail_json(msg=install_dir+" not found")

    # Installation
    if state == 'present':
        child = subprocess.Popen([updi_package_path+"/update.sh -options " + updi_package_path + "responsefiles/" + responsefiles + " -silent"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()
        if child.returncode != 0:
            module.fail_json(msg="Ifix/fixpack install failed", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg="Ifix/fixpack installed successfully", stdout=stdout_value)

    # Uninstall
    if state == 'rollback':
        child = subprocess.Popen([updi_package_path+"/update.sh -options " + updi_package_path + "responsefiles/uninstall.txt" + " -silent"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_value, stderr_value = child.communicate()
        if child.returncode != 0:
            module.fail_json(msg="Rollback failed", stdout=stdout_value, stderr=stderr_value)

        module.exit_json(changed=True, msg="Rollback completed successfully", stdout=stdout_value)

# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
