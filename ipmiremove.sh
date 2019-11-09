#!/bin/bash

# ipmiremove.sh <ipmi_ip> <ipmi_admin_pass>

# Remove ACCESS
if [[ -n $1 && -n $2 ]];
	then
	# Remove relevant rules
	until [[ -z $(iptables -L -t nat --line-numbers | grep $1) ]]
		do
		LINENUM=$(iptables -L -t nat --line-numbers | grep $1| awk '{print $1}' | head -1)
		iptables -t nat -D PREROUTING  $LINENUM
		iptables -t nat -D POSTROUTING $LINENUM
	done

	# Disabling IPMI user
	ipmitool -I lanplus -U ADMIN -P $2 -H $1 user disable 3
	printf '%s\n' "[$(date --rfc-3339=seconds)]: Rules for $1 removed and IPMI user account disabled" >> /var/log/ipmiaccess.log
	else
	printf '%s\n' "Check argument quality"
fi


