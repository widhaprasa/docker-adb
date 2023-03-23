#!/bin/sh

# Add ssh user & password
adduser -h /home/$SSHUSER -s /bin/sh -D $SSHUSER
echo -n adb:$SSHPASS | chpasswd

# Start ssh as daemon service
ssh-keygen -A
/usr/sbin/sshd

# Start adbportforward as entrypoint
java -jar adbportforward.jar server adblocation=/opt/platform-tools
