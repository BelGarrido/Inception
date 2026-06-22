# Developer Documentation

## Environment Setup From Scratch

Before building the project, make sure the machine has the required tools installed:

- Docker
- Docker Compose
- GNU Make

Also ensure the local domain resolves to the machine itself by adding this line to `/etc/hosts`:

- `127.0.0.1 anagarri.42.fr`

The project expects a configuration file at `srcs/.env`. Create it by copying `srcs/template.env` and filling in the values for:

- `DOMAIN_NAME`
- MariaDB settings: `MARIADB_DATABASE`, `MARIADB_USER`, `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD`
- WordPress database settings: `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`
- WordPress site and account settings: `WORDPRESS_TITLE`, `WORDPRESS_ADMIN_USER`, `WORDPRESS_ADMIN_PASSWORD`, `WORDPRESS_ADMIN_EMAIL`, `WORDPRESS_USER`, `WORDPRESS_USER_PASSWORD`, `WORDPRESS_USER_EMAIL`

Do not commit the filled `.env` file. It contains secrets used by the containers at runtime.

## Build and Launch

From the repository root, the main workflow is handled by the Makefile:

- `make all` creates the host data directories and launches the stack with a build.
- `make build` builds the images only.
- `make up` starts the already built stack.
- `make stop` pauses the running containers.
- `make clean` tears down the containers and network.
- `make fclean` removes the stack, images, and the persistent local data directory.

The Compose file used by the Makefile is `srcs/docker-compose.yml`.

## Container and Volume Management

Useful Docker commands when working on the project:

- `docker compose -f srcs/docker-compose.yml ps` to see the current service state.
- `docker compose -f srcs/docker-compose.yml logs -f` to follow container logs.
- `docker compose -f srcs/docker-compose.yml down` to stop and remove containers and the network.
- `docker compose -f srcs/docker-compose.yml down -v` to remove named volumes as well.
- `docker compose -f srcs/docker-compose.yml up -d --build` to rebuild and relaunch the full stack.

The Makefile already wraps the standard lifecycle, so using it is the preferred path.

## Data Storage and Persistence

The persistent data for the project is stored on the host in these bind-mounted paths:

- `/home/anagarri/data/mariadb`
- `/home/anagarri/data/wp`

MariaDB stores its database files in `/home/anagarri/data/mariadb`, and WordPress stores its web files in `/home/anagarri/data/wp`. These directories are mounted into the containers so data survives container recreation.

If you remove those directories or run `make fclean`, the stored data is lost and the stack will need to reinitialize on the next start.
