FROM ubuntu:18.04

ENV TERM=xterm

RUN apt-get update
RUN apt-get install netcat -y
RUN apt-get install curl -y
RUN apt-get install libmemcached-tools -y

ENTRYPOINT ["/bin/sh", "-c", "top"]

#FROM alpine:latest
#RUN apk update
#RUN apk add --update netcat-openbsd && rm -rf /var/cache/apk/*
#RUN apk add curl
#RUN apk add libmemcached
#
#ENTRYPOINT ["/bin/sh", "-c", "top"]