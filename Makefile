EXEC = sudo docker compose
SRC = -f srcs/docker-compose.yml

DATA_DIR_M = /home/anagarri/data/mariadb
DATA_DIR_W = /home/anagarri/data/wp

# Descomentamos y añadimos TODAS las reglas virtuales
.PHONY: all stop clean fclean re create_dirs

all: create_dirs
	$(EXEC) $(SRC) up -d --build

create_dirs:
	mkdir -p $(DATA_DIR_M)
	mkdir -p $(DATA_DIR_W)

build:
	$(EXEC) $(SRC) build
up:
	$(EXEC) $(SRC) up -d
stop:
	$(EXEC) $(SRC) stop

clean:
	$(EXEC) $(SRC) down

fclean:
	$(EXEC) $(SRC) down -v --rmi all
	@if [ -d "/home/$(USER)/data" ]; then \
		sudo rm -rf /home/$(USER)/data; \
		echo "Local data deleted."; \
	fi

re: fclean all
