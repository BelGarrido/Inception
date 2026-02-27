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

#### Tips
1- In the Inception project, you usually don't use the --init flag because you are expected to configure your services (Nginx, MariaDB) to behave correctly as the primary process.
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

- ### What is a "Docker Network"? How do two containers talk to each other if they don't have the same IP address? (Look up Docker DNS resolution).

- ### What is the difference between build: . and image: alpine?
What is depends_on? Does it guarantee that MariaDB is "ready" to accept connections before WordPress starts, or just that the container has "started"?

How do you pass secrets (passwords) to your containers without hardcoding them in the docker-compose.yml? (Look up .env files).

What happens if two containers try to use the same port on the internal Docker network?

## 3. Data Persistence (Volumes)
### Where does data go when a container is deleted?

### What is a "Bind Mount" vs. a "Named Volume"? The subject has specific requirements about where your data must live on the host machine (/home/user/data).

### Why can't we just save the database inside the container image?
What is the "copy-on-write" strategy? How does Docker handle it when you modify a file that was originally part of the Image?

If you delete a volume using docker volume rm, is the data gone forever? What if the container is still running?

Why must your volumes be mapped to /home/login/data specifically? (This is a core requirement of the Inception subject).

## 4. Networking & Security (TLS/SSL)
### What is Port Mapping? Why do we map 443:443 for Nginx but not for MariaDB?

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