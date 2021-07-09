FROM nginx:1.21.1-alpine

ENV NGINX_ENVSUBST_OUTPUT_DIR /tmp
ENV PROXY_LISTEN_PORT 8443
ENV PROXY_UPSTREAM_PORT 8080
ENV ACCESS_LOG_LOCATION /tmp/nginx.access.log

COPY conf/nginx.conf             /etc/nginx/
COPY conf/server.conf.template   /etc/nginx/templates/

RUN rm /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    chmod 777 /etc/nginx/conf.d

USER 1000:1000
