FROM ubuntu:18.04

ENV TERM=xterm

RUN apt-get update
RUN apt-get install netcat -y
RUN apt-get install curl -y
RUN apt-get install libmemcached-tools -y

ENTRYPOINT ["/bin/sh", "-c", "top"]
