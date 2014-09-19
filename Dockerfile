FROM pebbles/cedarish
MAINTAINER krisrang "mail@rang.ee"

RUN mkdir /scripts
ADD ./scripts/ /scripts
RUN cd /scripts && ./build.sh

EXPOSE 22
VOLUME ["/tmp/pebble-repos"]
VOLUME ["/tmp/pebble-cache"]
ENTRYPOINT ["/scripts/run"]
