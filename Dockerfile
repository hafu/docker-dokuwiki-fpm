FROM php:7-fpm-alpine
EXPOSE 9000/tcp

# update packages and install git
RUN apk upgrade --available --no-cache && apk add --no-cache git su-exec

RUN mkdir -p /usr/src/dokuwiki
COPY start.sh /usr/src/dokuwiki

ENV OWNER_UID=1000
ENV OWNER_GID=1000

ENTRYPOINT ["sh"]
CMD ["/usr/src/dokuwiki/start.sh"]
