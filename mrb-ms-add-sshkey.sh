#!/bin/bash
. /etc/init.d/functions

#time to wait between upates

LOOPDELAY="6"
USER="root"
MRBCFGFILE="/opt/mrb/nst-mrb-config.xml"

STARTTIME=`date +"%y-%m-%d_%H-%M-%S"` 
#chenge the below if you want to have a log output
LOG="/dev/null"
echo '--------------------------------------------------------------------------------------' >> $LOG
echo "Starttime = $STARTTIME" >> $LOG
echo "MRBCFGFILE = $MRBCFGFILE" >> $LOG
echo "USER = $USER" >> $LOG
echo '--------------------------------------------------------------------------------------' >> $LOG
# Use step(), try(), and next() to perform a series of commands and print
# [  OK  ] or [FAILED] at the end. The step as a whole fails if any individual
# command fails.
#
step() {
    echo -n -e "$@"
    echo -e "\n\nSTEP -  $@">> $LOG
    STEP_OK=0
}

try() {
    # Check for `-b' argument to run command in the background.
    echo -e "$@"  >> $LOG
    #uncomment this line if you want to see the output on scree
    "$@" | tee -a $LOG
    #uncomment this line if you don't and just want to see log file
    #"$@" >> $LOG
    # Check if command failed and update $STEP_OK if so.
    local EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
        STEP_OK=$EXIT_CODE
        echo "$FILE: line $LINE: Command \'$*\' failed with exit code $EXIT_CODE." >> "$LOG"
    fi
    return $EXIT_CODE
}

next() {
    [[ $STEP_OK -eq 0 ]]  && echo_success || echo_failure
    echo
    return $STEP_OK
}

setpass() {
    echo -n "$@"
    STEP_OK=0
}
setfail() {
    echo -n "$@"
    STEP_OK=1
}

if [[ -f mrb-ms-key.pub ]]; 
then
step "Ssh key found, using existing key"
setpass
next
else
step "Generating the ssh key"
try ssh-keygen -t rsa -b 2048 -f mrb-ms-key -N ''
next
fi
echo -e "\n\n" 
for MSIP in $(grep -P -A8 "<media-server id=\".*?\">" $MRBCFGFILE | grep -Po '(?<=<hostname>).*(?=</hostname>)')
do
step "Copying key to $MSIP"
echo -e "\n" 
try ssh-copy-id -i mrb-ms-key $USER@$MSIP 2> /dev/null
echo -n -e "\n$MSIP key update"
next
done

echo -e "\n\nComplete!\n\n"
