FROM python:3.6-alpine

MAINTAINER Brandon Simpkins <brandonsimpkins@gmail.com>

ENV PYTHONUNBUFFERED 1
RUN mkdir -p /opt/fd-supply-services
WORKDIR /opt/fd-supply-services
COPY requirements.txt /opt/fd-supply-services

RUN apk update && \
 apk add curl && \
 apk add postgresql-libs && \
 apk add --virtual .build-deps gcc musl-dev postgresql-dev && \
 python3 -m pip install -r /opt/fd-supply-services/requirements.txt --no-cache-dir && \
 apk --purge del .build-deps

ADD . /opt/fd-supply-services
RUN chmod 755 /opt/fd-supply-services/start-web-container.sh

ENTRYPOINT ["/opt/fd-supply-services/start-web-container.sh"]
