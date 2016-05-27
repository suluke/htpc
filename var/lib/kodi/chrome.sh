#!/bin/bash
WM=redpoison
${WM} &
/usr/bin/google-chrome-stable $@
killall -9 ${WM}
