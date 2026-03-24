# Inception – Project Requirements 🐳

<br>

## General Rules

1. The project must be developed and tested inside a **Virtual Machine**.
2. All required files must be placed inside the `srcs/` directory.
3. A `Makefile` is required at the root of the repository.  
   It must build the Docker images using `docker-compose.yml`.

<br>

## Docker & Image Rules

- Each Docker image must have the same name as its corresponding service.
- Each service must run in a **dedicated container**.
- Containers must be built from the **penultimate stable version** of:
  - Alpine  
  - Debian  
  *(Your choice.)*

### Mandatory Constraints

- You must write your own **Dockerfiles** (one per service).
- Dockerfiles must be called inside `docker-compose.yml` via your `Makefile`.
- You must build all Docker images manually.
- ❌ Pulling pre-built images is forbidden.
- ❌ Using DockerHub services is forbidden.  
  *(Alpine and Debian base images are allowed.)*

<br>

# Mandatory Infrastructure Setup

You must configure:

- A container with **NGINX** supporting **TLSv1.2 or TLSv1.3 only**
- A container with **WordPress + php-fpm** (without NGINX)
- A container with **MariaDB only** (without NGINX)
- A volume for the **WordPress database**
- A volume for the **WordPress website files**

### Volume Rules

- Must be **Docker named volumes**
- ❌ Bind mounts are forbidden
- Must store data inside:

```
inception/
├── Makefile
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

<br>

# Conceptual Summary

**Dockerfile**  
> Installs and configures the service (e.g., MariaDB and prepares `/var/lib/mysql`).

**.env**  
> Stores sensitive environment variables (database name, passwords, etc.).

**docker-compose.yml**  
> Uses the Dockerfile, injects `.env` variables, connects volumes and services.

Example logic:

- Dockerfile → "Install MariaDB and prepare `/var/lib/mysql`"
- `.env` → "Store DB credentials"
- Compose → "Build image, pass variables, attach volume `/home/login/data/mariadb`"

<br>

#  Why Containers Won

## 1️⃣ Consistency

"If it works on my machine" is no longer an excuse.

Docker images ensure identical behavior across environments.


## 2️⃣ Elasticity

Containers start in milliseconds.

On high traffic events (e.g., Black Friday), companies can spin up thousands of instances instantly.

## 3️⃣ Security

MariaDB is isolated from the public internet.

Attackers cannot directly access the database layer.

<br>

# Docker Architecture: Inception vs Industry Scale

## Comparison Table

| Feature | Inception Project | Large Tech Companies |
|----------|------------------|----------------------|
| Orchestration | Docker Compose | Kubernetes / Docker Swarm |
| Infrastructure | Single Host (42 VM) | Multi-node Clusters |
| Scalability | Static (1 per service) | Auto-scaling |
| Availability | Single Point of Failure | High Availability |
| Updates | Manual restart | Rolling Updates |
| Network | Bridge Network | Mesh / Global Load Balancers |

<br>

# Reverse Proxy Logic (Critical Concept)

Only **Nginx** is exposed to the outside world.

| Component | Internal Port | External Port | Role |
|------------|---------------|---------------|------|
| Nginx | 443 | 443 | Gateway |
| WordPress | 9000 | None | PHP Processor |
| MariaDB | 3306 | None | Database |

Traffic Flow:

User → Nginx → WordPress → MariaDB

<br>

# Defense Tip – Single Responsibility Principle

If asked:

> Why separate Nginx, WordPress, and MariaDB?

Answer:

To follow the **Single Responsibility Principle**, enabling:

- Better isolation
- Independent scaling
- Safer updates
- Easier maintenance

<br>

# Data Storage Requirement

The subject requires storing data in:

```
/home/login/data/mariadb
/home/login/data/wordpress
```

### Why?

**Transparency**  
Evaluators can verify data exists on the host.

**Control**  
Proves you understand volume mapping.

**Persistence**  
Even after:

```
docker system prune -a
```

Your data remains intact.

<br>

# ⚠️ The "Inception Trap"

Example in `docker-compose.yml`:

```yaml
services:
  nginx:
    build: ./requirements/nginx
    image: my_nginx_image
```

Why both `build` and `image`?

- `build` → Tells Docker how to create the image
- `image` → Assigns a name/tag to the resulting build

This allows identification and reuse of the built image.

<br>

# Additional Tip

In Inception, you typically do not use `--init`.

You are expected to configure your services (Nginx, MariaDB, etc.) to behave correctly as PID 1 processes.

<br>

# Core Idea

Inception is about:

- Microservices architecture
- Container isolation
- Networking
- Volume persistence
- Infrastructure design
- Reproducibility

<br>

# Shared Folder Setup: VirtualBox & Linux (42 School Environment)

This guide summarizes the steps to enable a shared folder between your Host (Windows/Mac) and your Linux Guest VM, allowing seamless file transfers for project evaluations.

---

### 1. Host Configuration (VirtualBox UI)
Before running commands inside the VM, configure the folder in the VirtualBox interface:

1. Go to **Devices** -> **Shared Folders** -> **Shared Folders Settings...**
2. Click the **"Adds new shared folder"** icon (+).
3. Set **Folder Path** to your local directory on the Host.
4. Set **Folder Name** (e.g., `shared`).
5. Check **Auto-mount** and **Make Permanent**.
6. Leave "Mount point" empty.

---

### 2. Guest Configuration (Linux Terminal)

Inside your Linux VM, follow these technical steps to grant access:

#### Step A: Install Dependencies & Guest Additions
Ensure your system is ready to handle VirtualBox modules:
```bash
sudo apt update
sudo apt install build-essential dkms linux-headers-$(uname -r)
# Insert and run the Guest Additions CD if not already done.
```

<br>

# Technical Guide: Extracting, Modifying, and Building MariaDB (Inception)

This document summarizes the steps taken to configure a customized database environment starting from an official image, ensuring that networking and configuration details are integrated into our own image.

---

## 1. Obtaining the Base Template (Docker Pull)

The process begins by downloading the official MariaDB image from Docker Hub. This image serves as our **base blueprint** and as the source of the original configuration files required for the software to run.

```bash
docker pull mariadb:latest
```

---

## 2. Configuration Extraction (Reverse Engineering)

Since the configuration files live inside the isolated container environment, we launch a temporary instance to extract the required file (`50-server.cnf`).

### Launch temporary container

```bash
docker run -d --name mi_mariadb -e MYSQL_ROOT_PASSWORD=root_pass mariadb:latest
```

### Copy the file to the Host (Our VM)

We use Docker's `cp` command to extract the file from the container to our local folder structure:

```bash
docker cp mi_mariadb:/etc/mysql/mariadb.conf.d/50-server.cnf ./srcs/requirements/mariadb/conf/
```

### Cleanup

Once the file has been retrieved, we remove the temporary container:

```bash
docker rm -f mi_mariadb
```

---

## 3. Network Technical Adjustment (Bind-Address)

The most important detail of the project is allowing containers to communicate with each other.  
By default, MariaDB only listens on the internal `localhost`.

### Action

Open the file:

```
./srcs/requirements/mariadb/conf/50-server.cnf
```

### Modification

Change:

```
bind-address = 127.0.0.1
```

to:

```
bind-address = 0.0.0.0
```

### Result

The database engine will now accept requests from any network interface, allowing the **WordPress** container to connect successfully.

---

## 4. Recipe Definition (Dockerfile)

Create the `Dockerfile` inside:

```
srcs/requirements/mariadb/
```

This file automates the creation of a new image that already includes our modifications.

```Dockerfile
# Base Layer: Clean official image
FROM mariadb:latest

# Configuration Layer: Inject our modified configuration file
# This overwrites the default configuration from the base image
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
```

---

## 5. Building the Image (Build Context)

Finally, we run the build engine indicating the current directory as the context.

```bash
docker build -t mi_mariadb_personalizada .
```

### The Detail of the Dot (`.`)

The dot at the end indicates that the **build context** is the current directory.  
This allows the `COPY` instruction to locate the `conf/` folder and the `50-server.cnf` file in order to integrate them into the new image.

---

## Final Result

We now have a local image named:

```
mi_mariadb_personalizada
```

This image is **architecturally identical to the official one**, but with networking **preconfigured for the Inception environment**, allowing proper communication between containers.

<br>

# Technical Notes: Docker Concepts Learned While Running WordPress

This section summarizes several key technical lessons learned while setting up a WordPress container and connecting it with MariaDB. Each issue revealed an important concept about how Docker works internally.

---

## 1. The Image vs. Container Concept

### What we did

We pulled the official WordPress image:

```bash
docker pull wordpress:latest
```

### The problem

You tried to locate the `wp-config.php` file, but it did not exist.

### The lesson

Official Docker images are often **minimalistic**. Some files are **not included in the image itself** and are generated dynamically when:

- The container starts for the first time
- The web installation process is completed

This means that if you want to inspect what actually exists inside a running container, you need to access it directly:

```bash
docker exec -it <container_name> bash
```

---

## 2. Network Isolation (The `inception_net` Error)

### What we did

We attempted to start the WordPress container connected to a network called `inception_net`.

### The problem

Docker returned the error:

```
network inception_net not found
```

### The lesson

In Docker, **the order of operations matters**.

You cannot connect a container to a network that **does not exist yet**. The network must be created first.

### Solution

Create the network manually before running containers:

```bash
docker network create inception_net
```

---

## 3. Communication Between Microservices (Internal DNS)

### What we did

We configured the environment variable:

```
WORDPRESS_DB_HOST=mi_mariadb
```

### The problem

WordPress initially could not locate the database container.

### The lesson

For containers to communicate, **they must share the same virtual network**.

When two containers are connected to the same Docker network:

- Docker automatically enables an **internal DNS system**
- Containers can resolve each other **by container name instead of IP address**

Once both containers were connected to `inception_net`, WordPress was able to resolve `mi_mariadb` correctly.

Example:

```bash
docker network connect inception_net mi_mariadb
docker network connect inception_net wordpress
```

---

## 4. "Inception" Inside the Terminal

### What we did

You attempted to execute Docker commands **from inside the container**.

### The problem

The terminal returned:

```
bash: docker: command not found
```

### The lesson

A container behaves like a **small isolated machine**. It does not automatically contain the Docker CLI.

Docker management commands must always be executed **from the host machine**, not from inside a container.

### Solution

Exit the container:

```bash
exit
```

Then run Docker commands from your **host system (VM)**.

---

## Technical Summary: Problems and Solutions

| Problem | Root Cause | Tech Lead Solution |
|-------|-------|-------|
| `Network not found` | Attempting to use a network that was never created | `docker network create <network_name>` |
| `Command not found` | Running host commands inside a container | Exit the container and run commands on the host |
| `File not found` | The file is generated dynamically during setup | Use `wp-config-sample.php` as the base |
| Database connection error | Containers are on different networks or misconfigured | Use `docker network connect` and verify `-e` variables |

---

## Key Takeaway

Running multi-container systems like **WordPress + MariaDB** requires understanding three core Docker concepts:

- **Image vs Container lifecycle**
- **Docker networking**
- **Host vs Container execution context**

Mastering these concepts is essential for building reliable multi-service environments such as the **Inception project**.




Daemon mode: Nginx, por defecto, intenta ejecutarse en segundo plano (como un demonio). En Docker, si el proceso se va al segundo plano, el proceso principal del contenedor desaparece y Docker cree que ha terminado.

En el caso de Nginx + WordPress, hay un detalle crítico: Nginx y WordPress deben compartir el mismo volumen.

¿Por qué compartir?
Nginx recibe la petición del navegador. Si el navegador pide index.php, Nginx necesita "ver" ese archivo en el disco para saber que existe, y luego le dice a WordPress (vía FastCGI) que lo ejecute. Si Nginx no tiene acceso a los archivos de WordPress, te dará un error 404 Not Found.

# Technical Note: Nginx Configuration Hierarchy in Docker (Debian)

## Technical Breakdown: OpenSSL Self-Signed Certificate
TLS: transport layer security
## 1. Command Architecture
`openssl req -x509 -nodes -days 365 -newkey rsa:2048`

- **Purpose**: Generates a self-signed SSL/TLS certificate for local development.
- **Security Level**: RSA 2048-bit (Standard).
- **Validity**: 1 Year (365 days).
- **Passphrase**: None (`-nodes`), allowing Nginx to start automatically.

## 2. File Roles
| File Extension | Name | Visibility | Role |
| :--- | :--- | :--- | :--- |
| `.key` | Private Key | **SECRET** | Used by Nginx to decrypt traffic. Must never be shared. |
| `.crt` | Certificate | **PUBLIC** | Sent to the browser to identify the server. |

## 3. The Subject Field (`-subj`)
Defines the Identity of the server. The `CN` (Common Name) is the most critical field as it must match the domain name (e.g., login.42.fr) for the browser to consider it potentially valid.

# Technical Note: Environment Variable Propagation

## 1. The .env File
The `.env` file acts as the single source of truth for project configuration. It is stored on the host machine and should contain sensitive or user-specific data (logins, passwords, IPs).

## 2. Propagation Chain
1. **Host**: `.env` file exists in the project root.
2. **Orchestrator**: `docker-compose.yml` reads the `.env` and maps variables using the `env_file` or `environment` directives.
3. **Container**: The Docker engine injects these variables into the container's shell environment upon startup.
4. **Script**: The Entrypoint script (shell) accesses these variables using the standard `$VARIABLE` syntax.

## 3. Best Practice: Variable Expansion
In Shell scripts, it is safer to use `${USER}` instead of `$USER` to avoid ambiguity with surrounding text (e.g., `${USER}.42.fr` ensures the interpreter doesn't look for a variable named `USER.42`).

## 4. Security Tip
The `.env` file is often ignored in `.gitignore` to prevent leaking credentials, while a `.env.example` is provided with dummy values.

# Technical Note: ENTRYPOINT vs CMD Relationship

## 1. Executive Roles
- **ENTRYPOINT**: Defines the binary or script that must ALWAYS run when the container starts. It is the "Hard" command.
- **CMD**: Defines the default arguments passed to the ENTRYPOINT. It is the "Soft" command (can be overridden easily from the CLI).

## 2. Inception Implementation Pattern
In this project, we use the **Exec Form** (using square brackets `[]`) for both, as it allows Docker to pass signals (like SIGTERM) directly to the processes.

### Workflow:
1. Docker starts `/usr/local/bin/setup.sh`.
2. The script performs setup tasks (OpenSSL).
3. The script finishes with `exec "$@"`.
4. The system executes the `CMD` (`nginx -g "daemon off;"`), replacing the script process as PID 1.

## 3. Best Practice: Shell Exec
Always use `exec "$@"` at the end of an entrypoint script. This ensures that the main service (Nginx) receives OS signals correctly, allowing for graceful shutdowns.


# Technical Note: Nginx Location Context

## 1. Definition
The `location` directive defines how Nginx processes specific URI requests. It lives inside the `server` block.

## 2. Syntax Types
- `location /`: Prefix match. Matches any request starting with `/`.
- `location = /`: Exact match. Only matches the root.
- `location ~ \.php$`: Case-sensitive Regular Expression match (used for PHP-FPM).

## 3. Key Directives inside Location
| Directive | Purpose |
| :--- | :--- |
| `root` | Sets the base directory for file lookups. |
| `index` | Defines the file to serve if the URI is a directory. |
| `proxy_pass` | Forwards the request to a different server/container. |
| `try_files` | Checks for file existence in a specific order before failing. |

## 4. Why use `try_files $uri $uri/ =404;`?
This is a standard security and usability pattern. It prevents Nginx from exposing directory listings and ensures the user gets a proper 404 error instead of a generic server crash if a file is missing.

## 2. The Problem: Overwriting the Master Configuration
In the initial Dockerfile setup, the following command was used:
`COPY conf/default.conf /etc/nginx/nginx.conf`

### What happened?
By copying a simple `server { ... }` block into `/etc/nginx/nginx.conf`, the **Master Configuration** file was destroyed. 

Nginx requires a specific global structure to start. The master file (`nginx.conf`) typically looks like this:

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    # ... global settings (SSL, Logs, Gzip) ...
    
    include /etc/nginx/conf.d/*.conf; # <--- THIS IS THE KEY
    include /etc/nginx/sites-enabled/*;
}
When you replaced this with your default.conf, Nginx lost its http context, its events context, and its basic execution directives. As a result, the process failed to initialize and exited immediately (Exit Code 0/1).2. The Solution: Modular Configuration (conf.d)Instead of replacing the brain of Nginx, we now "plug in" our configuration as a module.Revised Dockerfile Command:COPY conf/default.conf /etc/nginx/conf.d/default.confWhy this works:Preservation: The original /etc/nginx/nginx.conf provided by the Debian image remains intact.Auto-Inclusion: The master file contains an include /etc/nginx/conf.d/*.conf; directive inside the http block.Validation: Nginx starts globally, then reads your default.conf as a valid "child" configuration.3. Best Practices for Inception (42)Separation of Concerns: Keep global settings in the image and site-specific settings (ports, server_name, fastcgi) in separate files.Path Integrity: In Debian-based containers, always use /etc/nginx/conf.d/ for simple setups or /etc/nginx/sites-available/ + symbolic links for complex ones.PID 1 Stability: Ensure daemon off; is passed via CMD so the container stays "Up" as long as the master process is running.Summary Table: Path ComparisonTarget PathResultStatus/etc/nginx/nginx.confOverwrites global settings❌ CRITICAL ERROR/etc/nginx/conf.d/default.confAdds your server block to the global context✅ RECOMMENDED/etc/nginx/sites-available/Defines the site but requires a symlink to sites-enabled⚠️ OVERKILL FOR NOW




