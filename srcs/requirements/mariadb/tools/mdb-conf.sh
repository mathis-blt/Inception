#!/bin/sh
set -e

DATA_DIR="/var/lib/mysql"

# if there is no database yet
if [ ! -d "$DATA_DIR/${SQL_DATABASE}" ]; then

    echo "data base '${SQL_DATABASE}' missing. Initialisation..."
    
    # initialise system folders if empty
    if [ ! -d "$DATA_DIR/mysql" ]; then
        mysql_install_db --user=mysql --datadir=$DATA_DIR
    fi

    echo "temporary launch of MariaDB..."
    mariadbd-safe --skip-networking &
    PID=$!

    # wait for the server to respond
    until mariadb-admin ping > /dev/null 2>&1; do
        sleep 1
    done

    echo "BDD and user automatic creation..."
    
    # temporary file of SQL comands
    cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # file is added, if root has the rights, then it's perfect, if not, we try anyway
    mariadb -u root < /tmp/init.sql 2>/dev/null || mariadb -u root -p"${SQL_ROOT_PASSWORD}" < /tmp/init.sql 2>/dev/null || true
    rm -f /tmp/init.sql

    echo "temporary instance down..."
    mariadb-admin -u root -p"${SQL_ROOT_PASSWORD}" shutdown 2>/dev/null || mariadb-admin -u root shutdown 2>/dev/null || true
    wait $PID
else
    echo "data base '${SQL_DATABASE}' already exist. Configuration ignored."
fi

echo "Normal launch of mariadb at first plan..."
exec mariadbd --user=mysql --datadir=$DATA_DIR