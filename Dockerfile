FROM openjdk:8u212-jre-alpine3.9

# Set up insecure default key
RUN mkdir -m 0750 /root/.android
ADD files/insecure_shared_adbkey /root/.android/adbkey
ADD files/insecure_shared_adbkey.pub /root/.android/adbkey.pub
ADD files/update-platform-tools.sh /usr/local/bin/update-platform-tools.sh

RUN set -xeo pipefail && \
    apk update && \
    apk add wget ca-certificates tini && \
    wget -O "/etc/apk/keys/sgerrand.rsa.pub" \
      "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    wget -O "/tmp/glibc.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk" && \
    wget -O "/tmp/glibc-bin.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-bin-2.28-r0.apk" && \
    apk add "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    rm "/root/.wget-hsts" && \
    rm "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm -r /var/cache/apk/APKINDEX.* && \
    /usr/local/bin/update-platform-tools.sh

# Set up PATH
ENV PATH $PATH:/opt/platform-tools

# Install open ssh
RUN apk add --update --no-cache openssh
ADD files/sshd_config /etc/ssh/.

# Volume ssh key
RUN mkdir /ssh
VOLUME ssh

# Expose openssh server
EXPOSE 22

# Add adbportforward to image
ADD files/adbportforward.jar /opt/.

# Expose adb server
EXPOSE 6037

# Add docker-entrypoint to image
ADD files/docker-entrypoint.sh /opt/.
RUN chmod +x /opt/docker-entrypoint.sh

# Change workdir
WORKDIR /opt

# Entrypoint adb server
ENTRYPOINT "./docker-entrypoint.sh"
