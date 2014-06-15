# nginx as a frontend for a Rails application
FROM nginx

ADD nginx.conf /etc/nginx.conf
ADD default /etc/default.site
ADD cert.key /etc/cert.key
ADD cert.crt /etc/cert.crt

EXPOSE 80
EXPOSE 443

CMD ["/usr/local/sbin/nginx"]
