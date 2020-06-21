FROM docker.io/ashish1981/s390x-ubuntu-r-base

ENV OPERATING_SYSTEM=ubuntu_bionic

ARG AWS_REGION=us-east-1

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl4 \
 #   libicu63 \
 #   libjpeg62-turbo \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && BUILDDEPS="curl \
    default-jdk \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    tcl8.6-dev \
    tk8.6-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev" \
    && apt-get install -y --no-install-recommends $BUILDDEPS \
    && sed -i '/^R_LIBS_USER=.*$/d' /usr/local/lib/R/etc/Renviron \
    && echo "R_LIBS_USER=\${R_LIBS_USER-'/usr/local/lib/R/site-library'}" >> /usr/local/lib/R/etc/Renviron \
    && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
    ## Set configured CRAN mirror
    && if [ -z "$BUILD_DATE" ]; then MRAN=$CRAN; \
    else MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE}; fi \
    && echo MRAN=$MRAN >> /etc/environment \
    && echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
    ## Use littler installation scripts
    && Rscript -e "install.packages(c('littler', 'docopt'), repo = '$CRAN')" \
    && ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
    ## Clean up from R source install
    && cd / \
    && rm -rf /tmp/* \
#    && apt-get remove --purge -y $BUILDDEPS \
#    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*



# ensure we use the java 8 compiler
#RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

## build patchelf
# RUN cd /tmp \
#     && wget https://nixos.org/releases/patchelf/patchelf-0.9/patchelf-0.9.tar.gz \
#     && tar xzvf patchelf-0.9.tar.gz \
#     && cd patchelf-0.9 \
#     && ./configure \
#     && make \
#     && make install

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
# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.19.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-s390x && \
    chmod +x /usr/local/bin/tini

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

# Install Python  -------------------------------------------------------------#
ARG PYTHON_VERSION=3.6.5
RUN curl -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/python/${PYTHON_VERSION} && \
    rm /tmp/miniconda.sh && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -tipsy && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -a && \
    /opt/python/${PYTHON_VERSION}/bin/pip install virtualenv

# Install other Python PyPi packages
RUN /opt/python/${PYTHON_VERSION}/bin/pip install --no-cache-dir \
    pip==20.0.2 \
    jupyter==1.0.0 \
    jupyterlab==2.1.0 \
    rsp_jupyter==1.2.5003 \
    rsconnect_jupyter==1.3.3.1

# Install Jupyter extensions
RUN /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter


## run install-boost twice - boost exits 1 even though it has installed good enough for our uses.
## https://github.com/rstudio/rstudio/blob/master/vagrant/provision-primary-user.sh#L12-L15
#COPY dependencies/common/install-boost /tmp/
#RUN bash /tmp/install-boost || bash /tmp/install-boost

RUN cd /tmp && \ 
wget http://rpmfind.net/linux/fedora-secondary/development/rawhide/Everything/s390x/os/Packages/r/rstudio-server-1.3.959-2.fc33.s390x.rpm \
&& alien -i rstudio-server-1.3.959-2.fc33.s390x.rpm

# Copy config and startup
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh
COPY conf/* /etc/rstudio/

ENTRYPOINT ["tini", "--"]
#CMD ["/usr/local/bin/startup.sh"]