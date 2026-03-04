# Inception – Project Requirements

## General Rules

1. The project must be developed and tested inside a **Virtual Machine**.
2. All required files must be placed inside the `srcs/` directory.
3. A `Makefile` is required at the root of the repository.  
   It must build the Docker images using `docker-compose.yml`.

---

## Docker & Image Rules

- Each Docker image must have the same name as its corresponding service.
- Each service must run in a **dedicated container**.
- Containers must be built from the **penultimate stable version** of either:
  - Alpine, or
  - Debian  
  (Your choice.)

- You must write your own **Dockerfiles**, one per service.
- The Dockerfiles must be called in your `docker-compose.yml` by your `Makefile`.
- You must build all Docker images yourself.
- Pulling pre-built images is **forbidden**.
- Using services such as DockerHub is **forbidden**.  
  (Exception: Alpine and Debian base images are allowed.)

---

## Mandatory Infrastructure Setup

You must configure:

- A Docker container with **NGINX**, supporting **TLSv1.2 or TLSv1.3 only**.
- A Docker container with **WordPress + php-fpm** (installed and configured), **without NGINX**.
- A Docker container with **MariaDB only**, without NGINX.
- A volume containing the **WordPress database**.
- A second volume containing the **WordPress website files**.
- Both volumes must be **Docker named volumes** (bind mounts are forbidden).
- Both named volumes must store their data inside:

```
inception/
├── Makefile                # Root of the project
└── srcs/                   # All project source files
    ├── .env                # Environment variables (passwords, etc.)
    ├── docker-compose.yml  # The master configuration
    └── requirements/       # The "Requirements" for each service
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/       # Custom DB configs
        │   └── tools/      # Setup scripts
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/       # TLS/SSL and Server configs
        └── wordpress/
            ├── Dockerfile
            ├── conf/       # PHP-FPM configs
            └── tools/      # WP-CLI scripts
```

Resumen visual:
Dockerfile: "Instalo MariaDB y dejo el hueco en /var/lib/mysql".
.env: "Aquí guardo el nombre de mi base de datos".
Docker Compose: "Usa ese Dockerfile, pásale las variables del .env y conecta el volumen del host /home/login/data/mariadb al hueco del contenedor".

#### Tips
1- In the Inception project, you usually don't use the --init flag because you are expected to configure your services (Nginx, MariaDB) to behave correctly as the primary process.

The subject specifically requires you to store your data in /home/login/data/mariadb and /home/login/data/wordpress.

Why does it ask for this?

Transparency: The evaluators want to see that your data actually exists on the host machine. If they run ls /home/user/data/wordpress, they should see the WordPress files.

Control: It proves you understand how to link the container's internal file system to a specific physical location on the disk.

Persistence: It ensures that even if you run docker system prune -a (which deletes images and containers), your database and website files remain safe on your hard drive.

The "Inception" Trap
In your docker-compose.yml, you will actually see a combination of both:

```YAML
services:
  nginx:
    build: ./requirements/nginx
    image: my_nginx_image  # This gives your custom build a name!
The evaluator might ask: "Why do you have both build and image here?" The answer is: build tells Docker how to make it, and image gives that result a name/tag so you can identify it in your system.
```
<br>
<br>

# Inception – Documentation

## NGINX
Is an HTTP web server, reverse proxy, content cache, load balancer, TCP/UDP proxy server, and mail proxy server.

[proxy server](https://www.cloudflare.com/es-es/learning/cdn/glossary/reverse-proxy/)

## 1. The "Basics" (Docker Fundamentals)
 **What is the difference between an Image and a Container? (Hint: Think "Class" vs. "Object").**

An image is like a blueprint or a class in object-oriented programming. It is a read-only template that contains the application code, runtime, libraries, environment variables, and configuration files. You can instantiate an image multiple times to create many identical containers.

A container is the actual running instance (the object). It is an isolated process that runs on the host's kernel using the specifications defined by the image. Because it is a process, it has its own isolated filesystem and network stack, but it shares the host's OS kernel rather than requiring its own guest OS.

 **What is PID 1? Why is it so important in a container, and what happens when it dies?**

PID 1 is the first process started inside a container. It is critical because the lifecycle of the container is tied to it; if PID 1 exits, the container stops immediately.

Unlike normal processes, PID 1 does not respond to default signals like SIGINT (Ctrl+C) or SIGTERM unless the application is specifically programmed to handle them. Additionally, PID 1 is responsible for 'reaping' zombie processes. If the main process isn't built to handle this, the container can become cluttered with dead processes. To solve this, we can use a lightweight init system (like the --init flag or 'tini') to act as PID 1 and manage signals and zombies correctly.

Signal Handling: In a normal Linux system, if a process doesn't handle a SIGINT (Ctrl+C), the kernel kills it. But for PID 1, the kernel assumes it's the "parent of the whole system" and won't kill it unless the process explicitly says it knows how to handle that signal. This is why some containers feel "stuck."

Zombie Processes: When a process finishes, it usually leaves a "zombie" entry in the process table until its parent "reaps" it (acknowledges its death). If your main process (PID 1) isn't designed to be an init system, these zombies stay forever, eating up system resources.

The Lifecycle: In Docker, Container Life = PID 1 Life. If PID 1 finishes its task or crashes, the container's execution environment is immediately destroyed by the Docker Engine.

 **What is the difference between COPY and ADD in a Dockerfile?**

 **Why should we use ENTRYPOINT instead of CMD for these specific services?**

What is a Layer in a Dockerfile? If you change the last line of your Dockerfile, does Docker rebuild the whole thing? (Look up Build Cache).

What is the difference between EXPOSE and PUBLISH (-p)? Does EXPOSE actually open a port on your host machine?

Why do we use Alpine Linux instead of Debian or Ubuntu? (Hint: Check the image sizes and security footprint).

## 2. Orchestration (Docker Compose)
 ### What is docker-compose.yml actually doing? Is it creating a script, or is it a configuration for an orchestrator? 
 
While a Dockerfile defines the environment and dependencies for a single container, the docker-compose.yml is a declarative configuration file used to define and run multi-container applications.

It acts as a set of instructions for the Docker Compose orchestrator. Instead of running multiple docker run commands manually, the YAML file allows us to define services, networks, and volumes in one place. When we run docker-compose up, the tool ensures that the entire infrastructure—like the connection between Nginx and MariaDB—is created according to that blueprint.

### What is a "Docker Network"? How do two containers talk to each other if they don't have the same IP address? (Look up Docker DNS resolution).

A Docker Network is a virtual bridge that provides isolation and connectivity between containers. Two containers communicate using Docker's embedded DNS (domain name system) resolution. Instead of using volatile IP addresses, containers use Service Names defined in the docker-compose.yml as hostnames. For example, WordPress can reach the database simply by connecting to mariadb:3306. Docker's internal DNS server handles the translation of that name into the current internal IP of the target container.

- ### What is the difference between build: . and image: alpine?
image: alpine tells Docker Compose to pull a pre-existing, read-only image from a registry like Docker Hub. In contrast, build: . instructs Docker to create a custom image locally by executing the instructions found in a Dockerfile located in the specified directory. For the Inception project, we use build because the subject requires us to manually configure our own containers rather than using automated, pre-configured images.

What is depends_on? Does it guarantee that MariaDB is "ready" to accept connections before WordPress starts, or just that the container has "started"?

How do you pass secrets (passwords) to your containers without hardcoding them in the docker-compose.yml? (Look up .env files).

What happens if two containers try to use the same port on the internal Docker network?

## 3. Data Persistence (Volumes)
### Where does data go when a container is deleted?

### What is a "Bind Mount" vs. a "Named Volume"? The subject has specific requirements about where your data must live on the host machine (/home/user/data).
The main difference is management. A Named Volume is managed by Docker in an internal directory, making it great for performance but harder to access manually. A Bind Mount maps a specific path on the host machine directly into the container.In the Inception project, we use bind mounts (or specifically configured volumes pointing to host paths) because the subject requires data to persist at /home/login/data. This ensures that our database and website content are stored outside the container's lifecycle and are easily accessible for administrative tasks on the host.

### Why can't we just save the database inside the container image?
What is the "copy-on-write" strategy? How does Docker handle it when you modify a file that was originally part of the Image?

If you delete a volume using docker volume rm, is the data gone forever? What if the container is still running?

Why must your volumes be mapped to /home/login/data specifically? (This is a core requirement of the Inception subject).

## 4. Networking & Security (TLS/SSL)
### What is Port Mapping? Why do we map 443:443 for Nginx but not for MariaDB?

In your docker-compose.yml, only Nginx has a line like ports: - "443:443".
This tells the Host machine: "If someone talks to me on port 443 (HTTPS), send that traffic straight to the Nginx container."

Nginx is the only container with a "door" open to the outside world. This makes your infrastructure much more secure.

Your other containers (WordPress and MariaDB) are running, but they are hidden.

WordPress is listening on port 9000 (standard for PHP-FPM).

MariaDB is listening on port 3306.

However, they do not have a ports section in the Compose file. This means if you try to go to localhost:9000 in your browser, you will get nothing. They are only reachable inside the Docker Network.

In this architecture, Nginx acts as a Reverse Proxy. We only expose port 443 to the host machine for security reasons—this ensures that all incoming traffic must pass through our web server's firewall and SSL encryption first.

Even though WordPress and MariaDB aren't 'open' to the host, they are accessible to Nginx via the internal Docker network. When a user requests a page, Nginx receives the traffic and forwards it internally to the WordPress container using the FastCGI protocol. This keeps our database and application logic shielded from the public internet

### How does TLS (SSL) work? Why do you need a .crt and a .key file for Nginx?

### What is a "Self-Signed Certificate"? Why will your browser show a "Warning: Unsafe" even if your setup is correct?
What is the difference between HTTP and HTTPS at the OSI model level?

How does Nginx know to send a request to wordpress:9000? Does it use an IP address, or a hostname? Who translates "wordpress" into an IP?

Why is MariaDB listening on port 3306 but not accessible from your browser?
## 5. Service Specifics (The "How It Works")
### Nginx: Why is Nginx the only "entry point" to your infrastructure? Why shouldn't the outside world be able to talk directly to WordPress?

### PHP-FPM: How does Nginx "send" a PHP file to the PHP container? (Look up the FastCGI protocol).

### MariaDB: How do you initialize a database with a script without hardcoding passwords in the Dockerfile? (Look up Environment Variables).
Nginx: What is a server block and a location block? How does Nginx decide which one to use?

WordPress: Why does WordPress need a "wp-config.php" file, and how can you automate its creation during the container setup?

MariaDB: What is the difference between the root user and a regular database user in terms of privileges?

## 6. The "42 Rules" (The Constraints)
### Why is network: host forbidden?

### Why is the latest tag forbidden? (Hint: Think about "reproducibility" and what happens if a new version breaks your code tomorrow).

### What is Alpine Linux? Why is it the preferred base image for this project instead of Ubuntu?
Why can't we use docker run? Why does the subject force us to use Makefile and docker-compose?

How do you ensure your containers restart automatically if the host machine reboots? (Look up Restart Policies).

What is a "Signal"? When you run docker stop, what signal is sent to your PID 1, and how should your application handle it?