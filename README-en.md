# POP-PR - Bacula on Docker Project

Você pode ler esse documento em português [aqui](https://github.com/PoP-PR/bacula/blob/master/README.pt-br.md "Leia-me!").
The main goal of this project is build, run and deploy the OpenSource Bacula 9+ project inside a docker micro-service environment. You can read more about bacula [here](http://http://blog.bacula.org/ "Bacula Org")

## Introduction
The docker-compose tool and the provided docker-compose file must be used in order to start all containers.

The project consists in:

[Director Container](https://hub.docker.com/r/popprrnp/bacula-dir/ "Bacula Director Image")
[Mysql Catalog Container](https://hub.docker.com/r/popprrnp/bacula-catalog/ "Bacula Catalog Image")
[An optional Dashboard](https://hub.docker.com/r/popprrnp/bacula-dashboard/ "Bacula Dashboard Image") [(Bacula-web Project)](https://www.bacula-web.org/ "bacula web-Dashboard")
[An optional GUI](https://hub.docker.com/r/popprrnp/web-bacula-gui/ "Bacula WEB GUI Image") [(Web-Bacula Project)](https://github.com/wanderleihuttel/webacula "Web-bacula Project")

## Requirements

The following components are required for this setup:

    Docker >= 1.9.0
    Docker Compose >= 1.21.0

## Networking

You can modify the docker-compose.yml file to add Network configuration, presuming the containers can see each other. You can encapsulate the catalog in a default docker network and create valid interfaces for the web-services, if you want to.

## Starting the setup

docker-compose pull

When this has successfully completed you can start the containers:

docker-compose up

To run all containers in the background:

docker-compose start

To stop all containers one can simple hit ^C if they run in the foreground, or when running the background:

docker-compose stop

## Configuration

### Volumes

Configuration files for the director are stored inside $PWD/director/data (Relative to docker-compose.yml location), this is the volume that represents /etc/bacula. You can create this directory ($PWD/director/data) by hand or use the tree provided with this project. The [bacula-director.conf](https://github.com/PoP-PR/bacula/blob/master/director/templates/bacula-dir.conf "bacula-director.conf file") file has been modified so new conf (such as client for example) are stored in /data/clients/client-XYZ.conf, the same for pools, storages, schedules and so on. 

Catalog data persistence (AKA mysql datafiles) follows the same procedure. 
All data inside /var/lib/mysql is stored in $PWD/catalog/data (Relative to docker-compose.yml location).

### Bacula

In order to apply new configuration to the director, you should reload bacula console. 

To do that you can:

#### The Classic way:
Get to the director TTY and type: 
```bash 
echo "reload" | bconsole 
```


#### The Docker way:
```bash 
docker exec -ti bacula-dir bconsole
```


#### The AWESOME way:
[Use these Ansible roles to automate client/storage configuration/communication](https://github.com/PoP-PR/ansible-bacula "POP-PR ansible-bacula Project"). 

Simply run the playbook, grab a cup of coffee and behold the automated way of doing configuration!

### Bacula clients and Storages.

As said before, you can configure bacula-clients by adding resources to the director client's folder, but the best way of doing that is with [Ansible](https://www.ansible.com/ "Official Ansible Page"). To learn more about this technology and how to use it, visit our [ansible-bacula project on github](https://github.com/PoP-PR/ansible-bacula "POP-PR ansible-bacula Project") and read some of the [Official Ansible Documentation](https://docs.ansible.com/ "Ansible Docs").

### Catalog

Default bacula database + Bacula-web database
Default passwords for mysql are: root|root and bacula|bacula

## Support

These images are provided free of charge by POP-PR RNP. Various security measures (such as TLS)
have not been implemented or added in these images. Feel free to modify them and create a pull request.

## Sample docker-compose.yml
You can see the raw file [here](https://raw.githubusercontent.com/PoP-PR/bacula/master/docker-compose.yml "Compose Raw File").
```yml 
version: '2.3'
services:  
  catalog:
    container_name: bacula_catalog
    image: popprrnp/bacula-catalog:latest
    volumes:
      - ./catalog/data:/var/lib/mysql      
    networks: 
      default:
    restart: always
  director:
    container_name: bacula_director
    image: popprrnp/bacula-dir:latest
    tty: true
    volumes:
      - type: bind
        source: ./director/data
        target: /etc/bacula
    networks:      
      default:    
    depends_on: 
      - catalog
    restart: always
  webacula:
    container_name: webacula
    image: popprrnp/web-bacula-gui:latest
    tty: true
    ports:
      - 9002:80      
    networks:      
      default:    
    depends_on: 
      - director
      - catalog
    restart: always
  bdashboard:
    container_name: bdashboard
    image: popprrnp/bacula-dashboard:latest
    tty: true
    ports:
      - 9001:80    
    networks:      
      default:    
    depends_on: 
      - director
      - catalog
    restart: always
networks:  
  default:
```

## Web-Gui and Dashboard:

Provided containers uses the [bacula-web](https://www.bacula-web.org/ "bacula web-Dashboard") for the Dashboard and [web-bacula](https://github.com/wanderleihuttel/webacula "Web-bacula Project") for the WEB-GUI. you can map the ports in docker-compose file as you want, or use Network features to give them Ipv4 addresses.

If you used the provided docker-compose file you can access them at http://localhost:9001/bdashboard and http://localhost:9002/webacula/.

Issues: 

If you are dealing with PDO exceptions in the web-bacula interface, make sure to get to the catalog TTY and run    30_createBaculaWebTables.sh -p < password >  and 40_createWeBaculaACL.sh -p < password >  these scripts are inside /docker-entrypoint-initdb.d/

## Copyright and license

General Public License

## Contributing
    Fork it
    Create your feature branch (git checkout -b my-new-feature)
    Commit your changes (git commit -am 'Add some feature')
    Push to the branch (git push origin my-new-feature)
    Create new Pull Request