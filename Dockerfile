FROM docker.io/ashish1981/s390x-ubuntu-r-base

ENV OPERATING_SYSTEM=ubuntu_bionic

ARG AWS_REGION=us-east-1

# install needed packages. replace httpredir apt source with cloudfront
RUN set -x \
    && sed -i "s/archive.ubuntu.com/$AWS_REGION.ec2.archive.ubuntu.com/" /etc/apt/sources.list \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y gnupg1 \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x51716619e084dab9 \
    && echo 'deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/' >> /etc/apt/sources.list \
    && apt-get update

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y \
    ant \
    build-essential \
    clang \
    curl \
    debsigs \
    dpkg-sig \
    expect \
    fakeroot \
    git-core \
    libattr1-dev \
    libacl1-dev \
    libbz2-dev \
    libcap-dev \
    libcurl4-openssl-dev \
    libfuse2 \
    libgtk-3-0 \
    libgl1-mesa-dev \
    libegl1-mesa \
    libpam-dev \
    libpango1.0-dev \
    libpq-dev \
    libsqlite3-dev \
    libuser1-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    lsof \
    openjdk-8-jdk \
    p7zip-full \
    pkg-config \
    python \
#    r-base \
    sudo \
    unzip \
    uuid-dev \
    valgrind \
    wget \
    zlib1g-dev \
    alien

# ensure we use the java 8 compiler
#RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

## build patchelf
RUN cd /tmp \
    && wget https://nixos.org/releases/patchelf/patchelf-0.9/patchelf-0.9.tar.gz \
    && tar xzvf patchelf-0.9.tar.gz \
    && cd patchelf-0.9 \
    && ./configure \
    && make \
    && make install

## run install-boost twice - boost exits 1 even though it has installed good enough for our uses.
## https://github.com/rstudio/rstudio/blob/master/vagrant/provision-primary-user.sh#L12-L15
COPY dependencies/common/install-boost /tmp/
RUN bash /tmp/install-boost || bash /tmp/install-boost

RUN cd /tmp && \ 
wget http://rpmfind.net/linux/fedora-secondary/development/rawhide/Everything/s390x/os/Packages/r/rstudio-server-1.3.959-2.fc33.s390x.rpm \
&& alien -i rstudio-server-1.3.959-2.fc33.s390x.rpm