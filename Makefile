NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/maballet/data
ENV_FILE= srcs/.env

#------- colors -------#
GREEN = \033[0;32m]
BLUE  = \033[0;34m]
STD = \033[0m]
#----------------------#


all: $(ENV_FILE) setup
	@echo "$(BLUE)Lancement des conteneurs Docker...$(STD)"
	@docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Inception est opérationnel ! https://maballet.42.fr$(STD)"

$(ENV_FILE):
	echo -e "${BLUE}Le fichier $(ENV_FILE) est absent. Création...${STD}\n"
	touch $(ENV_FILE)
	echo "SQL_DATABASE=wordpress" >> $(ENV_FILE);\
	echo "SQL_USER=maballet" >> $(ENV_FILE);\
	read -p "🔑 Saisir le mot de passe utilisateur MariaDB (SQL_PASSWORD) : " sql_pass;\
	echo "" # Saut de ligne après la saisie masquée;\
	echo "SQL_PASSWORD=$$sql_pass" >> $(ENV_FILE);\
	read -p "🔑 Saisir le mot de passe ROOT MariaDB (SQL_ROOT_PASSWORD) : " sql_root_pass;\
	echo "";\
	echo "SQL_ROOT_PASSWORD=$$sql_root_pass" >> $(ENV_FILE);\
	echo "" >> $(ENV_FILE);\
	echo "WP_TITLE=Inception_maballet" >> $(ENV_FILE);\
	echo "WP_URL=maballet.42.fr" >> $(ENV_FILE);\
	echo "WP_ADMIN_USER=admin_maballet" >> $(ENV_FILE);\
	echo "WP_ADMIN_EMAIL=maballet@student.42.fr" >> $(ENV_FILE);\
	read -p "👑 Saisir le mot de passe ADMIN WordPress (WP_ADMIN_PASSWORD) : " wp_admin_pass;\
	echo "";\
	echo "WP_ADMIN_PASSWORD=$$wp_admin_pass" >> $(ENV_FILE);\
	echo "" >> $(ENV_FILE);\
	echo "WP_USER=touriste" >> $(ENV_FILE);\
	echo "WP_USER_EMAIL=touriste@gmail.com" >> $(ENV_FILE);\
	read -p "👤 Saisir le mot de passe USER secondaire (WP_USER_PASSWORD) : " wp_user_pass;\
	echo "";\
	echo "WP_USER_PASSWORD=$$wp_user_pass" >> $(ENV_FILE);\
	echo -e "\n${GREEN}✅ Fichier $(ENV_FILE) généré avec succès !${STD}";

setup:
	@echo "$(BLUE)Vérification et création des dossiers de volumes...$(STD)"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

down:
	@echo "$(BLUE)Arrêt des conteneurs...$(STD)"
	@docker compose -f $(COMPOSE_FILE) down

clean: down
	@echo "$(BLUE)Nettoyage des images inutilisées...$(STD)"
	@docker system prune -a -f

fclean: down
	@echo "$(BLUE)Nettoyage total (Docker + Volumes physiques)...$(STD)"
	@docker system prune -a --volumes -f
	@sudo rm -rf $(DATA_DIR)/mariadb
	@sudo rm -rf $(DATA_DIR)/wordpress
	@sudo chmod 777 $(DATA_DIR)
	@rm -f $(ENV_FILE)
	@echo "$(GREEN)Tout a été réinitialisé !$(STD)"

re: fclean all

.PHONY: all setup down clean fclean re