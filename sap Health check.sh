#!/bin/bash
# SAP System Health Check Script
# Author: SK & Meg 😉

if [ -z "$1" ]; then
  echo "❌ Usage: $0 <HOSTNAME>"
  exit 1
fi

HOSTNAME=$1
DATE=$(date)

echo "============================================="
echo " SAP System Health Check - $HOSTNAME"
echo " Date: $DATE"
echo "============================================="

echo -e "\n--------------Checking SAP Processes--------------"
ssh $HOSTNAME "ps -ef | grep -E 'disp|msg|enserver|icm' | grep -v grep"
if [ $? -eq 0 ]; then
  echo "✅ SAP processes are running on $HOSTNAME."
else
  echo "❌ SAP processes NOT running on $HOSTNAME!"
fi

echo -e "\n--------------Checking SAP Instance via sapcontrol--------------"
ssh $HOSTNAME "/usr/sap/hostctrl/exe/sapcontrol -nr 00 -function GetProcessList"

echo -e "\n--------------CPU Usage--------------"
ssh $HOSTNAME "mpstat | awk '/Average/ {print \"CPU Idle: \"\$12\"% | CPU Usage: \"100-\$12\"%\"}'"

echo -e "\n--------------Memory Usage--------------"
ssh $HOSTNAME "free -h"

echo -e "\n--------------Swap Usage--------------"
ssh $HOSTNAME "free -m | awk '/Swap/ {print \"Swap Total: \"\$2\"MB | Used: \"\$3\"MB | Free: \"\$4\"MB\"}'"

echo -e "\n--------------File System Usage--------------"
ssh $HOSTNAME "df -hT | grep -E 'ext|xfs'"

echo -e "\n--------------Checking Network Connectivity--------------"
ping -c2 $HOSTNAME > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✅ $HOSTNAME is reachable"
else
  echo "❌ $HOSTNAME is not reachable"
fi

echo -e "\n============================================="
echo "✅ System Health Check Completed for $HOSTNAME!"
echo "============================================="
