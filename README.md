# Docker configuration for Rails
I am creating a [Docker](https://www.docker.io/) configuration
with three separate containers, oriented for a production
environment:

* The [Rails](http://rubyonrails.org/) application (under
  [Unicorn](http://unicorn.bogomips.org/))
* A [PostgreSQL](http://www.postgresql.org/) 9.3 database
* An [nginx](http://nginx.org/) frontend and SSL proxy

The first two images run latest Ubuntu LTS (currently 16.04). Rails
application has latest MRI (currently 2.3.0) installed through RVM;
PostgreSQL image uses Canonical supplied packages. Nginx image is the
(Debian based) [official image](https://registry.hub.docker.com/_/nginx/)
(tested with 1.9.14) with custom configuration files. As of late April
2016, it builds and runs correctly under latest Docker (1.11.0).

> Note this is *not* a Docker tutorial. I assume you have a
> Docker environment already running. Follow the superb
> [official instructions](https://docs.docker.com/)
> if you need to set it up.

## Build and first start instructions

Note I ommit the `sudo` in all `docker` commands: prepend it if you
need it in your environment.

0. Copy the `Dockerfile` file and `docker` directory to the _root_
   of your Rails application.

1. In the _root_ of the Rails application, build the Rails image
   (this is the longest step):

        docker build -t irails_app .

2. Enter the `postgresql` directory and build the
   PostgreSQL image:

        docker build -t ipostgres_rails .

3. Enter the `nginx` directory. Note there are two files,
   `cert.key` and `cert.crt`: these are sample self-signed certificates,
   replace them with *your* certificates (with the same file names and
   without passphrase).

4. From the `nginx` directory, build the nginx image:

        docker build -t inginx_rails .

5. Start the PostgreSQL image:

        docker run -d --name postgres_rails ipostgres_rails

6. Populate the DB with a one shot run of rake in the Rails image with the
   following long command:

        docker run -t -i --rm --link postgres_rails:postgresql irails_app /bin/bash -c -l "bundle exec rake db:migrate"

7. Start the Rails application server:

        docker run -d --link postgres_rails:postgresql --name rails_app irails_app

8. Start the nginx server:

        docker run -d -P --link rails_app:rails --volumes-from rails_app --name nginx_rails inginx_rails

9. Check mapped ports by running `docker ps` (in this case, 49153 for HTTP and 49154 for HTTPS):

        # docker ps
        CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS                                           NAMES
        88ded649df8d        inginx_rails:latest      "nginx -g 'daemon of   2 weeks ago         Up 4 seconds        0.0.0.0:49153->80/tcp, 0.0.0.0:49154->443/tcp   nginx_rails         
        5b048ccdbd4b        irails_app:latest        "/bin/bash -c -l 'bu   2 weeks ago         Up 5 seconds        3000/tcp                                        rails_app           
        9da71f669478        ipostgres_rails:latest   "/usr/lib/postgresql   2 weeks ago         Up 13 seconds       5432/tcp                                        postgres_rails      


10. Verify you can access the application by visiting https://localhost:port/,
    e.g. https://localhost:49154/

## Stopping

Run

    docker stop nginx_rails rails_app postgres_rails

## Subsequent starts

Run

    docker start postgres_rails rails_app nginx_rails

## Running on fixed ports

If you want to use specific ports, you need to specify them when first
starting the nginx image.

Remove the container, if you started it with `-P` as instructed above,
with

    docker stop nginx_rails
    docker rm nginx_rails

To start the nginx container in the standard ports, run

    docker run -d -p 80:80 -p 443:443 --link rails_app:rails --volumes-from rails_app --name nginx_rails inginx_rails

This will make the container listen in all host interfaces.
Change the ports before the colons (:) if you want specific but
different ports.
