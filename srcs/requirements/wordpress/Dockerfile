FROM debian:bookworm

#WORKDIR /the/workdir/path

RUN mkdir -p /var/www/html
RUN mkdir -p /tmp

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl https://wordpress.org/latest.zip -o /tmp/wordpress.zip
RUN ls /tmp
RUN unzip /tmp/wordpress.zip -d /tmp/
#RUN unzip -d /var/www/html/ /tmp/wordpress.zip
RUN ls /var/www/html/

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./conf/php-fpm.conf /etc/php/8.2/fpm/php-fpm.conf
COPY ./conf/wp-config.php /tmp/wp-config.php

#RUN chown -R www-data:www-data /var/www/html/wordpress

EXPOSE 9000

CMD ["/usr/sbin/php-fpm8.2",  "--nodaemonize", "--fpm-config", "/etc/php/8.2/fpm/php-fpm.conf"]

ENTRYPOINT ["/usr/local/bin/setup.sh"]



# cat php8.3-fpm.service 
# [Unit]
# Description=The PHP 8.3 FastCGI Process Manager
# Documentation=man:php-fpm8.3(8)
# After=network.target

# [Service]
# Type=notify
# ExecStart=/usr/sbin/php-fpm8.3 --nodaemonize --fpm-config /etc/php/8.3/fpm/php-fpm.conf
# ExecStartPost=-/usr/lib/php/php-fpm-socket-helper install /run/php/php-fpm.sock /etc/php/8.3/fpm/pool.d/www.conf 83
# ExecStopPost=-/usr/lib/php/php-fpm-socket-helper remove /run/php/php-fpm.sock /etc/php/8.3/fpm/pool.d/www.conf 83
# ExecReload=/bin/kill -USR2 $MAINPID

# [Install]
# WantedBy=multi-user.target


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
