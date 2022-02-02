#!/usr/bin/env bash

apt-get update -q --fix-missing
apt-get -yq upgrade
apt-get -yq install -y --no-install-recommends \
    g++ \
    texlive texlive-latex-extra texlive-generic-extra \
    texlive-lang-german texlive-latex-base texlive-latex-recommended \
    texlive-humanities texlive-fonts-recommended texlive-xetex \
    poppler-utils \
    libsodium-dev

apt-get clean
apt-get autoclean
apt-get autoremove
rm -r /var/lib/apt/lists/*

mv /DockerInstall/latex_state.php /latex.php
chmod a+x /latex.php

mv /DockerInstall/motiontool_boot.sh /boot.d/motiontool.sh

docker-php-ext-install bcmath
docker-php-ext-install intl
docker-php-ext-install calendar
docker-php-ext-install imap
docker-php-ext-install mysqli
docker-php-ext-install pdo_mysql
docker-php-ext-install pdo_pgsql
docker-php-ext-install sodium
docker-php-ext-install zip

rm -rf /DockerInstall
