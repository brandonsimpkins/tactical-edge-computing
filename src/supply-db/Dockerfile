FROM postgres:9.6.9-alpine

MAINTAINER Brandon Simpkins <brandonsimpkins@gmail.com>

# https://stackoverflow.com/questions/30848670/how-to-customize-the-configuration-file-of-the-official-postgresql-docker-image

RUN apk update

COPY docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/

RUN find /docker-entrypoint-initdb.d/ -name '*.sh' -exec chmod 755 {} +
RUN find /docker-entrypoint-initdb.d/ -name '*.sql' -exec chmod 644 {} +

COPY scripts /opt/supply-db/scripts
RUN find /opt/supply-db/scripts -type f -exec chmod 755 {} +

