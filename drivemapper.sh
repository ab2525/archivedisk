#!/bin/bash


if [[ `id -u` -ne 0 ]]; then echo "This script must be run as root. Try 'sudo ./drivemapper.sh'";exit 1;fi
echo "We are now going to generate a symlink drive mapping for your system."
echo "I will open trays, and then I need you to tell me what number they are."
echo ""
echo "Thanks!"

echo "If you are using any of the drives, press control-c now! Otherwise, press enter"
read

for i in /dev/sr*;do if [ -f /d$i ]; then echo "Symlink exists for /d$i"; else eject $i;echo "What drive number is this?";read num;ln -s $i /d$num;eject -t $i;echo "Next!";fi;done
