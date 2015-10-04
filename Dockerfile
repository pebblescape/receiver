FROM pebbles/cedarish
MAINTAINER krisrang "mail@rang.ee"

RUN mkdir /scripts
ADD ./scripts/ /scripts
RUN cd /scripts && ./build.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22
VOLUME ["/tmp/pebble-repos"]
VOLUME ["/tmp/pebble-cache"]
CMD ["/usr/bin/supervisord"]
