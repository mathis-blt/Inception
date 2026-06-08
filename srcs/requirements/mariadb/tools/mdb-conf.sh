#!/bin/bash
set -e

DATA_DIR="/var/lib/mysql"

# ÉTAPE 1 : Si la base de données n'existe pas du tout sur le disque
if [ ! -d "$DATA_DIR/${SQL_DATABASE}" ]; then

    echo "Base de données '${SQL_DATABASE}' introuvable. Initialisation..."
    
    # Initialiser les dossiers système si vides
    if [ ! -d "$DATA_DIR/mysql" ]; then
        mysql_install_db --user=mysql --datadir=$DATA_DIR
    fi
    
    echo "Démarrage temporaire de MariaDB..."
    mariadbd-safe --skip-networking &
    
    # Attendre que le serveur réponde
    until mariadb-admin ping &>/dev/null; do
        sleep 1
    done

    echo "Création automatique de la BDD et de l'utilisateur..."
    
    # On crée un fichier temporaire de commandes SQL
    cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # On injecte le fichier. Si root a déjà un pass, on tente avec le pass, sinon sans.
    mariadb -u root < /tmp/init.sql 2>/dev/null || mariadb -u root -p"${SQL_ROOT_PASSWORD}" < /tmp/init.sql 2>/dev/null || true
    rm -f /tmp/init.sql

    echo "Arrêt de l'instance temporaire..."
    mariadb-admin -u root -p"${SQL_ROOT_PASSWORD}" shutdown 2>/dev/null || mariadb-admin -u root shutdown 2>/dev/null || true
    sleep 1
else
    echo "La base de données '${SQL_DATABASE}' existe déjà. Configuration ignorée."
fi

echo "Démarrage normal de MariaDB au premier plan..."
exec mariadbd --user=mysql --datadir=$DATA_DIR