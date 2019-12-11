# POP-PR - Utilizando o docker para subir uma infra-estrutura Bacula.

English version [here](https://github.com/PoP-PR/bacula/blob/master/README-en.md "READ ME!").


O objetivo desse projeto é construir, rodar e instalar o projeto OpenSource Bacula 9 dentro de um ambiente de arquitetura micro-serviço em Docker.

Leia mais sobre o Bacula [aqui](http://http://blog.bacula.org/ "Bacula Org")

## Introdução

Utilize a ferramenta docker-compose e o arquivo docker-compose.yml para subir todos os conteiners.

O projeto consiste em:

- [Director Container](https://hub.docker.com/r/popprrnp/bacula-dir/ "Bacula Director Image")
- [Mysql Catalog Container](https://hub.docker.com/r/popprrnp/bacula-catalog/ "Bacula Catalog Image")
- [Um Dashboard Opcional](https://hub.docker.com/r/popprrnp/bacula-dashboard/ "Bacula Dashboard Image") [(Bacula-web Project)](https://www.bacula-web.org/ "bacula web-Dashboard")
- [Uma GUI opcional](https://hub.docker.com/r/popprrnp/web-bacula-gui/ "Bacula WEB GUI Image") [(Web-Bacula Project)](https://github.com/wanderleihuttel/webacula "Web-bacula Project")
- [Um container Storage opcional](https://github.com/PoP-PR/bacula/blob/master/storage/ "Storage")

## Requirementos

    Docker >= 1.9.0
    Docker Compose >= 1.21.0

## Configurações Adicional de Rede

Você pode modificar o arquivo docker-compose.yml para adicionar ou modificar configurações de rede. Você pode, por exemplo, limitar o catalogo para uma rede default docker e expor os serviços WEB em sua rede interna, contanto que os containers consigam enxergar uns aos outros. Leia mais em [docker-docs](link "docker network docs").

## Subindo o projeto:

Entre no diretório raiz do projeto, onde encontra-se o arquivo docker-compose.yml e rode:
```bash 
docker-compose pull
```
E as imagens serão baixadas/atualizadas.
```bash 
docker-compose up
```
E todos os containers irão começar a rodar.

Para rodar em background:
```bash 
docker-compose start
```
Para parar os containers você pode utilizar Ctrl C se estiverem rodando em primeiro plano, ou então:
```bash 
docker-compose stop
```
## Configuração

### Volumes

Os arquivos de configuração do diretor, ou seja, os arquivos presentes em /etc/bacula/, serão armazenados em um volume de persistência, que segundo diretiva docker-compose (pode ser modificado livremente) fica localizado em $PWD/director/data, caminho relativo ao arquivo docker-compose.yml.

Esse mesmo tipo de configuração foi aplicado ao catalogo, monta-se /var/lib/mysql em $PWD/catalog/data relativo ao docker-compose.yml. 

Recomenda-se fortemente que exista redundância de backup destes volumes, principalmente do catálogo, pois sem ele não será possível continuar a utilização do bacula.

### Bacula Console

Para acessar o console do bacula, você pode abrir uma sessão TTY com o container do diretor e então executar o comando bconsole, como normalmente faria em uma máquina comum, ou configurar um console em uma máquina na mesma rede do diretor e acessa-lo por lá. 

### Bconsole Reload

Após inserir novos recursos ou modificar as configurações do diretor, você deve rodar o comando reload dentro do bconsole, para tanto você pode:

Abrir uma sessão TTY com o container do diretor e então digitar:
```bash 
echo "reload" | bconsole 
```
ou então:
Executar diretamente da linha de comando do host:

```bash 
docker exec -ti bacula-dir bconsole
```

### Bacula Resources

Para fazer modificações na configuração do diretor, ou para adicionar novos clientes/storages, você deve adicionar os arquivos de recurso com a extensão .conf dentro das subpastas do volume de persistencia do diretor. 

O arquivo bacula-director.conf foi modificado para fazer a leitura de todos os arquivos nas subpastas (/storages,/clients,/schedules,/pools, etc) e concatenar seu conteudo na configuração do diretor, isto facilita a adição/remoção de recursos e permite a automação de algumas configurações.

Exemplo:

Para adicionar um novo recurso de pool, ao invés de editar o arquivo bacula-director.conf, você pode criar um arquivo
nome_da_pool.conf dentro da subpasta /pools/ e então recarregar o diretor com o comando 'reload' dentro do bconsole.

Um arquivo exemplo deste recurso poderia ser:

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
Isto serve para todos os recursos, para clientes e storages pode-se automatizar o processo.

### Automatizando a adição de clientes/storages com o Ansible.

[Utilize estas receitas Ansible para realizar a automação completa de adição de clientes/storages.](https://github.com/PoP-PR/ansible-bacula "POP-PR ansible-bacula Project"). 

Com o [Ansible](https://www.ansible.com/ "Official Ansible Page") você pode simplesmente rodar as playbooks e ele garantirá que a configuração da comunicação entre um cliente e o diretor será realizada, além de rodar scripts handlers que irão recarregar o diretor para você. Este é, sem sombras de dúvidas, a melhor maneira de realizar a configuração de novos recursos.

Para aprender mais sobre essa tecnologia, leia a [Documentação Oficial do Ansible](https://docs.ansible.com/ "Ansible Docs").

### Catalogo

O Catálogo é configurado na primeira vez que você roda o compose e cria dois usuários:

bacula|bacula e root|root.

Levanta a base de dados padrão do Catálogo bacula e cria tabelas extras para a GUI Bacula-WEB.

## Suporte

Este projeto e suas imagens são disponibilizados gratuitamente pelo POP-PR da RNP. Sinta-se livre para complementar o projeto e submeter um pull request no GitHub.

## Docker-compose.yml exemplo
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

## Web-Gui e Dashboard:

Os containers com os serviços web utilizam os projetos [bacula-web](https://www.bacula-web.org/ "bacula web-Dashboard") para o Dashboard e [web-bacula](https://github.com/wanderleihuttel/webacula "Web-bacula Project") para a WEB-GUI.

Pode-se mapear as portas no docker-compose.yml ou, se preferível, utilizar o recursos de rede do Docker para dar IP's aos containers. 

Se você não fez modificações ao compose, pode-se acessa-los em: http://localhost:9001/bdashboard and http://localhost:9002/webacula/.

O usuário default do Dashboard é: admin|bacula.

O usuário default do Webacula é: root|bacula.

## Copyright and license

General Public License

## Contribuindo
    Faça um Fork de nosso projeto
    Crie uma branch com sua nova feature (git checkout -b my-new-feature)
    Commite suas mudanças (git commit -am 'Add some feature')
    Empurre para o branch (git push origin my-new-feature)
    Crie um novo Pull Request

## Informação Adicional

* [Frequently Asked Questions](http://www.bacula.org/7.4.x-manuals/en/problems/Bacula_Frequently_Asked_Que.html "FAQ")
* [Docs](http://www.bacula.org/5.2.x-manuals/en/main/main/index.html "Docs")
* [Configuring the director](http://www.bacula.org/5.2.x-manuals/en/main/main/Configuring_Director.html "Director-Docs")
* [Storage Daemon](http://www.bacula.org/5.1.x-manuals/fr/main/main/Storage_Daemon_Configuratio.html "SD-Docs")
* [Volume-Utilities](http://www.bacula.org/5.0.x-manuals/de/utility/utility/Volume_Utility_Tools.html "Volume-utiliies")
