# 🚀 Inception – Documentation

# The "Microservices" Revolution

## Monolithic Architecture (Before Docker)

A website was a single large application running on one large server.

If one component needed an update → The entire server restarted.

---

https://hub.docker.com/_/wordpress

## Microservices Architecture (Today)

Each feature runs in isolation:

- Search → One container
- Video → One container
- Messenger → One container

If one service crashes → Others continue running.

This is exactly what you are building with:

- Nginx
- WordPress
- MariaDB

All isolated, independent services.

<br>

# 1. NGINX

NGINX is:

- HTTP web server
- Reverse proxy
- Content cache
- Load balancer
- TCP/UDP proxy
- Mail proxy server

Reverse proxy explanation:  
https://www.cloudflare.com/es-es/learning/cdn/glossary/reverse-proxy/

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


# Technical Note: Port 80 as a Gateway

## 1. Rationale
Keeping port 80 closed entirely causes a "Connection Refused" if the user 
omits 'https://'. By keeping it open with a 301 redirect, we ensure 
accessibility without compromising security.

## 2. Variables used:
- $host: Resolves to 'anagarri.42.fr'.
- $request_uri: Preserves the path (e.g., /wp-admin) during the jump.

## 3. SEO & UX
The 301 status code is "Permanent", meaning modern browsers will remember 
this jump and go directly to 443 in future sessions without asking Nginx 
again (HSTS priming).

<br>

# 2. Docker Fundamentals

## Image vs Container

### Question
```
What is the difference between an Image and a Container?  
(Hint: Think "Class" vs. "Object")
```

### Answer
```
An image is like a blueprint or a class in object-oriented programming. It is a read-only template that contains the application code, runtime, libraries, environment variables, and configuration files. You can instantiate an image multiple times to create many identical containers.

A container is the actual running instance (the object). It is an isolated process that runs on the host's kernel using the specifications defined by the image. Because it is a process, it has its own isolated filesystem and network stack, but it shares the host's OS kernel rather than requiring its own guest OS.
```

---

## PID 1

### Question
```
What is PID 1? Why is it so important in a container, and what happens when it dies?
```

### Answer
```
PID 1 is the first process started inside a container. It is critical because the lifecycle of the container is tied to it; if PID 1 exits, the container stops immediately.

Unlike normal processes, PID 1 does not respond to default signals like SIGINT (Ctrl+C) or SIGTERM unless the application is specifically programmed to handle them. Additionally, PID 1 is responsible for "reaping" zombie processes. If the main process isn't built to handle this, the container can become cluttered with dead processes. To solve this, we can use a lightweight init system (like the --init flag or 'tini') to act as PID 1 and manage signals and zombies correctly.

Signal Handling:
In a normal Linux system, if a process doesn't handle a SIGINT (Ctrl+C), the kernel kills it. But for PID 1, the kernel assumes it's the "parent of the whole system" and won't kill it unless the process explicitly says it knows how to handle that signal. This is why some containers feel "stuck."

Zombie Processes:
When a process finishes, it usually leaves a "zombie" entry in the process table until its parent "reaps" it (acknowledges its death). If your main process (PID 1) isn't designed to be an init system, these zombies stay forever, eating up system resources.

The Lifecycle:
In Docker, Container Life = PID 1 Life. If PID 1 finishes its task or crashes, the container's execution environment is immediately destroyed by the Docker Engine.
```

---

## COPY vs ADD

### Question
```
What is the difference between COPY and ADD in a Dockerfile?
```

---

## ENTRYPOINT vs CMD

### Question
```
Why should we use ENTRYPOINT instead of CMD for these specific services?
```

---

## Docker Layers

### Question
```
What is a Layer in a Dockerfile?
If you change the last line of your Dockerfile, does Docker rebuild the whole thing?
(Look up Build Cache)
```

---

## EXPOSE vs PUBLISH

### Question
```
What is the difference between EXPOSE and PUBLISH (-p)?
Does EXPOSE actually open a port on your host machine?
```

---

## Alpine Linux

### Question
```
Why do we use Alpine Linux instead of Debian or Ubuntu?
(Hint: Check the image sizes and security footprint)
```

<br>

# 3. Orchestration – Docker Compose

---

## docker-compose.yml

### Question
```
What is docker-compose.yml actually doing?
Is it creating a script, or is it a configuration for an orchestrator?
```

### Answer
```
While a Dockerfile defines the environment and dependencies for a single container, the docker-compose.yml is a declarative configuration file used to define and run multi-container applications.

It acts as a set of instructions for the Docker Compose orchestrator. Instead of running multiple docker run commands manually, the YAML file allows us to define services, networks, and volumes in one place. When we run docker-compose up, the tool ensures that the entire infrastructure—like the connection between Nginx and MariaDB—is created according to that blueprint.
```

---

## Docker Network

### Question
```
What is a "Docker Network"?
How do two containers talk to each other if they don't have the same IP address?
(Look up Docker DNS resolution)
```

### Answer
```
A Docker Network is a virtual bridge that provides isolation and connectivity between containers. Two containers communicate using Docker's embedded DNS resolution. Instead of using volatile IP addresses, containers use Service Names defined in the docker-compose.yml as hostnames.

For example, WordPress can reach the database simply by connecting to:

mariadb:3306

Docker's internal DNS server handles the translation of that name into the current internal IP of the target container.
```

---

## build vs image

### Question
```
What is the difference between build: . and image: alpine?
```

### Answer
```
image: alpine tells Docker Compose to pull a pre-existing, read-only image from a registry like Docker Hub.

In contrast, build: . instructs Docker to create a custom image locally by executing the instructions found in a Dockerfile located in the specified directory.

For the Inception project, we use build because the subject requires us to manually configure our own containers rather than using automated, pre-configured images.
```

---

## depends_on

### Question
```
What is depends_on?
Does it guarantee that MariaDB is "ready" to accept connections before WordPress starts, or just that the container has "started"?
```

---

## Secrets Management

### Question
```
How do you pass secrets (passwords) to your containers without hardcoding them in the docker-compose.yml?
(Look up .env files)
```

---

## Port Conflicts

### Question
```
What happens if two containers try to use the same port on the internal Docker network?
```

<br>

# 4. Data Persistence – Volumes

---

## Container Deletion

### Question
```
Where does data go when a container is deleted?
```

---

## Bind Mount vs Named Volume

### Question
```
What is a "Bind Mount" vs. a "Named Volume"?
The subject has specific requirements about where your data must live on the host machine (/home/user/data)
```

### Answer
```
The main difference is management.

A Named Volume is managed by Docker in an internal directory, making it great for performance but harder to access manually.

A Bind Mount maps a specific path on the host machine directly into the container.

In the Inception project, we use bind mounts (or specifically configured volumes pointing to host paths) because the subject requires data to persist at:

/home/login/data

This ensures that our database and website content are stored outside the container's lifecycle and are easily accessible for administrative tasks on the host.
```

<br>

# 5. Networking & Security – TLS/SSL

---

## Port Mapping

### Question
```
What is Port Mapping?
Why do we map 443:443 for Nginx but not for MariaDB?
```

### Answer
```
In your docker-compose.yml, only Nginx has:

ports:
  - "443:443"

This tells the Host machine:

"If someone talks to me on port 443 (HTTPS), send that traffic straight to the Nginx container."

Nginx is the only container with a door open to the outside world.

WordPress listens on port 9000 (PHP-FPM).
MariaDB listens on port 3306.

However, they do not have a ports section in the Compose file.
This means they are only reachable inside the Docker Network.

Nginx acts as a Reverse Proxy.
All incoming traffic must pass through it first.
```

<br>

# 6. The 42 Constraints

---

## network: host

### Question
```
Why is network: host forbidden?
```

---

## latest Tag

### Question
```
Why is the latest tag forbidden?
(Hint: Think about reproducibility)
```

---

## Restart Policies

### Question
```
How do you ensure your containers restart automatically if the host machine reboots?
(Look up Restart Policies)
```

---

## Signals

### Question
```
What is a Signal?
When you run docker stop, what signal is sent to your PID 1?
How should your application handle it?
```


