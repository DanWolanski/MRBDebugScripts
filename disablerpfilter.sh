# Script to setup network and hostname

#setup the rp_filter on the interfaces
cat <<__EOF >> /etc/sysctl.conf
# Setting up the rp_filter for the interfaces
net.ipv4.conf.all.rp_filter = 0 
net.ipv4.conf.default.rp_filter = 0 
net.ipv4.conf.${OAMDEV}.rp_filter = 0
net.ipv4.conf.${SIGINTDEV}.rp_filter = 0
net.ipv4.conf.${CLUSTERDEV}.rp_filter = 0
__EOF

sysctl -f /etc/sysctl.conf &> /dev/null
#restarteing both here to cover bases depending what version is installed
systemctl restart network
service network restart
#performing ip a so that we can configure
ip a
sysctl -a | grep .rp_filter
