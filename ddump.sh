#!/usr/bin/env bash

echo "Welcome to ddump."

if [ -x $1 ]; then echo "Parameter missing. Run like ./ddump.sh <numberofdisks> <outputdir>";exit 1;fi
if [ -x $2 ]; then echo "Parameter missing or outputdir exists. Run like ./ddump.sh <numberofdisks> <outputdir>";exit 1;fi

disks=$1
output=$2


#how many drives does this system have?
drives=`ls /d?|wc -l`


if [[ $((disks%drives)) -eq 0 ]]; then
	smallStep=false;
else
	smallStep=true;
fi
if [ $smallStep == true ]; then
	remainder=$((disks%drives));
else
	remainder=0;
fi
#how many ejects will it take then?
if [[ $drives -eq 1 ]]; then
	cycles=$disks;
elif [[ $remainder -eq 0 ]]; then
	cycles=$((disks/drives));
else
	cycles=$((disks/drives+1));
fi

echo "Looks like your system has $drives drives. With $disks disks in this set, it will take $cycles cycles";
if [ $smallStep == true ]; then
	echo "$((cycles-1)) cycles of $drives drives, and one cycle of $remainder drives";
else
	echo "$((cycles)) cycles of $drives drives";
fi

mkdir $output
cd $output

if [ $smallStep == true ]; then
	for j in `seq 1 $((cycles-1))`;do
		for i in `seq 0 $((drives-1))`; do eject /d$i; done
		echo "Insert disks in all drives, and press enter when finished. (remember to close trays!)"
		read
		for i in `seq 0 $((drives-1))`; do bash -c "dd if=/d$i of='`blkid -o value /d$i | head -n 1`.iso';eject /d$i" & done
		echo "Running! There should be $drives lights on, now. (We hope)"
		sleep 2;
		while [[ `ps aux|grep " dd "|grep -v grep|wc -l` -ne 0 ]];do sleep 10;done
		
	done

	for i in `seq 0 $((remainder-1))`; do eject /d$i;done
	echo "Insert disks in open drives, and press enter when finished. (remember to close trays!)"
	read
	for i in `seq 0 $((remainder-1))`; do bash -c "dd if=/d$i of='`blkid -o value /d$i | head -n 1`.iso';eject /d$i" & done
	echo "Running! There should be $remainder lights on, now. (We hope)"

        sleep 2s;
	while [[ `ps aux|grep " dd "|grep -v grep|wc -l` -ne 0 ]];do sleep 10;done
else
	for j in `seq 1 $cycles`;do
		for i in `seq 0 $((drives-1))`; do eject /d$i; done
		echo "Insert disks in all drives, and press enter when finished. (remember to close trays!)"
		read
		for i in `seq 0 $((drives-1))`; do bash -c "dd if=/d$i of='`blkid -o value /d$i | head -n 1`.iso';eject /d$i" & done
		echo "Running! There should be $drives lights on, now. (We hope)"
		sleep 2s;
		while [[ `ps aux|grep " dd "|grep -v grep|wc -l` -ne 0 ]];do sleep 10;done
	done
fi
echo "All done!"
#for i in `seq 0 $((drives-1))`; do eject /d$i; done