FROM openjdk:8u212-jre-alpine3.9

# Set up insecure default key
RUN mkdir -m 0750 /root/.android
ADD files/insecure_shared_adbkey /root/.android/adbkey
ADD files/insecure_shared_adbkey.pub /root/.android/adbkey.pub
ADD files/update-platform-tools.sh /usr/local/bin/update-platform-tools.sh

# Add adbportforward to image
ADD adbportforward.jar .

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

# Expose adb server
EXPOSE 6037

# Entrypoint adb server
ENTRYPOINT [ "java", "-jar", "adbportforward.jar", "server", "adblocation=adb" ]
