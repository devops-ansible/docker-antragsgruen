FROM jugendpresse/apache:php-7.2
MAINTAINER Martin Winter

# environmental variables
ENV APACHE_PUBLIC_DIR $APACHE_WORKDIR/web
ENV GITBRANCH v3

# expose ports
EXPOSE 80
EXPOSE 443

WORKDIR $APACHE_WORKDIR

COPY files/motiontool_boot.sh /boot.d/motiontool.sh

# install applets and services
RUN apt-get update -q --fix-missing
RUN apt-get -yq upgrade

RUN apt-get -yq install -y --no-install-recommends \
        g++ \
        texlive texlive-latex-extra texlive-generic-extra \
        texlive-lang-german texlive-latex-base texlive-latex-recommended \
        texlive-humanities texlive-fonts-recommended texlive-xetex poppler-utils

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove
RUN rm -r /var/lib/apt/lists/*

# clone current git repo of Antragsgrün
COPY app/ $APACHE_WORKDIR

# declare volume for usage with docker volumes
VOLUME ["$APACHE_WORKDIR"]

# run on every (re)start of container
ENTRYPOINT ["entrypoint"]
CMD ["apache2-foreground"]
