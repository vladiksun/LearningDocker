FROM ubuntu:18.04

ENV TERM=xterm

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	    software-properties-common \
		netcat \
		curl \
		wget \
		libmemcached-tools

ENTRYPOINT ["/bin/sh", "-c", "top"]