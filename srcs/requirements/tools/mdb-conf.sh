#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -y mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 2. Vérifier si la base de données existe déjà (évite de réinitialiser au redémarrage de la VM)
if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then

    # Initialiser le répertoire de données de MariaDB s'il est vide
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Démarrer temporairement MariaDB en arrière-plan pour créer les utilisateurs
    mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    echo "Base de données MariaDB initialisée avec succès !"
fi

# 3. Passer le relais au processus principal de MariaDB pour qu'il tourne au premier plan
# (C'est ce qui maintient ton conteneur Docker allumé)
exec mariadbd --user=mysql