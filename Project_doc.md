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
