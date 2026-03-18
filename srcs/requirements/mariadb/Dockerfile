FROM debian:bookworm

#En MariaDB: El "corazón" está en /var/lib/mysql (donde están los datos), pero nunca pongas el WORKDIR ahí. Es una carpeta de sistema protegida y podrías causar conflictos de permisos si intentas ejecutar scripts desde ahí.
WORKDIR /usr/local/bin/

# Copy in the source code
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint.sh .

# Setup an app user so the container doesn't run as the root user
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*
    #(/var/lib/apt/lists/)las listas de qué programas existen y en qué versión están que se descargan cuando haces apt update.

EXPOSE 3306

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

ENTRYPOINT ["./entrypoint.sh"]

# Evitamos que se abran menús interactivos
#ARG DEBIAN_FRONTEND=noninteractive





# FROM <image> - this specifies the base image that the build will extend.
# WORKDIR <path> - this instruction specifies the "working directory" or the path in the image where files will be copied and commands will be executed.
# COPY <host-path> <image-path> - this instruction tells the builder to copy files from the host and put them into the container image.
# RUN <command> - this instruction tells the builder to run the specified command.
# ENV <name> <value> - this instruction sets an environment variable that a running container will use.
# EXPOSE <port-number> - this instruction sets configuration on the image that indicates a port the image would like to expose.
# USER <user-or-uid> - this instruction sets the default user for all subsequent instructions.
# CMD ["<command>", "<arg1>"] - this instruction sets the default command a container using this image will run.



# Dockerfile: Solo instala el software (apt install).

# Script .sh (Entrypoint): Se ejecuta dentro del contenedor cuando haces docker run. Es aquí donde se usan las variables de entorno de tu archivo .env.

# 1. El flag -y (Asumir "Yes" a todo)
# En Linux, casi todos los gestores de paquetes tienen un flag para no preguntar. En apt, es -y. Sin esto, el build se detendrá en la pregunta "¿Desea continuar? [Y/n]".

# 2. La variable DEBIAN_FRONTEND=noninteractive
# Algunos paquetes (como MariaDB o los que configuran zonas horarias) lanzan menús azules de texto (debconf) para elegir opciones. Para evitar esto, le decimos a Debian que no sea "interactivo".

# 3. El problema de systemctl y sudo
# Aquí hay un error conceptual común: En un Dockerfile NO se usa systemctl ni sudo.

# No sudo: En el proceso de build ya eres root por defecto.

# No systemctl: Los contenedores no tienen un sistema de gestión de servicios (init o systemd) corriendo durante el build. Los servicios no se "arrancan" en el RUN, se configuran para que arranquen cuando el contenedor finalmente se ejecute (CMD).

