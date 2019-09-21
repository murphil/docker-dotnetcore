FROM  mcr.microsoft.com/dotnet/core/runtime:2.2
ENV TIMEZONE=Asia/Shanghai

ARG s6url=https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz
COPY services.d /etc/services.d
RUN ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
 && echo "$TIMEZONE" > /etc/timezone \
 && sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1ftp2.cn.debian.org\3main contrib non-free/g' /etc/apt/sources.list \
 && apt-get update \
 # && apt-get upgrade \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends openssh-server curl \
 && mkdir -p /var/run/sshd \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
 && curl --fail --silent -L ${s6url} | \
    tar xzvf - -C /

ENTRYPOINT [ "/init" ]