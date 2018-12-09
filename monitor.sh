#!/bin/bash
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
		rs=h['test_results']['recognize'][r.to_s].map{|k,v| v['correct']}
		cs=h['test_results']['construct'][c.to_s].map{|k,v| v['correct']}
		tfp={true=>1,false=>0}.to_proc
		puts "recognize score:" + rs.to_s
		puts "recognize averg:" + (rs.map(&tfp).reduce(:+)/20.0).to_s
		puts "construct score:" + cs.to_s
		puts "construct averg:" + (cs.map(&tfp).reduce(:+)/10.0).to_s
		puts h['test_results']['distraction'].to_s
EOF

	sleep 30
	clear
done
