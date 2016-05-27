#!/bin/sh
WM=ratpoison
pgrep kodi | xargs kill -SIGSTOP
sleep 0.2 
${WM} &
if [ -n "$3" ]; then
  /usr/bin/retroarch $1 $2 "$3" ;
else
  /usr/bin/retroarch ;
fi
while [ $(pidof retroarch) ];do
sleep 1
done;
killall -9 retroarch
killall -9 ${WM}
pgrep kodi | xargs kill -SIGCONT
