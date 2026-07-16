#!/bin/sh

macaddr=$(ip a | grep -A1 eth0 | grep ether | awk '{print $2}' | sed 's/://g')
EUI=$(echo "${macaddr:0:6}fffe${macaddr: -6}" | tr '[:lower:]' '[:upper:]')

echo "TPE UUID: 0016C0-$EUI"
echo "Type this in the CloudGW"
echo export EUI=\"$EUI\"

