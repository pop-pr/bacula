# POP-PR - Bacula on Docker Project

Você pode ler esse documento em português [aqui](https://github.com/PoP-PR/bacula/blob/master/README.md "Leia-me!").


The main goal of this project is to build, run and deploy the OpenSource Bacula 9+ project inside a docker micro-service environment. You can read more about bacula [here](http://http://blog.bacula.org/ "Bacula Org")

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

More in [docker-docs](link "Docker Networks").
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

Configuration files for the director are stored inside $PWD/director/data (Relative to docker-compose.yml location),this is the volume that represents /etc/bacula. You can create this directory ($PWD/director/data) by hand or use the tree provided with this project. The [bacula-director.conf](https://github.com/PoP-PR/bacula/blob/master/director/templates/bacula-dir.conf "bacula-director.conf file") file has been modified so new conf (such as client for example) are stored in /data/clients/client-XYZ.conf, the same for pools, storages, schedules and so on. 

Catalog data persistence (AKA mysql datafiles) follows the same procedure. 
All data inside /var/lib/mysql is stored in $PWD/catalog/data (Relative to docker-compose.yml location).

### Bacula Console

In order to access the bconsole, you can open a TTY session with the director's container and then run "bconsole", as you normally would do. 

You can also configure an instance of the bconsole program in any machine on the same network.

### Bconsole Reload

In order to apply new configuration to the director, you should reload bacula console. 

To do that you can:
 
Get to the director TTY and type: 
```bash 
echo "reload" | bconsole 
```
or
```bash 
docker exec -ti bacula-dir bconsole
```

### Bacula Resources

To make changes to the director's configuration, or to add new clients / storages, you must add the resource files with the .conf extension within the subdirectories of the director's persistence volume.

The bacula-director.conf file has been modified to read all the files in the subfolders (/ storages, / clients, / schedules, / pools, etc) and concatenate its contents in the director's configuration, this facilitates the addition / removal of features and allows the automation of some configurations.

Example:

To add a new pool resource, instead of editing the bacula-director.conf file, you can create a file
name_pool.conf into the subfolder / pools / and then reload the director with the 'reload' command inside the bconsole.

An example file of this resource could be:

```conf
Pool {
  Name = example_pool
  Pool Type = Backup
  Recycle = yes                       # Bacula can automatically recycle Volumes
  AutoPrune = yes                     # Prune expired volumes
  Volume Retention = 365 days         # one year
  Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
  Maximum Volumes = 100
  Label Format = "example_vol-"       # Limit number of Volumes in Pool
}
```
The same goes for every resource, for clients and storages the process can be automated.

### The AWESOME way: Automating Client/Storage configuration with Ansible.

[Use these Ansible roles to automate client/storage configuration/communication](https://github.com/PoP-PR/ansible-bacula "POP-PR ansible-bacula Project"). 

With [Ansible](https://www.ansible.com/ "Official Ansible Page") you can simply run playbooks and it will ensure that the configuration and communication between a client and the director will be performed, as well as running handlers which will reload the director. This is, without a doubt, the best way to configure new resources.

Simply run the playbook, grab a cup of coffee and behold the automated way of doing configuration!

To learn more about this amazing technology [read the docs](https://docs.ansible.com/ "Ansible Docs").


### Catalog

The Catalog is configured the first time you run the compose and creates two users:

bacula | bacula and root | root.

Raises the default bacula Catalog database and creates extra tables for the Bacula-WEB GUI.

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

## Copyright and license

General Public License

## Contributing
    Fork it
    Create your feature branch (git checkout -b my-new-feature)
    Commit your changes (git commit -am 'Add some feature')
    Push to the branch (git push origin my-new-feature)
    Create new Pull Request
