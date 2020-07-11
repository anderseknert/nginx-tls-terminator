FROM nginx:1.19.0-alpine

# TODO: NAMING
ENV NGINX_TLS_PORT 8443
ENV NGINX_UPSTREAM_PORT 80

COPY conf/nginx.conf             /etc/nginx/
COPY conf/server.conf.template   /etc/nginx/templates/

RUN chmod 775 /etc/nginx/conf.d