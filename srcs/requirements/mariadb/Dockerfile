FROM debian:13.0

RUN apt-get update -y @@ apt-get upgrade -y && apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/mdb-conf.sh /usr/local/bin/mdb-conf.sh

RUN chmod +x /usr/local/bin/mdb-conf.sh

ENTRYPOINT ["/usr/local/bin/mdb-conf.sh"]