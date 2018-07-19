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

# Creates director's definition sub-directories
RUN cd /etc/bacula/ && mkdir \
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
COPY templates/bacula-dir.conf /etc/bacula/
COPY templates/bacula-fd.conf /etc/bacula/
COPY templates/bacula-sd.conf /etc/bacula/
COPY templates/bconsole.conf /etc/bacula/
COPY templates/director_client.conf /etc/bacula/clients/
COPY templates/director_storage.conf /etc/bacula/storages/
COPY templates/file_sets.conf /etc/bacula/file_sets/
COPY templates/job_defs.conf /etc/bacula/job_defs/
COPY templates/jobs.conf /etc/bacula/jobs/
COPY templates/messages.conf /etc/bacula/messages/
COPY templates/pools.conf /etc/bacula/pools/
COPY templates/schedules.conf /etc/bacula/schedules/

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

CMD /etc/init.d/bacula-director start && \
    /etc/init.d/bacula-fd start && \
    /etc/init.d/bacula-sd start && \
    /etc/init.d/ssh start && \
    /etc/init.d/apache2 start && \
    bconsole