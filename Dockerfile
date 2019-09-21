FROM  mcr.microsoft.com/dotnet/core/runtime:2.2
ENV TIMEZONE=Asia/Shanghai

COPY s6 /etc/s6

RUN ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
 && echo "$TIMEZONE" > /etc/timezone \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends openssh-server s6 \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

