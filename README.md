# Bacula - Solução de Backup Empresarial


## O repositório:


O repsitório consiste em scripts, arquivos templates de configuração, Dockerfile e Docker-compose que descrevem 3 serviços:

- Uma máquina docker MYSQL 5.7 que serve como catálogo da máquina diretora.
     
- Uma máquina diretora com dois serviços:

    - Daemon do Bacula-Director, dinamicamente configurado e pronto para se comunicar com o catálogo, além de estar pronto para receber instruções via ansible para configuração dinãmica de novos clientes.
    - O serviço WEB → WEB BACULA, uma GUI para utilizar o console.
         
## Passos para instação:
- Requisitos:
    - Docker engine 17+
    - Docker-compose 2+
- Clone o repositório
- docker-compose up 
    

