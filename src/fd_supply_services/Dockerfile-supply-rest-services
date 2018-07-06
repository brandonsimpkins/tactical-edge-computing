FROM python:3.6-alpine

MAINTAINER Brandon Simpkins <brandonsimpkins@gmail.com>

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
COPY requirements.txt /code/

RUN apk update && \
 apk add postgresql-libs && \
 apk add --virtual .build-deps gcc musl-dev postgresql-dev && \
 python3 -m pip install -r /code/requirements.txt --no-cache-dir && \
 apk --purge del .build-deps

ADD . /code/
