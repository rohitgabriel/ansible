#!/bin/bash

ME=`whoami`

IPCS_S=`ipcs -s | egrep "0x[0-9a-f]+ [0-9]+" | grep mqm | awk '{print $2}'`
IPCS_M=`ipcs -m | egrep "0x[0-9a-f]+ [0-9]+" | grep mqm | awk '{print $2}'`

for id in $IPCS_M; do
  ipcrm -m $id;
  #echo "This is shared MEM process : $id"
done

for id in $IPCS_S; do
   ipcrm -s $id;
  #echo "This is shared SEG process : $id"
done
