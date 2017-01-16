# Script to setup network and hostname

# Defines
myHostName="MRB1-DMW"
#myHostName="mrf1-mrb-01"
myDomainName="tss.dialogic.com"
#myDomainName=".ims.eng.rr.com"

#This is the defice that is used for the OAM Connect
OAMDEV="enp0s10"
#OAMDEV="eth0"
OAMIP="10.20.123.2"

#This is the Interface used to communciate between the MRB
SIGINTDEV="enp0s8"
#SIGINTDEV="eth1"
SIGINTIP="10.20.123.151"

# This is the Interface used to communciate back to the cluster (ie talking
# to XMS so should be used for MetaCtrl and SIP with XMS
CLUSTERDEV="enp0s9"
#CLUSTERDEV="eth2"
CLUSTERIP="10.20.123.152"

#this will ee
VIPDEV="enp0s3"
#CLUSTERDEV="eth2"
VIPIP="10.20.123.150"

GatewayIP="10.20.123.250"
DNS1="10.20.106.1"
DNS2="10.20.106.2"

# mrb-01
cd /etc/sysconfig/network-scripts

# eth0/ens32 - OAM - Configured for
# doing nothing, this should be configured at OS install

# eth1 - SIGINT
cat <<__EOF > ifcfg-${SIGINTDEV}
# Interface SIGINT
NAME=${SIGINTDEV}
DEVICE=${SIGINTDEV}
BOOTPROTO=none
ONBOOT=yes
PREFIX=25
IPADDR=${SIGINTIP}
GATEWAY=${GatewayIP}
USERCTL=no
__EOF

# eth2 - CLUSTER
sed -e 's/# Interface.*/# Interface CLUSTER/g' -e "s/${SIGINTDEV}/${CLUSTERDEV}/g" -e "/IPADDR=/s/=.*/=${CLUSTERIP}/" ifcfg-${SIGINTDEV} > ifcfg-${CLUSTERDEV}

# Update the Hostname and /etc/hosts
# Replacing whole hosts file here, maybe appending is better, but easier to just set it to known entity to avoid any issues
# however, based on the finial sed there may be some
cat << __EOF > /etc/hosts
127.0.0.1   ${myHostName} localhost
::1         ${myHostName} localhost
${OAMIP}    ${myHostName}-oam.${myDomainName} ${myHostName}-oam
${SIGINTIP}    ${myHostName}-sigint.${myDomainName}    ${myHostName}-sigint
${CLUSTERIP}   ${myHostName}-cluster.${myDomainName}   ${myHostName}-cluster
${VIPIP}   ${myHostName}-vip.${myDomainName}   ${myHostName}-vip
__EOF

#updating the hostname to BASE adress
echo "${myHostName}" > /etc/hostname

#update the DNS
sed -e "/^DNS1=/s/=.*/=${DNS1}/" -e "/^DNS2=/s/=.*/=${DNS2}/" -i /etc/sysconfig/network-scripts/ifcfg-e*


#setup the rp_filter on the interfaces
cat <<__EOF > /etc/sysctl.conf
# Setting up the rp_filter for the interfaces
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.${OAMDEV}.rp_filter = 0
net.ipv4.conf.${SIGINTDEV}.rp_filter = 0
net.ipv4.conf.${CLUSTERDEV}.rp_filter = 0
net.ipv4.conf.${VIPDEV}.rp_filter = 0
__EOF

sysctl -f /etc/sysctl.conf &> /dev/null
#restarteing both here to cover bases depending what version is installed
systemctl restart network
service network restart

#performing ip a so that we can configure
ip a
sysctl -a | grep .rp_filter
# Not sure if this substituion is needed.  In my case you can set the correct domain in the above var, recomment though if needed
#sed -i 's/voip-eng/ims.eng/g' /etc/hosts
