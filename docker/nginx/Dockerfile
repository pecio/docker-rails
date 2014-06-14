# nginx as a frontend for a Rails application
FROM ubuntu:latest

# Remove debconf warnings
ENV DEBIAN_FRONTEND noninteractive

# Update packages
# Install nginx
# Redirect access_log to stdout and error_log to stderr
# Configure nginx not to daemonize
RUN apt-get update &&\
    apt-get upgrade -qy &&\
    apt-get install -qy nginx &&\
    /bin/sed -i.orig '/access_log/c\access_log /proc/self/fd/1;' /etc/nginx/nginx.conf &&\
    /bin/sed -i      '/error_log/c\error_log /proc/self/fd/2;' /etc/nginx/nginx.conf &&\
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf

ADD default /etc/nginx/sites-enabled/default
ADD cert.key /etc/nginx/
ADD cert.crt /etc/nginx/

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/nginx"]
