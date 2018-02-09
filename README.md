# Apache for Antragsgrün / motion.tools #
## README ##

### What is this repository for? ###
Within this Repo you will find the Dockerfile and the pipeline configuration to build a running container for the motion tool Antragsgrün.

### How do I get set up? ###
Since the docker principles tell you to only run one process within one container, the container provided within this repository, `jugendpresse/antragsgruen`, only provides the php application. You need to setup a MySQL container, too. The `docker-compose.yml` within this repo shows you, how you can set this up.

If you want to reuse an existing database (container), you have to add a database and the credentials manually and remove the database service from `docker-compose.yml`.

Deploying from `docker-compose.yml` works by running the following command:

```sh
docker-compose up -d
```

If you've set your Antragsgrün up by `docker-compose.yml`, your container normally is called something like `antragsgruen_antragsgruen_1`.

First start-up (and after updates) will take a while due to installing the used PHP / NodeJS packages. The startup process is done, when the Docker logs show you something like that:

```sh
$ docker logs -f antragsgruen_antragsgruen_1

# [Fri Feb 09 10:00:00.000000 2018] [core:notice] [pid 1] AH00010: Command line: 'apache2 -D FOREGROUND'
```


The Hostname of the database, you've created by `docker-compose.yml` is the name of the Docker container and will normally look like `antragsgruen_database_1`. Use this hostname during setup!

### When was the image built, I'm using? ###

You can get the build-date of the image of your currently running container by running the following command:

```sh
docker exec -it antragsgruen_antragsgruen_1 cat /etc/built_at
```

### Contribution guidelines ###

This Repo is Creative Commons non Commercial - You can contribute by forking and using pull requests. The team will review them asap.

### environmental variables you should be aware of ###

The following environmental variables you can edit. There are more of them, but there should be no need to update / change the other ones (as the `www-data` username for Apache runner and the `/var/www/html/` folder as working directory).

On a non-development setup, Antragsgrün wants to communicate with the users – i.e. `A new motion was created` or `You forgot your password? Here's a new one!` and so on. Therefor the serverside sendmail-equivalent `msmtp` has to be configured and all you've to do is to set the following environmental variables:

* `SMTP_HOST` should be set to your smtp host, i.e. `mail.example.com`
* `SMTP_PORT` defaults to `587`
* `SMTP_FROM` should be set to your sending from address, i.e. `motiontool@example.com`
* `SMTP_USER` defaults to `SMTP_FROM` and has to be the user, you are authenticating on the `SMTP_HOST`
* `SMTP_PASS` should be set to your plaintext(!) smtp password, i.e. `I'am very Secr3t!`

If you are running Antragsgrün behind a reverse proxy like Træfik (the `docker-compose.yml` does NOT!), you can ignore the following variable. Else it should be set to the FQDN you'll use for visiting Antragsgrün, i.e. `motiontool.example.com`:

* `APACHE_FQDN`

### installed tools ###

#### Python + Tools ####

* `python-yaml`
* `python-jinja2`
* `python-httplib2`
* `python-keyczar`
* `python-paramiko`
* `python-setuptools`
* `python-pkg-resources`
* `python-pip`

#### OPS-Tools ####

* `htop`
* `tree`
* `zsh`
* `tmux`
* `screen`
* `vim`
* `wget`
* `curl`
* `supervisor`
* `openssl`
* `bzip2`
* `unzip`
* `zip`
* `sudo`
* `ssh`
* `msmtp` as small SMTP relay – has to be configured for production systems
* `msmtp-mta` for using `sendmail` with `msmtp`
* `nodejs`
* `j2cli` for templating
* `composer`

#### tools required by PHP extensions ####

* `libcurl3-dev` for `curl`
* `libxml2-dev` for `xml`
* `libicu-dev` for `intl`
* `libfreetype6-dev` for `mbstring`
* `libc-client-dev` for `imap`
* `libkrb5-dev` for `imap`
* `libmcrypt-dev` for `mcrypt`
* `libjpeg62-turbo-dev` for `gd`
* `libpng-dev` for `gd`
* `libfreetype6-dev` for `gd`

#### other tools ####

* `git`
* `perl`
* `ttf-dejavu`
* `procps`
* `xmlstarlet`
* `mysql-client`
* `g++`

#### installed PHP extensions ####

* `pdo` and `pdo_mysql`
* `imap`
* `bzip2`
* `mcrypt`
* `intl`
* `json`
* `mysqli`
* `opcache`
* `curl`
* `xml`
* `mbstring`
* `gd`
* `ldap`
