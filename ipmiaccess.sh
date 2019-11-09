#!/bin/bash

# Command line:
# ipmiaccess.sh <ipmi_ip> <ipmi_admin_pass> <ipmi_user_login> <time_h {optional}>

# iptables -t nat -A PREROUTING -d extIP -j DNAT --to-destination local.ip
# iptables -t nat -A POSTROUTING -o extIF -j SNAT --to-source ext.ip

# Colorize
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 191)
BLUE=$(tput setaf 4)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)

cd "$(dirname "$0")"
# Gathering info about available and used IP's
ip a | grep -E 'ens192+:+[[:alnum:]]' | awk '{print substr($2,1,15)}' > /tmp/ippool.tmp
IPINUSE=$(iptables -L -t nat | awk -F":" '/SNAT/ {print $NF}')

# Remove used IP from list of available IP's
for i in $IPINUSE
 	do
 	sed -i -e "/${i}/d" /tmp/ippool.tmp
done

IPPOOL="/tmp/ippool.tmp"

if [[ -s $IPPOOL && -n $1 && -n $2 && -n $3  ]];
	then

	if  [[ -n $4 ]];
		then
		 at now +$4 hour <<< "./ipmiremove.sh $1 $2"
		 JOBTIME=$(atq | tail -1 | awk '{print $2,$3,$4,$5}') 
		 printf '%s\n' "" "Acces granted for $4 hours ->" "Remove job scheduled $JOBTIME->"
	fi

        # Add Netmap rules
        EXTIP=$(head -1 $IPPOOL)
        iptables -t nat -A PREROUTING -d $EXTIP -j DNAT --to-destination $1
	echo "Processing forwarding rules ->"
        iptables -t nat -A POSTROUTING -o ens192 -j SNAT --to-source $EXTIP

	# Configuring IPMI access
	IPMIUSERPASS=$(curl -s "https://www.passwordrandom.com/query?command=password&format=plain&scheme=RRnnRRnnRRnR")
	ipmitool -I lanplus -U ADMIN -P $2 -H $1 user set name 3 $3
	ipmitool -I lanplus -U ADMIN -P $2 -H $1 user set password 3 $IPMIUSERPASS 1> /dev/null
	ipmitool -I lanplus -U ADMIN -P $2 -H $1 channel setaccess 1 3 link=on ipmi=on callin=on privilege=3 1> /dev/null
	ipmitool -I lanplus -U ADMIN -P $2 -H $1 user enable 3
	echo "Added IPMI user access ->"

	# Result output
	printf '%s\n' "[$(date --rfc-3339=seconds)]: $EXTIP mapped to $1 for user $3 with userpass $IPMIUSERPASS" >> /var/log/ipmiaccess.log
	printf '%s\n' "" "${YELLOW}= = = = = = = = = = = = = = = = = = = = =${NORMAL}" ""
	printf '%s\n' "${BRIGHT}$EXTIP${NORMAL} mapped to ${BRIGHT}$1${NORMAL}" "User login:    ${BRIGHT}$3${NORMAL}" "User password: ${BRIGHT}$IPMIUSERPASS${NORMAL}" ""

	else
	printf '%s\n' "Check arguments quality or IP pool is empty" "See current mappings:"
	iptables -L -t nat --line-numbers | awk '/DNAT/ {print $1" - "$6 " mapped " $NF}'
fi

