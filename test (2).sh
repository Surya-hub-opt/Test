#!/bin/bash
trap "exit 1" TERM
export TOP_PID=$$
# Input validation

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <sap_sid> <sap_sid2> <sap_sid3>"
    exit 1
fi

SID=$(echo "${1}" | tr -d '[:lower:]')
test_mul=$(echo "${2}")
SID2=$(echo "${3}" | tr -d '[:lower:]')
SID3=$(echo "${4}" | tr -d '[:lower:]')
SID4=$(echo "${5}" | tr -d '[:lower:]')

echo "$SID"
if [ "$test_mul" == "yes" ]; then
    echo "$SID2"
    echo "$SID3"
else
    echo "$SID4"
fi
echo "very fast"
echo "script changes"
echo "Completed"
