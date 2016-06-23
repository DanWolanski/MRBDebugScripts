#!/bin/bash

$@ | tee outtmp
TIMESTAMP=`date +"%Y-%m-%d %H:%M:%S,%3N"`
for f in /opt/mrb/nst-mrb.log /opt/mrb/notes.log /opt/mrb/nst-vip-manager.log /opt/mrb/SIP.log /var/log/messages
do
        echo $TIMESTAMP LOGCOMMAND - >> $f
        cat outtmp  >> $f
done

rm -f outtmp
