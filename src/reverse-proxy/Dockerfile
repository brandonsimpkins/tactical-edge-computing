FROM nginx:1.15-alpine

MAINTAINER Brandon Simpkins <brandonsimpkins@gmail.com>

RUN apk --no-cache update && \
 apk add libressl curl

# delete default configuration files
RUN rm /etc/nginx/conf.d/default.conf

RUN mkdir -p /etc/nginx/certs

COPY user-ca-public-cert.pem /etc/nginx/certs

COPY server-certs       /opt/reverse-proxy/server-certs
COPY scripts            /opt/reverse-proxy/scripts
COPY config-templates   /opt/reverse-proxy/config-templates

COPY static-html        /usr/local/nginx/html

RUN find /usr/local/nginx/html -type d -exec chmod 755 {} +
RUN find /usr/local/nginx/html -type f -exec chmod 644 {} +

RUN find /opt/reverse-proxy/scripts  -type f -exec chmod 755 {} +

ENTRYPOINT ["/opt/reverse-proxy/scripts/entry-point.sh"]

