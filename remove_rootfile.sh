#!/bin/bash
# Recommend syntax for setting an infinite while loop
date
sleep 10800
while :
do
	echo "date "
	date
	echo "check root files"
	ls *.root
	echo "........."
        echo "........ Deleting root files...... "
        rm *.root
        sleep 1800
done
