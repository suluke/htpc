#!/bin/sh
WM=ratpoison
pgrep kodi | xargs kill -SIGSTOP
sleep 0.2 
${WM} &
/usr/bin/steam -bigpicture ;
while [ $(pidof steam) ]; do
  sleep 1
done;
killall -9 steam
killall -9 ${WM}
pgrep kodi | xargs kill -SIGCONT
