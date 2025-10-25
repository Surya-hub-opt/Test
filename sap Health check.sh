#!/bin/bash
# SAP System Health Check Script
# Author: SK & Meg 😉

HOSTNAME=$(hostname)
DATE=$(date)

echo "============================================="
echo " SAP System Health Check - $HOSTNAME"
echo " Date: $DATE"
echo "============================================="

echo -e "\n--------------Checking SAP Processes--------------"
ps -ef | grep -E "disp|msg|enserver|icm" | grep -v grep
if [ $? -eq 0 ]; then
  echo "✅ SAP processes are running."
else
  echo "❌ SAP processes NOT running!"
fi

echo -e "\n--------------Checking SAP Instance via sapcontrol--------------"
/usr/sap/hostctrl/exe/sapcontrol -nr 00 -function GetProcessList

echo -e "\n--------------CPU Usage--------------"
mpstat | awk '/Average/ {print "CPU Idle: "$12"% | CPU Usage: "100-$12"%"}'

echo -e "\n--------------Memory Usage--------------"
free -h

echo -e "\n--------------Swap Usage--------------"
free -m | awk '/Swap/ {print "Swap Total: "$2"MB | Used: "$3"MB | Free: "$4"MB"}'

echo -e "\n--------------File System Usage--------------"
df -hT | grep -E "ext|xfs"

echo -e "\n--------------Checking Database Listener (If Oracle)--------------"
lsnrctl status > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✅ Oracle DB Listener Running"
else
  echo "⚠ Listener not Oracle or not active"
fi

echo -e "\n--------------Checking Network Connectivity--------------"
ping -c2 google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✅ Network is UP"
else
  echo "❌ Network DOWN"
fi

echo -e "\n============================================="
echo "✅ System Health Check Completed!"
echo "============================================="
