ARG tag=runtime
FROM  mcr.microsoft.com/dotnet/core/${tag}:3.1
ENV TIMEZONE=Asia/Shanghai

ARG s6url=https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64.tar.gz
COPY services.d /etc/services.d
RUN ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
 && echo "$TIMEZONE" > /etc/timezone \
 && sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1ftp2.cn.debian.org\3main contrib non-free/g' /etc/apt/sources.list \
 && apt-get update \
 # && apt-get upgrade \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends openssh-server curl unzip \
 && mkdir -p /var/run/sshd \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
 && curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l /vsdbg \
 && curl --fail --silent -L ${s6url} | \
    tar xzvf - -C /

ENTRYPOINT [ "/init" ]
