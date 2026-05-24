*This project has been created as part of the 42 curriculum by anagarri*

# Inception

## Description

Inception is a 42 project focused on building a small microservices infrastructure with Docker.
The mandatory stack is:

- NGINX with TLSv1.2 or TLSv1.3 only
- WordPress with php-fpm (without NGINX in the same container)
- MariaDB (without NGINX)

The project is developed and tested inside a Virtual Machine, while the services themselves run as isolated containers.

### Why this architecture

The core design choices are:

- Separation of responsibilities (Single Responsibility Principle): NGINX as gateway, WordPress as PHP processor, MariaDB as database
- Isolation: if one service fails, others can continue
- Reproducibility: custom Dockerfiles and explicit service configuration
- Persistence: data must survive container recreation
- Security posture: only NGINX is exposed externally; WordPress and MariaDB stay internal

### Docker usage in this project

- Dockerfile: installs and configures each service
- docker-compose.yml: orchestrates multi-container setup (services, network, volumes, env propagation)
- .env: central source of truth for project configuration and sensitive values
- Entrypoint scripts: runtime setup logic during container start

Traffic flow:

User -> NGINX -> WordPress (php-fpm) -> MariaDB

Only NGINX maps host port 443. WordPress and MariaDB remain internal to the Docker network.

## Infrastructure Snapshot

- Project root includes Makefile and srcs/
- srcs contains .env, docker-compose.yml, and requirements per service
- Service directories include Dockerfile, conf, and tools

Key service ideas from my notes:

- MariaDB must listen on all interfaces inside container networking context (bind-address 0.0.0.0)
- NGINX must stay in foreground as PID 1 (daemon off)
- NGINX and WordPress must share website files so NGINX can resolve requested PHP paths before forwarding
- php-fpm pool and main configs are loaded from php configuration directories, while wp-config.php belongs in WordPress web root

## Comparisons

### Virtual Machines vs Docker

Virtual Machine in this project:

- Required environment for development/evaluation
- Full guest OS context

Docker in this project:

- Runs isolated services sharing the host kernel
- Faster startup and easier reproducibility
- Better fit for microservice-style separation (NGINX, WordPress, MariaDB)

My notes also emphasize consistency (same behavior across environments), elasticity (fast startup), and isolation/security as practical reasons containers are preferred for service delivery.

### Secrets vs Environment Variables

From my notes, sensitive values are handled through .env and injected via docker-compose.yml.

Environment variables (.env + compose propagation):

- Keep credentials out of hardcoded compose content
- Are injected into container environment at startup
- Should be ignored in git repositories

Secrets (concept in my notes via “Secrets Management” prompts):

- Refer to protected sensitive values (passwords, credentials)
- In my current documented implementation, this role is fulfilled through .env-based environment variables

### Docker Network vs Host Network

Docker bridge network in this project:

- Planned as a dedicated project network (example: inception_network)
- Provides internal DNS resolution by service/container name
- Keeps internal services private unless explicitly published

Host network:

- Explicitly forbidden by project constraints
- Breaks the intended isolation model used in this architecture

### Docker Volumes vs Bind Mounts

From my notes, both ideas appear during learning, with subject constraints highlighted.

Named volumes:

- Docker-managed volume abstraction
- Required by the project requirements section in my notes
- Used in compose with aliases and explicit naming

Bind mounts:

- Direct host-path mapping into containers
- Mentioned in my notes when discussing persistence paths like /home/login/data

The documented persistence objective is that data remains outside container lifecycle and is stored in host-visible paths, including:

- /home/login/data/mariadb
- /home/login/data/wordpress

## Instructions

### 0. Project Initialization (First Run)

Use this quick sequence to initialize the project environment before the normal build/run cycle:

1. Ensure your 42 domain points to localhost in `/etc/hosts`:

```text
127.0.0.1 anagarri.42.fr
```

2. Prepare persistence directories required by the project:

```bash
sudo mkdir -p /home/login/data/mariadb /home/login/data/wordpress
```

3. Make sure `.env` exists inside `srcs/` with your database and WordPress variables.

4. Initialize and start the infrastructure from the project root using your Makefile:

```bash
make all
```

5. If your Makefile separates build and startup, run:

```bash
make build
make up
```

6. Validate that containers are up and HTTPS is reachable at:

```text
https://anagarri.42.fr
```

### 1. Foundation

1. Set up VM with latest stable Debian or Alpine (as required by subject).
2. Install Docker and Docker Compose.
3. Add user to docker group to avoid sudo on every command:

```bash
sudo usermod -aG docker ${USER}
```

4. Create project directory structure under srcs/ and requirements/.
5. Configure host mapping:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1 anagarri.42.fr
```

### 2. Configuration Logic

1. Create .env with database names/users/passwords.
2. Keep .env out of public repository (.gitignore).
3. Create Makefile in repository root.
4. Plan bridge network name (for example inception_network).

### 3. Build Services

Suggested order:

1. MariaDB
2. NGINX
3. WordPress + php-fpm

MariaDB tasks:

- Build Dockerfile
- Initialize DB and WordPress user in entrypoint
- Ensure network listening configuration allows inter-container access

NGINX tasks:

- Build Dockerfile
- Generate self-signed SSL certificate
- Configure TLS-only listener and forwarding logic

WordPress + php-fpm tasks:

- Build Dockerfile
- Install wp-cli tools
- Configure wp-config.php with environment values
- Ensure php-fpm listens on port 9000

#### Recipe for Dockerfile
```dockerfile
FROM <image> - this specifies the base image that the build will extend.
WORKDIR <path> - this instruction specifies the "working directory" or the path in the image where files will be copied and commands will be executed.
COPY <host-path> <image-path> - this instruction tells the builder to copy files from the host and put them into the container image.
RUN <command> - this instruction tells the builder to run the specified command.
ENV <name> <value> - this instruction sets an environment variable that a running container will use.
EXPOSE <port-number> - this instruction sets configuration on the image that indicates a port the image would like to expose.
USER <user-or-uid> - this instruction sets the default user for all subsequent instructions.
CMD ["<command>", "<arg1>"] - this instruction sets the default command a container using this image will run.
```

### 4. Integrate with docker-compose.yml

1. Connect all services to the chosen bridge network.
2. Attach persistence volumes.
3. Set dependencies between services.
4. Configure FastCGI handoff from NGINX to WordPress.

### 5. Build/Run Lifecycle

The root Makefile is expected to provide at least:

- all
- build
- up
- down
- fclean

Use those targets to build and run the stack through docker-compose.yml.

### 6. Verification Checklist

- Persistence test: restart stack and verify WordPress data still exists
- Security test: MariaDB should not be directly reachable from host
- No tail -f hacks
- Reboot test: infrastructure comes back correctly

## Usage Examples

Examples documented during learning/debugging:

Create a network manually before attaching containers:

```bash
docker network create inception_net
```

Inspect a running container filesystem:

```bash
docker exec -it <container_name> bash
```

Extract MariaDB config from a temporary container:

```bash
docker pull mariadb:latest
docker run -d --name mi_mariadb -e MYSQL_ROOT_PASSWORD=root_pass mariadb:latest
docker cp mi_mariadb:/etc/mysql/mariadb.conf.d/50-server.cnf ./srcs/requirements/mariadb/conf/
docker rm -f mi_mariadb
```

Build custom image from Dockerfile context:

```bash
docker build -t mi_mariadb_personalizada .
```

## Feature List

- Multi-container architecture with isolated roles
- TLS termination at NGINX (HTTPS entrypoint)
- Internal service communication through Docker networking and DNS
- Persistent storage strategy for WordPress and MariaDB data
- Environment-driven configuration flow (.env -> compose -> container -> entrypoint)
- Service startup orchestration via docker-compose.yml

## Technical Choices

- NGINX reverse proxy as single exposed edge
- WordPress with php-fpm on internal port 9000
- MariaDB internal service on port 3306
- ENTRYPOINT scripts for runtime setup and PID 1 lifecycle control
- Exec pattern in entrypoint scripts to pass signals correctly
- Keep NGINX master config intact and add server block in modular conf path
- Foreground process strategy so container lifecycle follows service lifecycle

## Defense Notes and Open Questions to Master

Topics highlighted in my documentation for defense preparation:

- PID 1 behavior, signal handling, zombie reaping
- COPY vs ADD
- ENTRYPOINT vs CMD
- Docker layers and build cache behavior
- EXPOSE vs published ports
- Alpine vs Debian tradeoffs
- depends_on meaning (start order vs readiness)
- Port conflict scenarios
- Why network host is forbidden
- Why latest tag is forbidden (reproducibility)

## Resources

### References captured in my notes

- https://hub.docker.com/_/wordpress
- https://www.cloudflare.com/es-es/learning/cdn/glossary/reverse-proxy/

### How AI was used

In this repository workstream, AI was used for documentation tasks:

- Reorganizing multiple Markdown notes into one coherent README structure
- Rewriting for clarity while preserving the original ideas and constraints
- Keeping technical explanations and personal project context intact