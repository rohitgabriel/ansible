#!/bin/bash
RUNNING_QMGRS=`dspmq | grep 'STATUS(Running)' | sed 's/QMNAME(\(.*\)) *STATUS.*/\1/'`
d=$(date +%Y-%m-%d)
cd /var/tmp/mqbackup
for qMgr in $RUNNING_QMGRS
do
  ./saveqmgr64.linux --localQMgr $qMgr
  cp SAVEQMGR.MQSC SAVEQMGR.MQSC.$qMgr.$d
  /opt/mqm/bin/amqoamd -s -m $qMgr > $qMgr.mqauth.$d
  echo "DISPLAY QLOCAL(*) WHERE(CURDEPTH GT 0)" | runmqsc $qMgr > $qMgr.QLOCAL.CURDEPTH.BEFORE
  echo "DISPLAY CHS(*) ALL" | runmqsc $qMgr > $qMgr.CHS.BEFORE
  echo "DISPLAY CLUSQMGR(*)" | runmqsc $qMgr > $qMgr.CLUSQMGRS
  echo "DISPLAY QC(*)" | runmqsc $qMgr > $qMgr.CLUSTEREDQS
done

