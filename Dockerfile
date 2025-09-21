FROM alpine:3.22

RUN apk add --no-cache \
    squid \
    apache2-utils \
    bash

RUN mkdir -p /var/cache/squid /var/log/squid /etc/squid/auth \
    && chown -R squid:squid /var/cache/squid /var/log/squid /etc/squid/auth \
    && chmod 755 /var/cache/squid /var/log/squid

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENV SQUID_USERNAME=""
ENV SQUID_PASSWORD=""

EXPOSE 3128

ENTRYPOINT ["/entrypoint.sh"]
