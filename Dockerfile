FROM docker.io/ashish1981/s390x-rstudio:onlystudio
# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL3009
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    gdebi-core \
    git \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libssl1.0.0 \
    libssl-dev \
    openssh-client \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.19.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-s390x && \
    chmod +x /usr/local/bin/tini

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

# Set default env values
ENV RSP_LICENSE ""
ENV RSP_LICENSE_SERVER ""
ENV RSP_TESTUSER rstudio
ENV RSP_TESTUSER_PASSWD rstudio
ENV RSP_TESTUSER_UID 10000
ENV RSP_LAUNCHER true
ENV RSP_LAUNCHER_TIMEOUT 10

# Copy config and startup
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh
COPY conf/* /etc/rstudio/

# Create log dir
RUN mkdir -p /var/lib/rstudio-server/monitor/log 
#&& \
#    chown -R rstudio-server:rstudio-server /var/lib/rstudio-server/monitor

EXPOSE 8787/tcp
EXPOSE 5559/tcp

#ENTRYPOINT ["tini", "--"]
#CMD ["/usr/local/bin/startup.sh"]