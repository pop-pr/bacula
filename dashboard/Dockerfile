FROM ubuntu:xenial

RUN mkdir \
    /docker-entrypoint.d \
    /docker-healthcheck.d \
    /usr/src/bacula 

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    bacula-console \    
    libapache2-mod-php \
    php \
    php-curl \
    php-dev \
    php-gd \    
    php-mcrypt \    
    php-mysqlnd \
    php-sqlite3     

COPY ./scripts /usr/src/bacula/scripts/
COPY ./scripts/entrypoint.sh /docker-entrypoint.d
COPY ./scripts/healthcheck.sh /docker-healthcheck.d

COPY templates/bconsole.conf /usr/src/bacula/

RUN chmod +x /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-healthcheck.d/healthcheck.sh

RUN ["/bin/bash", "-c","./usr/src/bacula/scripts/installDashboard.sh"]

HEALTHCHECK --interval=1m --timeout=10s --start-period=10s --retries=1 CMD ["/docker-healthcheck.d/healthcheck.sh"]

ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]
CMD tail -f /var/log/apache2/access.log