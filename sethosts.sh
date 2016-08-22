# Script to setup network and hostname

# Defines
myHostName=$(hostname)
#myHostName="mrf1-mrb-01"
myDomainName="tss.dialogic.com"
#myDomainName=".ims.eng.rr.com"

# Update the Hostname and /etc/hosts
# Replacing whole hosts file here, maybe appending is better, but easier to just set it to known entity to avoid any issues
# however, based on the finial sed there may be some
cat << __EOF > /etc/hosts
127.0.0.1   ${myHostName} localhost
::1	    ${myHostName} localhost
__EOF

#updating the hostname to BASE adress

echo "${myHostName}" > /etc/hostname

echo "/etc/hostname set to ${myHostname}"
echo "/etc/hosts:"
cat /etc/hosts
