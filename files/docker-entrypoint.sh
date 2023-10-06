#!/bin/sh

# Add ssh user & password
adduser -h /home/$SSHUSER -s /bin/sh -D $SSHUSER
echo -n adb:$SSHPASS | chpasswd

# Start ssh as daemon service
ssh-keygen -A
chmod 600 /ssh/ssh_*  >/dev/null 2>&1
cp -rf /ssh/ >/dev/null 2>&1
/usr/sbin/sshd

# Start adbportforward as entrypoint
java -jar /opt/adbportforward.jar server adblocation=/opt/platform-tools
