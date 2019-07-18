while true ;
do echo "------------------------------";
MRBPS=$(ps aux | grep mrb.jar | grep -v /bin/bash | grep -v grep  | xargs echo | cut -d' ' -f 2)
date ;
echo "MRB PID=$MRBPS"
for PORT in 8181 5060
do
  echo "AS->MRB (${PORT}):"
  ASLIST=$(ss -np | grep $PORT | cut -c67-90 | cut -f 1 -d':' | sort -u)
  for AS in $ASLIST
  do
    echo "  $AS->MRB: $(ss -np | grep ${MRBPS} | grep ":${PORT} " | grep "${AS}" | wc -l)"
  done
done
echo

MSLIST=$(grep media-server-config -A 9 /opt/mrb/config/nst-mrb-config.json | grep hostname | cut -f4 -d"\"" | xargs echo)
for PORT in 81 5060 5070
do
  echo "MRB->MS (${PORT}):"
  for MS in $MSLIST
  do
    echo "  MRB->$MS: $(ss -np | grep ${MRBPS} |  grep "${MS}:${PORT} "  | wc -l)"
  done
done
echo "------------------------------"
sleep 30
done
