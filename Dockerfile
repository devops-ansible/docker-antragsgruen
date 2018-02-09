FROM php:7.1-apache
MAINTAINER Martin Winter

# environmental variables
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV WORKINGUSER www-data
ENV WORKINGGROUP www-data
ENV WORKINGDIR /var/www/html

# expose ports
EXPOSE 80
EXPOSE 443

# install applets and services
RUN apt-get update
RUN apt-get -yq install -y --no-install-recommends \
        software-properties-common \
        aptitude

RUN apt-get update -q --fix-missing
RUN apt-get -yq upgrade
RUN apt-get -yq install -y --no-install-recommends \
        python-yaml \
        python-jinja2 \
        python-httplib2 \
        python-keyczar \
        python-paramiko \
        python-setuptools \
        python-pkg-resources \
        python-pip

RUN apt-get -yq install -y --no-install-recommends \
        htop \
        tree \
        zsh \
        tmux \
        screen \
        vim \
        wget \
        curl \
        supervisor \
        openssl \
        zip unzip bzip2 \
        ssh \
        sudo \
        g++ \
        msmtp msmtp-mta

RUN apt-get -yq install -y --no-install-recommends \
        git \
        perl \
        ttf-dejavu \
        procps \
        xmlstarlet \
        mysql-client

RUN apt-get -yq install -y --no-install-recommends \
        libcurl3-dev \
        libxml2-dev \
        libicu-dev \
        libc-client-dev \
        libkrb5-dev \
        libmcrypt-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libpng-dev

RUN pip install j2cli

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# install and enable php modules
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-configure intl
RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql imap zip mcrypt \
        intl json mysqli opcache curl xml mbstring
RUN a2enmod rewrite

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

RUN apt-get -yq install -y --no-install-recommends libldap2-dev
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install -j$(nproc) ldap

# install composer
COPY files/composer_install.sh /composer.sh
RUN chmod a+x /composer.sh
RUN /composer.sh
RUN mv composer.phar /usr/local/bin/composer
RUN rm -f /composer.sh

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove
RUN rm -r /var/lib/apt/lists/*

# clone current git repo of Antragsgrün
RUN git clone https://github.com/CatoTH/antragsgruen.git $WORKINGDIR
RUN chown $WORKINGUSER:$WORKINGGROUP $WORKINGDIR/..

# copy template files
COPY files/apache.j2  /templates/apache.j2
COPY files/msmtprc.j2 /templates/msmtprc.j2

#copy script files
COPY files/boot.sh /boot.sh
RUN chmod a+x /boot.sh

COPY files/entrypoint /usr/local/bin/

RUN chmod a+x /boot.sh /usr/local/bin/entrypoint

# Date of Build
RUN echo "Built at" $(date) > /etc/built_at

# run on every (re)start of container
ENTRYPOINT ["entrypoint"]
CMD ["apache2-foreground"]
