EXEC = docker compose
SRC = -f srcs/docker-compose.yml

DATA_DIR_M = /home/anaigd/data/mariadb
DATA_DIR_W = /home/anaigd/data/wp

# Descomentamos y añadimos TODAS las reglas virtuales
.PHONY: all stop clean fclean re create_dirs

all: create_dirs
	$(EXEC) $(SRC) up -d --build

create_dirs:
	mkdir -p $(DATA_DIR_M)
	mkdir -p $(DATA_DIR_W)

stop:
	$(EXEC) $(SRC) stop

clean:
	$(EXEC) $(SRC) down

fclean:
	$(EXEC) $(SRC) down -v --rmi all
	@if [ -d "/home/anaigd/data" ]; then \
		rm -rf /home/anaigd/data; \
		echo "Datos locales eliminados con éxito."; \
	fi

re: fclean all