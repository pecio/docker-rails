# nginx as a frontend for a Rails application
FROM nginx

ADD nginx.conf /etc/nginx.conf
ADD cert.key /etc/nginx/
ADD cert.crt /etc/nginx/

EXPOSE 80
EXPOSE 443

CMD ["/usr/local/sbin/nginx"]
