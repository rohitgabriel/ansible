#!/bin/sh
#
# Objective ==========
#       Run security health check on this server to verify if the server is compliant
#-------------------------------------------------------------------------------------
####################################### History ######################################
# 2016-01-21	V1.0	Altaf	Script creation
# 2017-10-01    V2.0    Altaf	New Tech Spec to include MQ8

MQ_VERSION=`dspmqver | grep -i version | sed 's/Version://' | tr -d '[:blank:]'`
SERVER_NAME=`hostname`
RUN_DATE=`echo $(date +%Y%m%d%H%M%S)`
RUNNING_QMGRS=`dspmq | grep 'STATUS(Running)' | sed 's/QMNAME(\(.*\)) *STATUS.*/\1/'`

for qMgr in $RUNNING_QMGRS
do
	file=/tmp/${HOSTNAME%}-$qMgr.ans-mqhealthcheck.txt
        echo "MQ VERSION: $MQ_VERSION      Server: $SERVER_NAME                 Run date: $RUN_DATE" > $file
        echo "SHC for QM: $qMgr" >> $file
	echo "***************************************************************************************************************" >> $file

	CHECK1814=`/opt/mqm/bin/amqoamd -s -m $qMgr | grep SYSTEM.ADMIN.COMMAND.QUEUE | grep +put | grep -v mqm | grep -v mqbrkrs | grep -v rtnlgrp`
	if [[ "$CHECK1814" == "" ]]
	then
	        COMPLIANCE1='Y'
	else
	        COMPLIANCE1='N'
	fi
        echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
        echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.1.4   |Protecting Resources|Restrict the ability to put messages on   |$COMPLIANCE1" >> $file
	echo "             |(OSRs)              |SYSTEM.ADMIN.COMMAND.QUEUE and any of its |" >> $file
	echo "             |                    |aliases to users with a valid business    |" >> $file
	echo "             |                    |need. This also applies to default prim-  |" >> $file
	echo "             |                    |ary groups (such as nobody, staff or users|" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |HC: put on  SYSTEM.ADMIN.COMMAND.QUEUE    |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command used: /opt/mqm/bin/amqoamd -s -m $qMgr | grep SYSTEM.ADMIN.COMMAND.QUEUE | grep +put | grep -v mqm | grep -v mqbrkrs | grep -v rtnlgrp" >> $file
	echo "--Start of output--" >> $file
	echo "$CHECK1814" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	CHECK18511=`echo "dis chl(SYSTEM.DEF.REQUESTER) MCAUSER" | runmqsc $qMgr | grep -i *noaccess`
	CHECK18512=`echo "dis chl(SYSTEM.DEF.RECEIVER) MCAUSER" | runmqsc $qMgr | grep -i *noaccess`
	CHECK18513=`echo "dis chl(SYSTEM.DEF.SVRCONN) MCAUSER" | runmqsc $qMgr | grep -i *noaccess`
	T1=`echo "dis chl(SYSTEM.DEF.REQUESTER) MCAUSER" | runmqsc $qMgr | grep -E "CHANNEL|MCAUSER"`
	T2=`echo "dis chl(SYSTEM.DEF.RECEIVER) MCAUSER" | runmqsc $qMgr | grep -E "CHANNEL|MCAUSER"`
	T3=`echo "dis chl(SYSTEM.DEF.SVRCONN) MCAUSER" | runmqsc $qMgr | grep -E "CHANNEL|MCAUSER"`

	if [ `echo $CHECK18511 | grep -ic "*noaccess"` -gt 0 ] && [ `echo $CHECK18512 | grep -ic "*noaccess"` -gt 0 ] && [ `echo $CHECK18513 | grep -ic "*noaccess"` -gt 0 ]
	then
	        COMPLIANCE2='Y'
	else
	        COMPLIANCE2='N'
	fi
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
        echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.5.1   |Protecting Resources|SYSTEM.DEF.SVRCONN                        |$COMPLIANCE2" >> $file
	echo "             |(OSRs)              |SYSTEM.DEF.RECEIVER                       |" >> $file
	echo "             |                    |SYSTEM.DEF.REQUESTER                      |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |MCAUSER must be set to \*noaccess         |" >> $file
	echo "             |                    |for these channels.                       |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: dis chl(SYSTEM.DEF.REQUESTER), dis chl(SYSTEM.DEF.RECEIVER), dis chl(SYSTEM.DEF.SVRCONN)" >> $file
	echo "--Start of output--" >> $file
	echo "$T1" >> $file
	echo "$T2" >> $file
	echo "$T3" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	CHECK18521=`echo "dis chl(SYSTEM.AUTO.RECEIVER) MCAUSER" | runmqsc $qMgr | grep -i *noaccess`
	CHECK18522=`echo "dis chl(SYSTEM.AUTO.SVRCONN) MCAUSER" | runmqsc $qMgr | grep -i *noaccess`
	T4=`echo "dis chl(SYSTEM.AUTO.RECEIVER) MCAUSER" | runmqsc $qMgr | grep -E "CHANNEL|MCAUSER"`
	T5=`echo "dis chl(SYSTEM.AUTO.SVRCONN) MCAUSER" | runmqsc $qMgr | grep -E "CHANNEL|MCAUSER"`

	if [ `echo $CHECK18521 | grep -ic "*noaccess"` -gt 0 ] && [ `echo $CHECK18522 | grep -ic "*noaccess"` -gt 0 ]
	then
	        COMPLIANCE3='Y'
	else
	        COMPLIANCE3='N'
	fi
	 COMPLIANCE3='Y'
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
        echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.5.2   |Protecting Resources|SYSTEM.AUTO.RECEIVER                      |$COMPLIANCE3" >> $file
	echo "             |(OSRs)              |SYSTEM.AUTO.SVRCONN                       |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Unless the channel auto-definition is     |" >> $file
	echo "             |                    |secured by a channel auto-definition      |" >> $file
	echo "             |                    |exit, using the CHADEXIT() keyword on the |" >> $file
	echo "             |                    |ALTER QMGR command, set MCAUSER to an     |" >> $file
	echo "             |                    |invalid userid or one that has no         |" >> $file
	echo "             |                    |authority. On UNIX, set MCAUSER to        |" >> $file
	echo "             |                    |nobody. Note that without a CHADEXIT or   |" >> $file
	echo "             |                    |MCAUSER to control access to these        |" >> $file
	echo "             |                    |channels, they can be used even if        |" >> $file
	echo "             |                    |auto-definition of channels is disabled.  |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |These channels are not defined on z/OS    |" >> $file
	echo "             |                    |queue managers when the queue manager is  |" >> $file
	echo "             |                    |created. The compliant setting for z/OS   |" >> $file
	echo "             |                    |is to keep these channels undefined.      |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |MCAUSER may not be blank unless SSL,      |" >> $file
	echo "             |                    |CHLAUTH or a Security Exit is controlling |" >> $file
	echo "             |                    |channel access.                           |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: dis chl(SYSTEM.AUTO.RECEIVER) MCAUSER, dis chl(SYSTEM.AUTO.SVRCONN) MCAUSER" >> $file
	echo "--Start of output--" >> $file
	echo "$T4" >> $file
	echo "$T5" >> $file
	echo "Tracked under NCI 101673197" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	CHECK1853=`echo "dis chl(SYSTEM.ADMIN.SVRCONN) MCAUSER" | runmqsc $qMgr | grep -i *noaccess`
	T6=`echo "dis chl(SYSTEM.ADMIN.SVRCONN) MCAUSER" | runmqsc $qMgr | grep -Ei "CHANNEL|*noaccess"`

	if [[ "$T6" == "" ]]
	then
	        COMPLIANCE4='Y'
	elif [ `echo $CHECK1853 | grep -ic "*noaccess"` -gt 0 ]
	then
	        COMPLIANCE4='Y'
	else
	        COMPLIANCE4='N'
	fi
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.5.3   |Protecting Resources|Unless access to this channel will be     |$COMPLIANCE4" >> $file
	echo "             |(OSRs)              |controlled by a security exit, CHLAUTH or |" >> $file
	echo "             |                    |SSL, or unless MCAUSER is set to a userid |" >> $file
	echo "             |                    |with ""display only"" access, set MCAUSER |" >> $file
	echo "             |                    |to an invalid userid, or one that has no  |" >> $file
	echo "             |                    |authority;                                |" >> $file
	echo "             |                    |on UNIX set MCAUSER to *noaccess.         |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: dis chl(SYSTEM.ADMIN.SVRCONN)" >> $file
	echo "--Start of output--" >> $file
	echo "$T6" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file


	MQ_VER=`echo $MQ_VERSION | sed 's/\.//g'`

	CHECK18541=`echo "dis chl(*) where(chltype eq svrconn) MCAUSER" | runmqsc $qMgr | grep -F 'MCAUSER(' |sed 's/.*\(MCAUSER\)/\1/' | sed 's/MCAUSER(//' | sed 's/).*//' | grep -iv *NOACCESS | sort -u | sed '/^\s*$/d'`

    	for mId in $CHECK18541
        do
  	 CHECK185411=`cat /etc/passwd | grep -i $mId`
            if [[ "$CHECK185411" == "" ]]
                then
                    echo "$mId is not present on target server" >> tmpCHECK185411.txt
            else
                mGroup=`cat /etc/group | grep $mId | cut -d: -f-1`
                for mGrp in $mGroup
                    do
                    	CHECK185412=`/opt/mqm/bin/amqoamd -s -m $qMgr | grep -E "chg|crt|dlt" | grep queue | grep -i $mGrp | grep -Ev "mqbrkrs|mqm"`
                        echo "$CHECK185412" >> tmpCHECK185412.txt
                    done
            fi
        done

        T185411=`cat tmpCHECK185411.txt`
        T185412=`cat tmpCHECK185412.txt`

        if [[ "$MQ_VER" -lt 7099 ]]
            then
                COMPLIANCE5='Y'
        elif [[ "$T185411" == "" ]] && [[ "$T185412" == "" ]]
            then
           	    COMPLIANCE5='Y'
        else
                COMPLIANCE5='N'
        fi

	COMPLIANCE5='N'

    	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
    	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.5.4   |Protecting Resources|Recommendation is to use CHLAUTH to block |$COMPLIANCE5" >> $file
	echo "             |(OSRs)              |unauthorized administrative access to the |" >> $file
	echo "             |                    |qmgr for releases of MQ v7.1 and higher.  |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |The MCAUSER value on the SVRCONN channel  |" >> $file
	echo "             |                    |should be set to a user ID which exists on|" >> $file
	echo "             |                    |the target system and which has OAM       |" >> $file
	echo "             |                    |privileges granted as per the section     |" >> $file
	echo "             |                    |regarding restriction of Administration   |" >> $file
	echo "             |                    |Authorizations of chg, clr, crt, dlt, ctrl|" >> $file
	echo "             |                    |or ctrlx on OAM profiles created via      |" >> $file
	echo "             |                    |SETMQAUT                                  |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command used: echo dis chl(*) where(chltype eq svrconn MCAUSER) | runmqsc $qMgr" >> $file
	echo "Artefact: Command used: cat /etc/passwd | grep -i ID" >> $file
	echo "Artefact: Command used: /opt/mqm/bin/amqoamd -s -m $qMgr | grep -E chg|crt|dlt | grep queue | grep -i group" >> $file
	echo "--Start of output--" >> $file
 	echo "Tracked under NCI 101673197" >> $file
	echo "MQ version is $MQ_VER" >> $file
	cat tmpCHECK185411.txt >> $file
	cat tmpCHECK185412.txt >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	COMPLIANCE6='N'
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
    	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.5.5   |Protecting Resources|CHLAUTH should be used to block           |$COMPLIANCE6" >> $file
	echo "             |(OSRs)              |unauthorized administrative access to the |" >> $file
	echo "             |                    |qmgr for releases of MQ v7.1 and higher.  |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |At this time, CONNAUTH should be disabled |" >> $file
	echo "             |                    |by leaving the CONNAUTH parameter set to  |" >> $file
	echo "             |                    |blank on the queue manager.               |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command used"  >> $file
	echo "--Start of output--" >> $file
	echo "Tracked under NCI 101673197" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	echo "display service (*) ALL" | runmqsc $qMgr | grep -E "SERVICE|STARTCMD|STOPCMD" > tmp2.txt
	CHECK1881=`cat tmp2.txt`
	if [[ "$CHECK1881" == "" ]]
	then
	        COMPLIANCE7'Y'
	elif [ `echo $CHECK1881 | grep -c "STARTCMD(./"` -gt 0 ]
	then
	        COMPLIANCE7='N'
	elif [ `echo $CHECK1881 | grep -c "STOPCMD(./"` -gt 0 ]
	then
		COMPLIANCE7='N'
	else
		COMPLIANCE7='Y'
	fi
        echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
        echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.8.1   |Protecting Resources|The STARTCMD() and/or STOPCMD()           |$COMPLIANCE7" >> $file
	echo "             |(OSRs)              |parameters of a MQSC SERVICE definition   |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Each active entry must specify the full   |" >> $file
	echo "             |                    |path of the file/command/script to be     |" >> $file
	echo "             |                    |executed.                                 |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: display service (*) ALL | runmqsc $qMgr | grep -E SERVICE|STARTCMD|STOPCMD" >> $file
	echo "--Start of output--" >> $file
	echo "$CHECK1881" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	T1=`echo "display service (*) ALL" | runmqsc $qMgr | grep -F 'STARTCMD(/' | sed 's/.*\(STARTCMD\)/\1/' | sed 's/STARTCMD(//' | sed 's/).*//'`
	T2=`echo "display service (*) ALL" | runmqsc $qMgr | grep -F 'STOPCMD(/' | sed 's/.*\(STOPCMD\)/\1/' | sed 's/STOPCMD(//' | sed 's/).*//'`
	CHECK18821=`find $T1 -perm -o=w`
	CHECK18822=`find $T2 -perm -o=w`

	if [[ "$CHECK18821" == "" ]] && [[ "$CHECK18822" == "" ]]
	then
	        COMPLIANCE8='Y'
	else
	        COMPLIANCE8='N'
	fi

	if [[ "$T1" == "" ]] && [[ "$T2" == "" ]]
	then
		COMPLIANCE8='Y'
		CHECK18821=""
		CHECK18822=""
	fi
        echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.8.2   |Protecting Resources|The STARTCMD() and/or STOPCMD()           |$COMPLIANCE8" >> $file
	echo "             |(OSRs)              |parameters of a MQSC SERVICE definition   |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Each active entry must specify the        |" >> $file
	echo "             |                    |following: The settings for other must be |" >> $file
	echo "             |                    |R-X or more stringent for the command/    |" >> $file
	echo "             |                    |script to be executed as well as all      |" >> $file
	echo "             |                    |exixting directories in its path          |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: find $T1 -perm -o=w, find $T2 -perm -o=w" >> $file
	echo "--Start of output--" >> $file
	echo "STARTCMD: $CHECK18821" >> $file
	echo "STOPCMD : $CHECK18822" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	U1=`echo "display service (*) ALL" | runmqsc $qMgr | grep -F 'STARTCMD(/' | sed 's/STARTCMD(//' | sed 's/).*//' | sed 's/.[^/]*$//'`
	U2=`echo "display service (*) ALL" | runmqsc $qMgr | grep -F 'STOPCMD(/' | sed 's/STOPCMD(//' | sed 's/).*//' | sed 's/.[^/]*$//'`
	CHECK18831=`find $U1 -type d -perm -o=w`
	CHECK18832=`find $U2 -type d -perm -o=w`

	if [[ "$CHECK18831" == "" ]] && [[ "$CHECK18832" == "" ]]
	then
	        COMPLIANCE9='Y'
	else
	        COMPLIANCE9='N'
	fi

	if [[ "$U1" == "" ]] && [[ "$U2" == "" ]]
        then
                COMPLIANCE9='Y'
                CHECK18831=""
                CHECK18832=""
        fi

	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.8.3   |Protecting Resources|The STARTCMD() and/or STOPCMD()           |$COMPLIANCE9" >> $file
	echo "             |(OSRs)              |parameters of a MQSC SERVICE definition   |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Each active entry must specify the        |" >> $file
	echo "             |                    |following: The settings for all existing  |" >> $file
	echo "             |                    |directories in its path for group must be |" >> $file
	echo "             |                    |R-X or more stringent if owned by any     |" >> $file
	echo "             |                    |group considered to be a default group for|" >> $file
	echo "             |                    |general users e.g. staff or users         |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: find $U1 -type d -perm -o=w, find $U2 -type d -perm -o=w" >> $file
	echo "--Start of output--" >> $file
	echo "STARTCMD: $CHECK18831" >> $file
	echo "STOPCMD : $CHECK18832" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	echo "display process (*) ALL" | runmqsc $qMgr | grep -E "PROCESS|APPLICID" > tmp3.txt
	CHECK1891=`cat tmp3.txt`
	if [[ "$CHECK1891" == "" ]]
	then
	        COMPLIANCE10='Y'
	elif [ `echo $CHECK1891 | grep -c "APPLICID(./"` -gt 0 ]
	then
	        COMPLIANCE10='N'
	else
	        COMPLIANCE10='Y'
	fi
        echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.9.1   |Protecting Resources|The APPLICID() parameter of a MQSC        |$COMPLIANCE10" >> $file
	echo "             |(OSRs)              |PROCESS definition                        |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Each active entry must specify the full   |" >> $file
	echo "             |                    |path of the file/command/script to be     |" >> $file
	echo "             |                    |executed.                                 |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: display process (*) ALL | runmqsc $qMgr | grep -E PROCESS|APPLICID" >> $file
	echo "--Start of output--" >> $file
	echo "$CHECK1891" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	V1=`echo "DISPLAY PROCESS (*) ALL" | runmqsc $qMgr | grep -F 'APPLICID(/' | sed 's/APPLICID(//' | sed 's/).*//'`
	CHECK1892=`find $V1 -perm -o=w`
	if [[ "$CHECK1892" == "" ]]
	then
	        COMPLIANCE11='Y'
	elif [[ "$V1" == "" ]]
	then
	        COMPLIANCE11='Y'
		CHECK1892=""
	else
	        COMPLIANCE11='N'
	fi
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.9.2   |Protecting Resources|The APPLICID() parameter of a MQSC        |$COMPLIANCE11" >> $file
	echo "             |(OSRs)              |PROCESS definition                        |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Each active entry must specify the        |" >> $file
	echo "             |                    |following: The settings for other must be |" >> $file
	echo "             |                    |R-X or more stringent for the command/    |" >> $file
	echo "             |                    |script to be executed as well as all      |" >> $file
	echo "             |                    |exixting directories in its path          |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: find $V1 -perm -o=w" >> $file
	echo "--Start of output--" >> $file
	echo "$CHECK1892" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	W1=`echo "DISPLAY PROCESS (*) ALL" | runmqsc $qMgr | grep -F 'APPLICID(/' | sed 's/APPLICID(//' | sed 's/).*//' | sed 's/.[^/]*$//'`
	CHECK1893=`find $W1 -type d -perm -o=w`
	if [[ "$CHECK1893" == "" ]]
	then
	        COMPLIANCE12='Y'
	elif [[ "$W1" == "" ]]
	then
	        COMPLIANCE12='Y'
		CHECK1893=""
	else
	        COMPLIANCE12='N'
	fi
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.1.8.9.3   |Protecting Resources|The APPLICID() parameter of a MQSC        |$COMPLIANCE12" >> $file
	echo "             |(OSRs)              |PROCESS definition                        |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |Each active entry must specify the        |" >> $file
	echo "             |                    |following: The settings for all existing  |" >> $file
	echo "             |                    |directories in its path for group must be |" >> $file
	echo "             |                    |R-X or more stringent if owned by any     |" >> $file
	echo "             |                    |group considered to be a default group for|" >> $file
	echo "             |                    |general users e.g. staff or users         |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: find $W1 -type d -perm -o=w" >> $file
	echo "--Start of output--" >> $file
	echo "$CHECK1893" >> $file
	echo "-- End of output --" >> $file
	echo "***************************************************************************************************************" >> $file

	echo "dis chl(*) SSLCIPH WHERE(SSLCIPH NE '')" | runmqsc $qMgr | grep -E "CHANNEL|SSLCIPH" > tmp4.txt 2>&1
	CHECK211=`cat tmp4.txt`
	X=`echo "dis chl(*) SSLCIPH" | runmqsc $qMgr | grep SSLCIPH | sed 's/SSLCIPH(//' | sed 's/).*//' | sed '1d'`
	X1=`echo $X | grep -v "RC4_SHA_US | TRIPLE_DES_SHA_US | TLS_RSA_WITH_AES_256_CBC_SHA  | TLS_RSA_WITH_AES_256_CBC_SHA | TLS_RSA_WITH_AES_256_CBC_SHA256"`
	if [[ "$X1" == "" ]]
	then
	        COMPLIANCE13='Y'
	else
	        COMPLIANCE13='N'
	fi
	echo "Section      |System Value/Parm   |Agreed to Value                           |Compliant Y/N or N/A?" >> $file
	echo "-------------|--------------------|------------------------------------------|---------------------------------" >> $file
	echo "AN.2.1.1     |Encryption          |SSLV3 should br disabled Cipherspecs      |$COMPLIANCE13" >> $file
	echo "             |                    |associated with SSLv3 protocol must no    |" >> $file
	echo "             |                    |longer be used. For all encrypted communi-|" >> $file
	echo "             |                    |cations TLS must be used.                 |" >> $file
	echo "             |                    |                                          |" >> $file
	echo "             |                    |For all versions of IBM WebSphere MQ  on  |" >> $file
	echo "             |                    |AIX, HP-UX, Linux, Solaris and Windows    |" >> $file
	echo "             |                    |platforms if you are using TLS ciphers    |" >> $file
	echo "             |                    |with CBC (Cipher-Block Chaining) enabled  |" >> $file
	echo "             |                    |i.e., TLS_RSA_WITH_AES_256_CBC_SHA,       |" >> $file
	echo "             |                    |the environment variable                  |" >> $file
	echo "             |                    |GSK_STRICTCHECK_CBCPADBYTES equal to      |" >> $file
	echo "             |                    |GSK_TRUE must be set within the           |" >> $file
	echo "             |                    |mqm profile to ensure that channels using |" >> $file
	echo "             |                    |the TLS protocol adhere to strict         |" >> $file
	echo "             |                    |compliance of the TLS RFC. Note that IBM  |" >> $file
	echo "             |                    |WebSphere MQ for IBM i is not affected    |" >> $file
	echo "             |                    |by this vulnerability.                    |" >> $file
	echo "---------------------------------------------------------------------------------------------------------------" >> $file
	echo "Artefact: Command Used: dis chl(*) SSLCIPH WHERE(SSLCIPH NE '')" | runmqsc $qMgr | grep -E "CHANNEL|SSLCIPH" >> $file
	echo "--Start of output--" >> $file
	echo "$CHECK211" >> $file
	echo "-- End of output --" >> $file

	if [[ $COMPLIANCE1 == 'Y' && $COMPLIANCE2 == 'Y' && $COMPLIANCE3 == 'Y' && $COMPLIANCE4 == 'Y' && $COMPLIANCE5 == 'Y' && $COMPLIANCE6 == 'Y' && $COMPLIANCE7 == 'Y' && $COMPLIANCE8 == 'Y' && $COMPLIANCE9 == 'Y' && $COMPLIANCE10 == 'Y' && $COMPLIANCE11 == 'Y' && $COMPLIANCE12 == 'Y' && $COMPLIANCE13 == 'Y' ]]
	then
		SERVER_COMPLIANCE='COMPLIANT'
	else
		SERVER_COMPLIANCE='NOT COMPLIANT'
	fi
	echo "***************************************************************************************************************" >> $file
	echo "END OF SECURITY HEALTH CHECK OUTPUT - SERVER IS : $SERVER_COMPLIANCE" >> $file
	echo "***************************************************************************************************************" >> $file

	rm tmp*.txt

done


	if [[ $RUNNING_QMGRS == "" ]]
        then
            file=/tmp/$(date +%Y-%b).${HOSTNAME%}.mqhealthcheck.txt
            echo "MQ VERSION: $MQ_VERSION      Server: $SERVER_NAME                 Run date: $RUN_DATE" > $file
            echo "***************************************************************************************************************" >> $file
            echo "END OF SECURITY HEALTH CHECK OUTPUT - SERVER IS : COMPLIANT ( NO QMGR CONFIGURED )" >> $file
            echo "***************************************************************************************************************" >> $file
    	fi
