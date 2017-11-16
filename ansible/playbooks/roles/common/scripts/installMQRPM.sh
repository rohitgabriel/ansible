#!/bin/bash
filename=/var/tmp/installed-mqrpm.txt
liner=`cat $filename | awk -F '-' '{print $1}' | grep Runtime | sort -u`
lines=`cat $filename | awk -F '-' '{print $1}' | grep -v Runtime | sort -u`
for line in $liner
do
   	rpm -ivh `find /tmp/mqpatch/ -type f ! -name *.spec | grep $line`
done
for line in $lines
do
   	rpm -ivh `find /tmp/mqpatch/ -type f ! -name *.spec | grep $line`
done
