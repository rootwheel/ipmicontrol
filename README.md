# IPMI Access Helper
Forwarding of IP address from non-routable network to routable IP address. Adding user credentials to Supermicro IPMI BMC

## Using
```ipmiaccess.sh <ipmi_ip> <ipmi_admin_pass> <ipmi_user_login> <time_h {optional}>```

```ipmiremove.sh <ipmi_ip> <ipmi_admin_pass>```

```<time_h>``` - parameter to disable IPMI acount and remove forwarding rules in given time (hours). This can be optional and calls ipmiremove.sh from main script after a given time

Note: This script used and tested under Debian 10, and includes name of the network interface (ens192), in case of various interface this part needs to be edited

### Prerequisites
* Enable ipv4 forwarding in /etc/sysctl.conf by adding net.ipv4.ip_forward = 1
* Add enough of routable addresses to the server interface
* Install ipmitool, curl
* For color compatibility add ```export TERM=xterm-256color``` to .bashrc
