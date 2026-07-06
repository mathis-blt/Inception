FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y mariadb-server

COPY ./requirements/mariadb/conf/99-server.cnf /etc/mysql/mariadb.conf.d/99-server.cnf

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

COPY ./requirements/mariadb/tools/mdb-conf.sh /usr/local/bin/mdb-conf.sh

RUN chmod +x /usr/local/bin/mdb-conf.sh

ENTRYPOINT ["/usr/local/bin/mdb-conf.sh"]