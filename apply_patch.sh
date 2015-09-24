#!/bin/bash
grep -lR '"/proc' * | while read line
do
	sed -i 's@"/proc@"/host_proc@g' $line
done
