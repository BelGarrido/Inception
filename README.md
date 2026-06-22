*This project has been created as part of the 42 curriculum by anagarri*

<p align="center">
    <img alt="Docker" src="https://img.shields.io/badge/Docker-%232496ED?style=for-the-badge&logo=docker&logoColor=white" />&nbsp;
    <img alt="Docker Compose" src="https://img.shields.io/badge/Docker%20Compose-%231DB7ED?style=for-the-badge&logo=docker&logoColor=white" />&nbsp;
    <img alt="NGINX" src="https://img.shields.io/badge/NGINX-%23009639?style=for-the-badge&logo=nginx&logoColor=white" />&nbsp;
    <img alt="WordPress" src="https://img.shields.io/badge/WordPress-%231877F2?style=for-the-badge&logo=wordpress&logoColor=white" />&nbsp;
    <img alt="MariaDB" src="https://img.shields.io/badge/MariaDB-%23F29111?style=for-the-badge&logo=mariadb&logoColor=white" />&nbsp;
</p>

# Inception

## Description

Inception is a 42 School project focused on system administration and microservices infrastructure design. The goal of this project is to build a robust, multi-container infrastructure completely from scratch using Docker, Docker Compose, and custom Dockerfiles, running inside a dedicated Virtual Machine.

### The Mandatory Stack
The infrastructure consists of the following isolated services:
- **NGINX**: Acting as the secure entry point, configured with TLSv1.2 or TLSv1.3 only.
- **WordPress**: Running with `php-fpm` to process PHP scripts, completely isolated without NGINX in its container.
- **MariaDB**: The relational database management system, completely isolated without NGINX.

### Project Architectural Design Choices
The architecture follows strict system engineering and software design principles:
- **Separation of Responsibilities (Single Responsibility Principle)**: Each container runs exactly one process (NGINX as the gateway, WordPress as the PHP engine, and MariaDB as the database).
- **Isolation and Security**: Services communicate via a dedicated private network. If one service fails, the others remain unaffected. Only NGINX is exposed to the host machine via port 443; WordPress (port 9000) and MariaDB (port 3306) remain strictly internal.
- **Reproducibility**: No pre-built official images are allowed (except for the base OS). Every service is built from a custom `Dockerfile` using Debian/Alpine.
- **Persistence**: Application data and database files are designed to survive container recreation and deletion by mapping them to specific persistence structures.

---

## Technical Comparisons & Design Analysis

### Virtual Machines vs Docker
- **Virtual Machines**: Emulate an entire hardware stack, including a full Guest Operating System, kernel, and virtual drivers. In this project, the VM provides the underlying isolated development and evaluation environment. It is resource-heavy but provides absolute kernel-level isolation.
- **Docker (Containers)**: Containers run as isolated processes directly on the Host OS kernel, sharing its resources. They do not require a guest OS, making them extremely lightweight, fast to boot, and highly portable. This model fits perfectly for microservices where consistency and rapid scaling are needed.

### Secrets vs Environment Variables
- **Environment Variables**: Dynamic values injected into the container system at startup. They allow us to control configuration without hardcoding values in the source code. In this project, they are defined in a `.env` file and propagated via Docker Compose.
- **Secrets Management**: Refers to secure mechanisms specifically designed to store sensitive data (like passwords, API keys, or certificates) encrypted at rest and in transit. In our current architecture, this role is fulfilled by strict environment variable propagation via a `.env` file that is ignored by Git (`.gitignore`) to prevent credential leaks.

### Docker Network vs Host Network
- **Docker Bridge Network**: Creates an isolated private network (`inception_network`) managed by Docker. Containers get internal IPs and can communicate with each other using their service names as DNS hostnames. This keeps internal components invisible to the outside world.
- **Host Network**: Removes the isolation between the container and the Docker host, making the container share the host’s networking namespace directly. This approach is explicitly forbidden by the project rules as it breaks the isolation paradigm and security model.

### Docker Volumes vs Bind Mounts
- **Docker Named Volumes**: Storage abstractions completely managed by Docker within its internal subsystem (`/var/lib/docker/volumes/`). They are safer, decoupled from the host's directory structure, and are the standard requirement for data persistence in this project.
- **Bind Mounts**: A direct link to an absolute path on the host filesystem (e.g., `/home/login/data`). While flexible for development, they depend on the host's specific directory hierarchy and permission structures. For this project, data persistence paths are directed to `/home/anagarri/data/mariadb` and `/home/anagarri/data/wordpress`.

The documented persistence objective is that data remains outside container lifecycle and is stored in host-visible paths, including:

- /home/login/data/mariadb
- /home/login/data/wordpress

---

## Docker Infrastructure Snapshot

The structural architecture of this repository ensures that configurations are fully automated:
- **Dockerfile**: Defines the installation layers, package management, and system prerequisites for each service.
- **docker-compose.yml**: Orchestrates the whole stack, establishing dependencies, private network setups, and volume bindings.
- **Entrypoint Scripts**: Manage runtime logic, environment variable interpolation, and system preparation tasks right before the main daemon claims PID 1.

```text
Nombre_del_Proyecto/
├── docker-compose.yml
└── srcs/
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/entrypoint.sh
        ├── nginx/
        └── wordpress/
```

###Traffic flow:

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


## Instructions

### 0. Project Initialization (First Run)

Use this quick sequence to initialize the project environment before the normal build/run cycle:

1. Ensure your 42 domain points to localhost in `/etc/hosts`:

```text
127.0.0.1 anagarri.42.fr
```

2. Make sure `.env` exists inside `srcs/` with your database and WordPress variables.

3. Initialize and start the infrastructure from the project root using your Makefile:

```bash
make all
```

4. If your Makefile separates build and startup, run:

```bash
make build
make up
```

5. Validate that containers are up and HTTPS is reachable at:

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
- Internal service communication through Docker networking and DNS
- Persistent storage strategy for WordPress and MariaDB data
- Environment-driven configuration flow (.env -> compose -> container -> entrypoint)
- Service startup orchestration via docker-compose.yml

## Services Summary

- **NGINX**: Acts as the secure entry point for the stack. Built from a custom `Dockerfile`, NGINX is configured to serve TLS (TLSv1.2 or TLSv1.3 only), run in the foreground (`daemon off`), and expose only port 443 to the host. It terminates TLS, manages SSL certificates, and reverse-proxies PHP requests to the WordPress `php-fpm` service (FastCGI on port 9000) across the private Docker network.

- **WordPress**: Runs `php-fpm` in its own container (no NGINX inside). The WordPress image is built from a custom `Dockerfile`, configured via `.env` and `wp-config.php`, and may include tooling such as `wp-cli`. It listens on port 9000 for FastCGI requests and stores website files in a named Docker volume (persisted on the host under `/home/login/data/wordpress`) that is shared with NGINX so PHP paths can be resolved and served.

- **MariaDB**: The dedicated database container built from a custom `Dockerfile`. MariaDB stores data in a named volume mapped to `/var/lib/mysql` (host persistence at `/home/login/data/mariadb`), is initialized via an `entrypoint` script (creates the DB and WordPress user), and is configured to listen on `0.0.0.0` inside the container so other services can connect. MariaDB is not exposed to the host and communicates only over the Compose bridge network.

## Resources

### References

- https://hub.docker.com/_/wordpress
- https://www.cloudflare.com/es-es/learning/cdn/glossary/reverse-proxy/
- https://mariadb.com/docs/
- https://hub.docker.com/_/nginx
- https://docs.docker.com/compose/

### How AI was used

In this repository workstream, AI was used for documentation tasks:

- Architecture Layout & Documentation: Structuring and formatting loose technical engineering notes into a highly readable, compliant Markdown format matching the 42 evaluation constraints.

- Conceptual Validation: Assisting in the clear architectural distinction and technical comparison between Virtual Machines vs. Containers, Network Paradigms, Storage Strategies, and Secrets Processing.

- Debugging Workflows: Assisting with debugging and troubleshooting various configuration and deployment challenges throughout the infrastructure setup process.







