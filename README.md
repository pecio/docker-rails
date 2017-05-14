# Docker configuration for Rails
I am creating a [Docker](https://www.docker.io/) configuration
with three separate containers, oriented for a production
environment:

* The [Rails](http://rubyonrails.org/) application (under
  [Puma](https://github.com/puma/puma))
* A [PostgreSQL](http://www.postgresql.org/) database
* An [nginx](http://nginx.org/) frontend and SSL proxy

The three images are base upon alpine variants of official images:

* [ruby:alpine](https://hub.docker.com/_/ruby/)
* [postgres:alpine](https://hub.docker.com/_/postgres/)
* [nginx:stable-alpine](https://hub.docker.com/_/nginx/)

> Note this is *not* a Docker tutorial. I assume you have a
> Docker environment already running. Follow the superb
> [official instructions](https://docs.docker.com/)
> if you need to set it up.

## Build and first start instructions

Note I ommit the `sudo` in all `docker` commands: prepend it if you
need it in your environment.

1. Copy the contents of the `app` directory to the _root_
   of your Rails application.

2. Build the Rails image (this is the longest step):

        docker build -t rails_app /path/to/your/app

3. Build the PostgreSQL image and start the container:

        docker build -t rails_db postgres
        docker run -d --name rails_db rails_db

   Allow some time for the database to be created and started before
   launching `rake db:migrate` to populate it later.

4. Enter the `nginx` directory.
   - There are two files, `cert.key` and `cert.crt`: these are sample
     self-signed certificates, replace them with *your* certificates
     (with the same file names and without passphrase).
   - Review `default.site`. In particular, you may want to change
     `server_name localhost;` to a better value.

5. From the `nginx` directory, build the nginx image:

        docker build -t rails_nginx .

6. Populate the DB with a one shot run of rake in the Rails image with the
   following command:

        docker run -t --rm --link rails_db:db rails_app rake db:migrate

7. Start the Rails application server, replacing `YOUR_SECRET` with
   a random string of your choice.

        docker run -d --link rails_db:db --name rails_app -e SECRET_KEY_BASE=YOUR_SECRET rails_app

8. Start the nginx server:

        docker run -d -P --link rails_app:rails --volumes-from rails_app --name rails_nginx rails_nginx

9. Check mapped ports by running `docker ps` (in this case, 32769
   for HTTP and 32768 for HTTPS):

        # docker ps
        CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                           NAMES
        e66a6c7b7c48        rails_nginx         "nginx -g 'daemon off"   20 minutes ago      Up 20 minutes       0.0.0.0:32769->80/tcp, 0.0.0.0:32768->443/tcp   rails_nginx
        de5b5b34f3dd        rails_app           "/bin/sh -c -l 'bundl"   21 minutes ago      Up 21 minutes       3000/tcp                                        rails_app
        0e6284aed5cd        rails_db            "docker-entrypoint.sh"   28 minutes ago      Up 28 minutes       5432/tcp                                        rails_db

10. Verify you can access the application by visiting https://localhost:port/,
    e.g. https://localhost:32768/

## Stopping

Run

    docker stop rails_nginx rails_app rails_db

## Subsequent starts

Run

    docker start rails_db rails_app rails_nginx

## Running on fixed ports

If you want to use specific ports, you need to specify them when first
starting the nginx image.

Remove the container, if you started it with `-P` as instructed above,
with

    docker rm -f rails_nginx

To start the nginx container in the standard ports, run

    docker run -d -p 80:80 -p 443:443 --link rails_app:rails --volumes-from rails_app --name rails_nginx rails_nginx

This will make the container listen in all host interfaces.
Change the ports before the colons (:) if you want specific but
different ports.
