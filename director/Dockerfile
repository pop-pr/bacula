FROM ubuntu:latest

RUN apt-get update && apt install -y apt-utils     
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'postfix postfix/mailname string desenvolvimento@pop-pr.rnp.br'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'postfix postfix/main_mailer_type string' 'Internet Site'"]
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bacula-console \    
    bacula-common-mysql \
    bacula-director-mysql \
    bacula-fd \
    bacula-sd \
    openssh-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint.d /usr/src/bacula

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

RUN useradd -s /bin/bash -g root -G sudo -p 0lambda popuser

## WEBACULA

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-curl \
    php-dev \
    php-gd \    
    php-mcrypt \    
    php-mysqlnd \
    sudo 

COPY scripts/ /etc/bacula/scripts/
RUN ["/bin/bash", "-c","./etc/bacula/scripts/installWebBacula.sh"]

## WEBACULA_END

VOLUME /etc/bacula
COPY ./scripts/entrypoint.sh /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]

CMD /etc/init.d/bacula-director start && \
    /etc/init.d/bacula-fd start && \
    /etc/init.d/bacula-sd start && \
    /etc/init.d/ssh start && \
    /etc/init.d/apache2 start && \
    bconsole