FROM nginx:1.19.0-alpine

# TODO: NAMING
ENV NGINX_TLS_PORT 8443
ENV NGINX_UPSTREAM_PORT 80

COPY nginx.conf             /etc/nginx/
COPY server.conf.template   /etc/nginx/templates/

RUN chmod 775 /etc/nginx/conf.d