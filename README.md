## Adjusted SNMPD daemon for Docker use
This is a patched net-snmpd-5.7.3d daemon which can be used to enable SNMP monitoring on CoreOS. Within CoreOS it is not possible to execute a volume mount on /proc. In order to achieve this, the sourcode has been patched to use /host_proc. By executing a volume mount on /host_proc, SNMP is able to use the standard MIBS which collect metrics from the guest CoreOS system.

# Applied patch
The applied patch is rather simple but effective. The code is executed through a shell script calles "apply_patch.sh".

```shell
#!/bin/bash
grep -lR '"/proc' * | while read line
do
	sed -i 's@"/proc@"/host_proc@g' $line
done
```

# Compile line
The compilation of net-snmp is as default as it can get. We disable IPv6 and SNMP V1 but other than that we dont any fancy options.

```shell
./configure --prefix=/usr/local --disable-ipv6 --disable-snmpv1 --with-defaults
```

# Cleanup
In order to keep the image accepatable in terms of size we remove all installed packages except for perl-libs

```shell
rpm -e --nodeps $(grep Installed /var/log/yum.log | grep -v perl-libs | awk '{print $5}' | sed 's/^[0-9]://g')
```

# snmpd.conf
We added an external snmpd.conf because the EXAMPLE.conf file is not good enough to use as the default configuration. We want SNMPD to listen on all ports rather than only localhost. Also we might want to introduce a level of authorization rather than using the 'public' community string for collecting all metrics available.

```
...
agentAddress udp:161
...
view   all	   included   .1
...
rocommunity secret  default    -V all
```

# Run the image
Last but not least we need to run the image ofcourse. 

```shell
#!/bin/bash

docker run -d --name snmpd \
	-v /proc:/host_proc \
	-p 161:161/udp \
	digiwhite/snmpd
```

# Tracking
- 2015-09-24: Added automated build through github
