FROM nginx:1.15-alpine

MAINTAINER Brandon Simpkins <brandonsimpkins@gmail.com>

COPY nginx.conf /etc/nginx/nginx.conf

# TODO need to add these onto the host later into the process
COPY bender-public.pem  /etc/nginx/certs/server.crt
COPY bender-private.pem /etc/nginx/certs/server.key


