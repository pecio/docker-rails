# Docker configuration for Rails
I am creating a [Docker](https://www.docker.io/) configuration
with three separate containers, oriented for a production
environment:

* The Rails application (under [Unicorn](http://unicorn.bogomips.org/))
* A PostgreSQL 9.3 database
* An [nginx](http://nginx.org/) frontend and SSL proxy

The first image runs under Ubuntu 12.04 as I had trouble
installing Ruby in 14.04; the other two run under Ubuntu 14.04
and use Canonical supplied packages.

> Note this is *not* a Docker tutorial. I assume you have a
> Docker environment already running. Follow the superb
> [official instructions](https://www.docker.io/gettingstarted/#h_installation)
> if you need to set it up.

## Build and first start instructions

Note I ommit the `sudo` in all commands: prepend it if you need it in
your environment.

1. In the _root_ of the Rails application, build the Rails image
   (this is the longest step):

        docker build -t irails_app .

2. Enter the `/docker/postgresql` directory and build the
   PostgreSQL image:

        docker build -t ipostgres_rails .

3. Enter the `/docker/nginx` directory. Note there are two files,
   `cert.key` and `cert.crt`: these are sample self-signed certificates,
   replace them with *your* certificates (with the same file names and
   without passphrase).

4. From the `/docker/nginx` directory, build the nginx image:

        docker build -t inginx_rails .

5. Start the PostgreSQL image:

        docker run -d --name postgres_rails ipostgres_rails

6. Populate the DB with a one shot run of rake in the Rails image with the
   following long command:

        docker run -t -i --rm --link postgres_rails:postgresql irails_app /bin/bash -c -l "RAILS_ENV=production bundle exec rake db:migrate"

7. Start the Rails application server:

        docker run -d --link postgres_rails:postgresql --name rails_app irails_app

8. Start the nginx server:

        docker run -d -P --link rails_app:rails --volumes-from rails_app --name nginx_rails inginx_rails

9. Check mapped ports by running `docker ps` (in this case, 49182 for HTTP and 49181 for HTTPS):

        # docker ps
        CONTAINER ID        IMAGE                    COMMAND                CREATED              STATUS              PORTS                                           NAMES
        8f59b69c36b2        inginx_rails:latest      /bin/sh -c /usr/sbin   43 seconds ago       Up 6 seconds        0.0.0.0:49181->443/tcp, 0.0.0.0:49182->80/tcp   nginx_rails                                                        
        652c1a506220        irails_app:latest        /bin/bash -c -l 'RAI   51 seconds ago       Up 14 seconds       3000/tcp                                        nginx_rails/rails,rails_app                                        
        5640f473505d        ipostgres_rails:latest   /usr/lib/postgresql/   About a minute ago   Up 25 seconds       5432/tcp                                        nginx_rails/rails/postgresql,postgres_rails,rails_app/postgresql   

10. Verify you can access the application by visiting https://localhost:port/,
    e.g. https://localhost:49181/

## Stopping

Run
    docker stop nginx_rails rails_app postgres_rails

## Subsequent starts

Run
    docker start postgres_rails rails_app nginx_rails

## Running
