FROM nginx:1.15-alpine

MAINTAINER Brandon Simpkins <brandonsimpkins@gmail.com>

RUN apk update && \
 apk add libressl


# delete default configuration files
RUN rm /etc/nginx/conf.d/default.conf

RUN mkdir -p /etc/nginx/certs
RUN mkdir -p /var/www/html

COPY config-templates/nginx.conf /etc/nginx/nginx.conf

# TODO need to add these onto the host later into the process
COPY server-certs       /opt/reverse-proxy/server-certs
COPY scripts            /opt/reverse-proxy/scripts
COPY config-templates   /opt/reverse-proxy/config-templates

RUN chmod 755 /opt/reverse-proxy/scripts/*

ENTRYPOINT ["/opt/reverse-proxy/scripts/entry-point.sh"]
# ENTRYPOINT ["ls", "-la", "/opt/reverse-proxy"]


