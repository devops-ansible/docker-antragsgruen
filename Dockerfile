ARG BASEIMAGE="devopsansiblede/apache"
ARG BASEVERSION="php8"

FROM ${BASEIMAGE}:${BASEVERSION}

MAINTAINER Martin Winter <dev@winter-martin.de>

# environmental variables
ENV APACHE_PUBLIC_DIR "${APACHE_WORKDIR}/web"
ENV LATEX_ENABLE "yes"

# expose ports
EXPOSE 80
EXPOSE 443

WORKDIR "${APACHE_WORKDIR}"

COPY files/ /DockerInstall/

# install applets and services
RUN chmod a+x /DockerInstall/install.sh && \
    /DockerInstall/install.sh

# clone current git repo of Antragsgrün
COPY app/ "${APACHE_WORKDIR}"

# declare volume for usage with docker volumes
VOLUME [ "${APACHE_WORKDIR}" ]

# run on every (re)start of container
ENTRYPOINT [ "entrypoint" ]
CMD [ "apache2-foreground" ]
