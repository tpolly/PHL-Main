#!/bin/bash
# This script can be used to monitor a participant's progress in the study. It reads a file from the results folder and displays the state the participant is currently in.

cd "/opt/BA/User-Interface/"
if [ $(ls -1 results | wc -l) != 1 ]
then
	echo "more than one file in results"
	exit 1
fi

file=$(ls -1 results)

while :
	do cp "results/${file}" "tmp.json"
	ruby << EOF
		require "json"
		h=JSON.parse(File.read('tmp.json'))
		r=h['test_results']['recognize'].keys.map(&:to_i).max
		c=h['test_results']['construct'].keys.map(&:to_i).max
		puts "recognize state:" + r.to_s
		puts "construct state:" + c.to_s
EOF

	sleep 30
	clear
done
