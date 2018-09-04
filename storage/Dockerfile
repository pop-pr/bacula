FROM ubuntu:latest    

## Exclude documentation
COPY templates/01_nodoc /etc/dpkg/dpkg.cfg.d/
##

## Set TZDAT to America/Sao_paulo
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
##

## Installs bacula packages
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'postfix postfix/mailname string backup@pop-pr.rnp.br'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'postfix postfix/main_mailer_type string' 'Internet Site'"]
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \    
    bacula-common-mysql \            
    bacula-sd \     
    && apt-get clean && rm -rf /var/lib/apt/lists/*
##

RUN mkdir \
    /docker-entrypoint.d \
    /docker-healthcheck.d \
    /usr/src/bacula \
    /usr/src/bacula/scripts 

# Changes permission 
RUN cd /etc/bacula && chown bacula:bacula *

# Conf's Templates
# COPY templates/bacula-fd.conf /usr/src/bacula/
# COPY templates/bacula-sd.conf /usr/src/bacula/

# Scripts and handlers
COPY scripts/bacula/ /usr/src/bacula/scripts/
VOLUME /etc/bacula
COPY scripts/docker/entrypoint.sh /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.d/entrypoint.sh"]
CMD tail -f /var/log/bacula/bacula.log