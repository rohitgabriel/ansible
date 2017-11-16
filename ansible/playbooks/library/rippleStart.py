import  sys
import  java
import  os

##################################
# starting and stopping a Cluster
#################################
def cluster(x,y):

# get the cell name
    cellName = AdminControl.getCell()

# get the cluster id
    cluster = AdminControl.completeObjectName('cell=' + cellName + ',type=Cluster,name=' + y + ',*')

    if x == 'ripplestartCluster':
       print "Ripple Starting the cluster: " + y
       AdminControl.invoke(cluster, 'rippleStart')
       print "Ripple Start of " + y + " complete. "

#    if x == 'startCluster':
#       print "Starting the cluster: "
#       AdminControl.invoke(cluster, 'start')
#    elif x == 'stopCluster':
#       print "Stopping the cluster: "
#       AdminControl.invoke(cluster, 'stop')
    else:
       print "pb wrong command" + x

    print "Wait 20 seconds "
    sleep(20)


#################################
# Main
#################################

command = sys.argv[0]
if command == 'ripplestartCluster':
   clusterName = sys.argv[1]
   print "clusterName: " + clusterName
   print "command: " + command
   cluster(command,clusterName)
else:
   print "wrong command"
#usage: /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f '/home/wasuser/bin/rippleStart.py' ripplestartCluster DecisionCluster
