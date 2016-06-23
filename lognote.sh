#!/bin/bash

TIMESTAMP=`date +"%Y-%m-%d %H:%M:%S,%3N"`
for f in /opt/mrb/nst-mrb.log /opt/mrb/notes.log /opt/mrb/nst-vip-manager.log /opt/mrb/SIP.log /var/log/messages
do
        echo $TIMESTAMP LOGNOTE - $@ >> $f
done
