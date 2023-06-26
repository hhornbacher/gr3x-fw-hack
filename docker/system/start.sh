#!/bin/sh -e


syslogd -s 200 -b 4
klogd

MOD_REVISIONS=/etc/revisions
for f in `ls $MOD_REVISIONS`; do
    logger -t version `cat $MOD_REVISIONS/$f`
done

#insmod /home/root/murata-driver/bcmdhd.ko

CAMCTLD_LOG=trace camctld -w &

# wait for camctld ready
until [ -f "/tmp/camctld_ready" ]; do usleep 100000 ; done

# usbd &
SYSMGRD_LOG=info sysmgrd &

MODE=`cat /tmp/startup_mode`
if [ "$MODE" = "restrict" ]; then
    echo "rc.local(restrict) complete"
    exit 0
fi

while true; do sleep 5 ; done

# NETMGRD_LOG=info netmgrd &
# BLESRVD_LOG=info bled &

# # wait for storage mounted
# until [ -f "/tmp/mounted" ]; do usleep 100000; done

# WEBAPID_LOG_LEVEL=info webapid &

# until [ -e "/dev/mtp_usb" ]; do usleep 100000; done
# MTPD_LOG_LEVEL=info mtpd &

# echo "rc.local(normal) complete"

# exit 0
