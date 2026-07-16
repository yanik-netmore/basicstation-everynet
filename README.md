Publicly reachable files for basicstation configuration of Cloudcell gateway and Everynet V2 gateway


## Prerequisite
- SSH is needed (either old or new RAT)
- All needed files stored in a publicly reachable HTTP server, here: https://something.somewhere

## Cloudcell Gateway

- SSH to the gateway and execute this:
```
FILESHOST="https://something.somewhere/cloudgw"
export PS1="\u@\h: \w\a: "
sv stop lora
mount -o rw,remount /
mv /app/lora/ranproxy /app/lora/ranproxy_backup
mv /app/lora/run /app/lora/run_backup
wget $FILESHOST/station -O /app/lora/station
wget $FILESHOST/cloudcell_lora_run  -O /app/lora/run
chmod 755 /app/lora/station
chmod 755 /app/lora/run
mkdir -p /configs/station
curl $FILESHOST/cups.trust > /configs/station/cups.trust
curl $FILESHOST/cups.uri > /configs/station/cups.uri
rm -vf /var/log/mobile/log* /var/log/vpn/log*
curl $FILESHOST/eui.sh 2> /dev/null | sh -

```

- At the end of execution there will be a line *export EUI=xxxxxxxx*, type the command:

```
export EUI=xxxxxxxx
```

- Then execute:

```
curl $FILESHOST/station.conf 2> /dev/null| sed "s/EUI/$EUI/" > /configs/station/station.conf
sv start lora
sleep 2
mount -o ro,remount /
```

### Checking


```
tail -f /var/log/station.log  | grep -v -e NMEA -e TIMEGPS -e GGA -e garbage -e 'SYNC: ustime' -e 'UBX cksum' -e 'nmea_gga:'
```

### Known issues
- On some gateways, the first execution of **sv start lora** can lead to a station binary segfault, this seems to be related to the GPS exclusive access by the former lora service you just stopped. **sv restart lora** will cure this
- If you experienced some CUPS error "No TC .....", regenerate the certificate in TPE GUI and restart the lora service

## EverynetV2

- SSH to the gateway and execute this:
```
FILESHOST="https://something.somewhere/everynet"
export PS1="\u@\h: \w\a: "
sv stop ranproxy
mount -o rw,remount /;mount -o rw,remount /mnt/datafs
mv /mnt/datafs/ranproxy/ranproxy /mnt/datafs/ranproxy/ranproxy_backup
mkdir -p /mnt/datafs/configs/station
curl -k $FILESHOST/station > /mnt/datafs/app/station
curl -k $FILESHOST/cups.trust > /mnt/datafs/configs/station/cups.trust
curl -k $FILESHOST/cups.uri > /mnt/datafs/configs/station/cups.uri
curl -k $FILESHOST/everynetv2_lora_run > /mnt/datafs/app/run
chmod 755 /mnt/datafs/app/station
chmod 755 /mnt/datafs/app/run
rm /etc/sv/app/down /etc/runit/service/app/down
touch /etc/sv/ranproxy/down /etc/runit/service/ranproxy/down

curl -k $FILESHOST/eui.sh 2> /dev/null | sh -
```

- At the end of execution there will be a line *export EUI=xxxxxxxx*, type the command:

```
export EUI=xxxxxxxx
```

- Then execute:

```
curl -k $FILESHOST/station.conf 2> /dev/null| sed "s/EUI/$EUI/" > /mnt/datafs/configs/station/station.conf
cp /etc/metalog.conf /etc/metalog.conf_backup
curl -k $FILESHOST/metalog.add >> /etc/metalog.conf
sv restart metalog
sv start app
sv stop ranmon
touch /etc/runit/service/ranmon/down
touch /etc/sv/ranmon/down
mv /mnt/datafs/ranmon /mnt/datafs/ranmon_backup
mount -o ro,remount /;mount -o ro,remount /mnt/datafs
```

### Known issues
- If you experienced some CUPS error "No TC .....", regenerate the certificate in TPE GUI and restart the lora service
