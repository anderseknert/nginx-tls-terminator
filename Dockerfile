FROM nginx:1.19.1-alpine

ENV PROXY_LISTEN_PORT 8443
ENV PROXY_UPSTREAM_PORT 80

COPY conf/nginx.conf             /etc/nginx/
COPY conf/server.conf.template   /etc/nginx/templates/

RUN rm /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    chmod 777 /etc/nginx/conf.d

USER 1000:1000
