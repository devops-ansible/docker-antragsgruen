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
        texlive texlive-latex-extra texlive-generic-extra

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove
RUN rm -r /var/lib/apt/lists/*

# clone current git repo of Antragsgrün
ARG GITTAG
ARG GITBRANCH
RUN git clone https://github.com/CatoTH/antragsgruen.git --branch $(echo ${GITBRANCH:-master}) ./ && \
    git checkout $(echo ${GITTAG:-master})

# declare volume for usage with docker volumes
VOLUME ["$APACHE_WORKDIR"]

# run on every (re)start of container
ENTRYPOINT ["entrypoint"]
CMD ["apache2-foreground"]
