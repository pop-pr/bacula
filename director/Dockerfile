FROM ubuntu:latest    

## Exclude documentation
COPY templates/01_nodoc /etc/dpkg/dpkg.cfg.d/
##

## Set TZDAT to America/Sao_paulo
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
##

## Installs bacula packages
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'postfix postfix/mailname string desenvolvimento@pop-pr.rnp.br'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'postfix postfix/main_mailer_type string' 'Internet Site'"]
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bacula-console \    
    bacula-common-mysql \
    bacula-director-mysql \
    bacula-fd \
    bacula-sd \     
    && apt-get clean && rm -rf /var/lib/apt/lists/*
##

RUN mkdir \
    /docker-entrypoint.d \
    /docker-healthcheck.d \
    /usr/src/bacula 
    

# Creates director's definition sub-directories
RUN cd /usr/src/bacula/ && mkdir \
    clients \
    file_sets \
    jobs \
    job_defs \
    local_storage \
    messages \
    pools \
    schedules \
    scripts \
    storages 

# Changes permission 
RUN cd /etc/bacula && chown bacula:bacula *
# Copies template files
COPY templates/bacula-dir.conf /usr/src/bacula/
COPY templates/bacula-fd.conf /usr/src/bacula/
COPY templates/bacula-sd.conf /usr/src/bacula/
COPY templates/bconsole.conf /usr/src/bacula/
COPY templates/director_client.conf /usr/src/bacula/clients/
COPY templates/director_storage.conf /usr/src/bacula/storages/
COPY templates/file_sets.conf /usr/src/bacula/file_sets/
COPY templates/job_defs.conf /usr/src/bacula/job_defs/
COPY templates/jobs.conf /usr/src/bacula/jobs/
COPY templates/messages.conf /usr/src/bacula/messages/
COPY templates/pools.conf /usr/src/bacula/pools/
COPY templates/schedules.conf /usr/src/bacula/schedules/
##

## WEBACULA
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-curl \
    php-dev \
    php-gd \    
    php-mcrypt \    
    php-mysqlnd     

COPY scripts/ /usr/src/bacula/scripts/
RUN ["/bin/bash", "-c","./usr/src/bacula/scripts/installWebBacula.sh"]
##

VOLUME /etc/bacula

COPY ./scripts/entrypoint.sh /docker-entrypoint.d
COPY ./scripts/healthcheck.sh /docker-healthcheck.d
RUN chmod +x /docker-entrypoint.d/entrypoint.sh
RUN chmod +x /docker-healthcheck.d/healthcheck.sh

HEALTHCHECK --interval=1m --timeout=10s --start-period=10s --retries=1 CMD ["/docker-healthcheck.d/healthcheck.sh"]

ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]

CMD tail -f /var/log/bacula/bacula.log