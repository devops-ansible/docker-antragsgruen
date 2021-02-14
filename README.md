# Apache for Antragsgrün / motion.tools #
## README ##

### What is this repository for? ###
Within this Repo you will find the Dockerfile and the pipeline configuration to build a running container for the motion tool Antragsgrün.

### How do I get set up? ###

First things first: **_NEVER_ run the `docker-compose.yml` or the `docker-compose-traefik.yml` without adjustments in production!** You need to adjust it to use your passwords, your domain(s) – even probably you need to define docker networks and other environment specific settings to get the tool running!

Since the docker principles tell you to only run one process within one container, the container provided within this repository, `jugendpresse/antragsgruen`, only provides the php application. You need to setup a MySQL container, too. The `docker-compose.yml` within this repo shows you, how you can set this up.

If you want to reuse an existing database (container), you have to add a database and the credentials manually and remove the database service from `docker-compose.yml`.

You'll need to edit your settings within the `docker-compose.yml` file – i.e. set valid SMTP data to valid email account, declare a strong non-default database password, your domain already pointing to the Docker host, etc.<br/>
It is best practice to create a copy of the `docker-compose.yml` and adjust the settings within there, so a new git pull will not break:

```sh
cp -rp docker-compose.yml my-docker-compose.yml
vim my-docker-compose.yml
```

Deploying the original `docker-compose.yml` works by running the following command – don't forget to adjust your settings within this file:

```sh
docker-compose up -d
```

If you've made a copy and changed your settings there, you've to use this command instead:

```sh
docker-compose -f my-docker-compose.yml up -d
```


![docker-compose up -d](https://jugendpresse.cloud/s/hjNHYoU764vyYpB/download)

If you've set your Antragsgrün up by `docker-compose.yml`, your container normally is called something like `antragsgruen_antragsgruen_1`.

First start-up (and after updates) will take a while due to installing the used PHP / NodeJS packages. The startup process is done, when the Docker logs show you something like that:

```sh
$ docker logs -f antragsgruen_antragsgruen_1

# [Fri Feb 09 10:00:00.000000 2018] [core:notice] [pid 1] AH00010: Command line: 'apache2 -D FOREGROUND'
```

![docker logs -f antragsgruen_antragsgruen_1](https://jugendpresse.cloud/s/aojNWX6rQuTrjDp/download)

##### Reach the Website #####

Since the default Docker setup via `docker-compose` binds the webservice to port `8080` (`docker-compose.yml`, line 9), you can reach it via http://ip-address:8080 (or if you have bound an URL `domain.tld` to your IP even http://domain.tld:8080).

#### alternative setup with Træfik as reverse proxy

<aside class="warning">
    Due to a bug within Antragsgrün, one cannot proceed the installation via https. Therefor you have to configure your app to be reachable through port 80 / https during installation. My advice would be to expose another host-port like 8180 to container-port 80 during installation and afterwards remove the container and build it up without exposed port.
</aside>

In my setup, I don't want to use HTTP protocol within public (since it is not encrypted). To use the container via HTTPS protocol, there are two possibilities: you can configure the containers Apache to use certificates and an adjusted Apache2 config file, which all have to be mounted to the container. The alternative is to use a reverse proxy – i.e. [Træfik](https://traefik.io) is able to do what we need and to secure the container with free [Let’s Encrypt](https://letsencrypt.org) Certificates.

Visit [Træfik user guide](https://docs.traefik.io/user-guide/docker-and-lets-encrypt/) for detailed configuration. Please take a copy of `templates/traefik.toml` within this repository to `/srv/traefik/traefik.toml` on your Docker host, the default Træfik configuration file – you should at least change `[docker] > domain` and `[acme] > email` to valid values:

```sh
mkdir -p /srv/traefik
touch /srv/traefik/acme.json
chmod 0600 /srv/traefik/acme.json
cp files/traefik.toml /srv/traefik/traefik.toml
vim /srv/traefik/traefik.toml
```

After these preparation steps you should take a copy of the `docker-compose-traefik.yml` file and adjust it to your settings, too:

```sh
cp -rp docker-compose-traefik.yml my-docker-compose-traefik.yml
vim my-docker-compose-traefik.yml
```

Then you'll be prepared to run your containers (since the Træfik setup needs to be network sensitive unless one wants to achieve unexpected behavior, the `database` and the `proxy` network have to be created manually):

```sh
docker network create database
docker network create proxy
docker-compose -f my-docker-compose-traefik.yml up -d
```

#### Database configuration during setup ####

After the boot process of the main container (probably `antragsgruen_antragsgruen_1`), you normally want to set up your instance of Antragsgrün. The main part here is the connection to the database.

The Hostname of the database, you've created is the name of the Docker container of the database. If you used the `docker-compose.yml` file it will normally look like `antragsgruen_database_1`. Also given by `docker-compose.yml` you'll use the `root` user with the given password – please change it within the `docker-compose.yml` before you'll start your containers!

![Database-Setup](https://jugendpresse.cloud/s/dWK8cjpFgK28WNl/download)

### Contribution guidelines ###

This Repo is Creative Commons non Commercial - You can contribute by forking and using pull requests. The team will review them asap.

### environmental variables you should be aware of ###

The following environmental variables you can edit. There are more of them, but there should be no need to update / change the other ones (as the `www-data` username for Apache runner and the `/var/www/html/` folder as working directory).

Since a Docker container defaults the timezone and therefor the time sync to UTC, one can set the `TIMEZONE` environmental variable i.e. as `TIMEZONE="Europe/Berlin"` to change the container time behavior. `docker-compose.yml` file defaults this to `Europe/Berlin`.

On a non-development setup, Antragsgrün wants to communicate with the users – i.e. `A new motion was created` or `You forgot your password? Here's a new one!` and so on. Therefor the serverside sendmail-equivalent `msmtp` has to be configured and all you've to do is to set the following environmental variables:

* `SMTP_HOST` should be set to your smtp host, i.e. `mail.example.com`
* `SMTP_PORT` defaults to `587`
* `SMTP_FROM` should be set to your sending from address, i.e. `motiontool@example.com`
* `SMTP_USER` defaults to `SMTP_FROM` and has to be the user, you are authenticating on the `SMTP_HOST`
* `SMTP_PASS` should be set to your plaintext(!) smtp password, i.e. `I'am very Secr3t!`

If you are running Antragsgrün behind a reverse proxy like Træfik (the `docker-compose.yml` does NOT!), you can ignore the following variable. Else it should be set to the FQDN you'll use for visiting Antragsgrün, i.e. `motiontool.example.com`:

* `APACHE_FQDN`

### installed tools ###

See base repository: https://github.com/jugendpresse/apache

### build history ###

The official GitHub-Repository of the motion tool is not linked to this Docker image – so the automated build is now done by the Jenkins instance of Jugendpresse once a week based on (new) Tags within the git repo. For not rebuilding tags, the build date is stored for every tag within the `build_tags.json` file.
