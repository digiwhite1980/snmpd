#!/bin/bash

docker run -d --name snmpd \
	-v /proc:/host_proc \
	-p 161:161/udp \
	digiwhite/snmpd
