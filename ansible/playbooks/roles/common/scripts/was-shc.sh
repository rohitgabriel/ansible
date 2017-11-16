#!/bin/bash

NODE=`uname -n`
#DATE=`date +%d-%m-20%y+%s`
DATE=`date -u`
echo "
<html>
<body>
<pre>
*******************************************************
* performing health check of Websphere on $NODE
* Run on $DATE
* ISEC appendix AS WebSphere Application Servers
*****************************************************
"

#Input the users as variables
wasuser=wasuser
wasgrp=wasgrp
root=root
rootgrp=root

#For the servers that don't have batch user, please enter root user and group
batchuser=root
batchgrp=root

for dir in /opt/IBM/WebSphere/AppServer /usr/WebSphere /opt/IBM/WebSphere/BPM/v8.0 /opt/IBM/WebSphere85/AppServer /opt/IBM/WebSphere/BPM/v8.5
do
    if [[ -d $dir ]]; then
        #Following Variables are required
InstallRoot=$dir
DmgrName=`ls $InstallRoot/profiles/ | grep D`
ProfileName=`ls $InstallRoot/profiles/ | grep M`

#Following are derived values -- DO NOT CHANGE
ProfilePATH=$InstallRoot/profiles
PropertiesDmgr=$ProfilePATH/$DmgrName/properties
PropertiesNode=$ProfilePATH/$ProfileName/properties
PropertiesBase=$InstallRoot/properties
BINDIRS=$InstallRoot/bin
PROFILEBINDIRS=$ProfilePATH/$ProfileName/bin
DMGRBINDIRS=$ProfilePATH/$DmgrName/bin
CellName=`ls $ProfilePATH/$DmgrName/config/cells/ | grep Cell`
SecurityDmgrPATH=$ProfilePATH/$DmgrName/config/cells/$CellName
SecurityPATH=$ProfilePATH/$ProfileName/config/cells/$CellName
InstalledAPPS=$ProfilePATH/$ProfileName/installedApps/$CellName

echo "Any files listed below are non-compliant"
echo "Checking for non-compliant files under Install Root: $InstallRoot"
echo ""

echo "<font color=red>"

find $InstallRoot -type f \( \( ! -user $wasuser -a ! -user $root -a ! -user $batchuser \) -o \( ! -group $wasgrp -a ! -group $rootgrp  -a ! -group $batchgrp \)  -o \( -perm -2 \) \) -exec ls -l {} \;
echo "</font>"

#if [[ -n $(find $InstallRoot -type f \( \( ! -user $wasuser -a ! -user $root -a ! -user $batchuser \) -o \( ! -group $wasgrp -a ! -group $rootgrp  -a ! -group $batchgrp \)  -o \( -perm -2 \) ! -path "$PropertiesBase/*" ! -path "$PropertiesDmgr/*" ! -path "$PropertiesNode/*" \) ) ]]


#Protecting specific files

echo ""
echo "Checking for non-compliant property files under Install Root: $InstallRoot"
echo ""
echo "<font color=red>"
find $PropertiesBase/ -type f \( -name TraceSettings.properties -o -name client.policy -o -name client_types.xml -o -name  implfactory.properties -o -name sas.client.props -o -name sas.stdclient.properties -o -name sas.tools.properties -o -name soap.client.props -o -name wsadmin.properties -o -name wsjaas_client.conf -o -name ipc.client.props \) \( \( -perm -1 \) -o \( -perm -2 \) -o \( -perm -4 \) \)  -exec ls -l {} \;

echo "</font>"
echo ""
echo "Checking for non-compliant property files under Dmgr profile: $PropertiesDmgr"
echo ""
echo "<font color=red>"
find $PropertiesDmgr/ -type f \( -name TraceSettings.properties -o -name client.policy -o -name client_types.xml -o -name  implfactory.properties -o -name sas.client.props -o -name sas.stdclient.properties -o -name sas.tools.properties -o -name soap.client.props -o -name wsadmin.properties -o -name wsjaas_client.conf -o -name ipc.client.props \) \( \( -perm -1 \) -o \( -perm -2 \) -o \( -perm -4 \) \)  -exec ls -l {} \;
echo "</font>"

echo ""
echo "Checking for non-compliant property files under App Server profile: $PropertiesNode"
echo ""
echo "<font color=red>"
find $PropertiesNode/ -type f \( -name TraceSettings.properties -o -name client.policy -o -name client_types.xml -o -name  implfactory.properties -o -name sas.client.props -o -name sas.stdclient.properties -o -name sas.tools.properties -o -name soap.client.props -o -name wsadmin.properties -o -name wsjaas_client.conf -o -name ipc.client.props \) \( \( -perm -1 \) -o \( -perm -2 \) -o \( -perm -4 \) \)  -exec ls -l {} \;
echo "</font>"

echo ""
echo "Checking for non-compliant security.xml file under Dmgr: $SecurityDmgrPATH"
echo ""
echo "<font color=red>"
find $SecurityDmgrPATH/ -type f \( -name security.xml \) \( \( -perm -1 \) -o \( -perm -2 \) -o \( -perm -4 \) \)  -exec ls -l {} \;
echo "</font>"

echo ""
echo "Checking for non-compliant security.xml file under App Server profile: $SecurityPATH"
echo ""
echo "<font color=red>"
find $SecurityPATH/ -type f \( -name security.xml \) \( \( -perm -1 \) -o \( -perm -2 \) -o \( -perm -4 \) \)  -exec ls -l {} \;
echo "</font>"


#No LOG CHECK - CUSTOMER has SAP Exemption

#Global Security enabled check
GSStatus=`grep "\<security" "$SecurityDmgrPATH"/security.xml | awk -F "enabled=" '{print $2}' | awk -F '\" ' '{print $1}' | awk -F '\"' '{print $2}'`
if [ $GSStatus == "false" ]
  then
echo "<font color=red>"
  echo "Global Security Check failed"i
echo "</font>"
  else
        echo "Global Security check passed"

fi


echo ""
echo "Checking for any sample applications installed: $InstalledAPPS"
echo ""
#Sample Apps check
echo "<font color=red>"
find $InstalledAPPS/  \( -name DefaultApplication.ear -o -name ivtApp.ear -o -name PerfServletApp.ear -o -name  query.ear -o -name uddi.ear \)
echo "</font>"


echo ""

pcount=`grep loginPassword={xor} $PropertiesDmgr/soap.client.props $PropertiesNode/soap.client.props|wc -l`
if [ $pcount -lt 2 ]
  then
echo "<font color=red>"
  echo "Password not encrypted"
echo "</font>"
  else
        echo "Password check passed"
fi

    else
        echo "------"
    fi
done
echo "
</pre>
</body>
</html>"

