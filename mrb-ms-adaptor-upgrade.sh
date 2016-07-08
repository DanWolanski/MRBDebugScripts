#!/bin/bash
. /etc/init.d/functions

MRBCFGFILE="/opt/mrb/nst-mrb-config.xml"
MRBINSTALLER="dialogic-mrb-installer-1.4.26.jar"
#time to wait between upates

LOOPDELAY="6"

STARTTIME=`date +"%y-%m-%d_%H-%M-%S"` 
LOG="mrb-ms-upgrade.log"
echo '--------------------------------------------------------------------------------------' >> $LOG
echo "Starttime = $STARTTIME" >> $LOG
echo "MRBCFGFILE = $MRBCFGFILE" >> $LOG
echo "MRBINSTALLER = $MRBINSTALLER" >> $LOG
echo "LOOPDELAY = $LOOPDELAY" >> $LOG
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
    #echo -e "$@"  >> $LOG
    #uncomment this line if you want to see the output on scree
    "$@" | tee -a $LOG
    #uncomment this line if you don't and just want to see log file
    "$@" >> $LOG
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



for MSIP in $(grep -P -A8 "<media-server id=\".*?\">" $MRBCFGFILE | grep -Po '(?<=<hostname>).*(?=</hostname>)')
do
echo "Upgrading $MSIP"
step "   Copying $MRBINSTALLER" 
#try scp -i mrb-ms-key $MRBINSTALLER root@$MSIP:$MRBINSTALLER
setpass
next
step "   Performing remote upgrade of $MSIP"
try expect -f mrb-adaptor-upgrade.exp $MSIP $MRBINSTALLER 
next
step "   Sleeping for $LOOPDELAY seconds"
try sleep $LOOPDELAY
next
done

echo -e "\n\nUpgrade complete! See $LOG for details!\n"

