Phase 1: The Foundation (System & Prep)

[ ] Set up your VM: Install the latest stable version of Debian or Alpine (as per the subject).

[✅] Install Docker & Docker Compose: Ensure you can run docker version and docker-compose version.
sudo usermod -aG docker ${USER} so we dont need to type sudo every time

[✅] Create the Directory Structure: * srcs/ for your code.

srcs/requirements/ for your service folders (nginx, mariadb, wordpress).

[✅] The Domain Name: Modify your /etc/hosts file so that login.42.fr points to 127.0.0.1.
sudo nano /etc/hosts
add a line: 127.0.0.1 anagarri.42.fr

Phase 2: The Logic (Configuration)

[✅] Create a .env file: Define your DB names, users, and passwords here.
Its totally forbiden to add the .env to a public repository, always in the .gitignore

[ ] Create a Basic Makefile: It should have all, build, up, down, and fclean rules.

[ ] Plan the Network: Decide on a name for your bridge network (e.g., inception_network).

Phase 3: Service by Service (The Build)

Tip: Build them in this order so you can test connectivity as you go.

1. MariaDB (The Vault)
[ ] Write the Dockerfile for MariaDB.

[ ] Create a script (entrypoint) to initialize the database and create the WordPress user.
El ENTRYPOINT especifica el ejecutable que usará el contenedor.
[ ] Task: Ensure MariaDB can listen on the network (edit 50-server.cnf or equivalent to bind to 0.0.0.0).

2. Nginx (The Gateway)
[ ] Write the Dockerfile for Nginx.

[ ] Generate a Self-Signed SSL Certificate using OpenSSL.

[ ] Configure the nginx.conf to listen only on port 443 with TLS 1.2/1.3.

[ ] Task: Test if you can reach a simple index.html via https://login.42.fr.

3. WordPress + PHP-FPM (The Engine)
[ ] Write the Dockerfile for WordPress.

[ ] Use wget or curl to download the WordPress CLI (wp-cli).

[ ] Create a script to configure wp-config.php using your .env variables.

[ ] Task: Configure PHP-FPM to listen on port 9000 (check www.conf).

Phase 4: Integration (The Snap-Together)
[ ] The docker-compose.yml:

[ ] Connect all services to your bridge network.

[ ] Link your volumes to /home/login/data/.

[ ] Ensure Nginx "depends_on" WordPress, and WordPress "depends_on" MariaDB.

[ ] The "Handshake": Configure Nginx to send .php requests to the wordpress container on port 9000 using FastCGI.

Phase 5: Verification (The Defense Prep)
[ ] Persistence Test: make down, then make up. Does your WordPress data (posts/users) still exist?

[ ] Security Test: Can you access MariaDB directly from the host? (The answer should be no).

[ ] Hacky Patch Check: Are you using tail -f anywhere? (Remember the subject warning!).

[ ] Reboot Test: Does everything come back up correctly?




