# nginx as a frontend for a Rails application
FROM ubuntu
RUN apt-get update
RUN apt-get install -qy nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-enabled/default
ADD cert.key /etc/nginx/
ADD cert.crt /etc/nginx/

EXPOSE 80
EXPOSE 443
VOLUME ["/var/log/nginx"]

CMD /usr/sbin/nginx
