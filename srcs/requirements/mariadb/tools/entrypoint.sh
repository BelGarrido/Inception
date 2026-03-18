#Log in to MariaDB:
#Access the MariaDB shell as the root user:

mkdir -p /var/lib/mysql
mkdir -p /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing database."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

#mysql -u root -p

#Create a Database:
#Inside the MariaDB shell, create a new database:

CREATE DATABASE mydatabase;

#Create a User and Grant Privileges:
#Create a user and grant access to the database:

CREATE USER 'myuser'@'%' IDENTIFIED BY 'mypassword';
GRANT ALL PRIVILEGES ON mydatabase.* TO 'myuser'@'%';
FLUSH PRIVILEGES;

EXIT;

exec mysqld
#Esto asegura que MariaDB se convierta en el proceso con el PID 1, permitiendo que Docker gestione correctamente las señales de apagado (SIGTERM).

# ENTRYPOINT [ "" ]

# 1. Preparar el entorno (El "Suelo" de la DB)
# Antes de nada, el script debe asegurarse de que existen las carpetas necesarias donde MariaDB guarda sus procesos.

# Acción: Crear la carpeta /run/mysqld y darle los permisos correctos al usuario mysql. Sin esto, MariaDB no puede crear su archivo "socket" y fallará al arrancar.

# 2. Inicialización del Sistema (Solo la primera vez)
# No queremos borrar la base de datos cada vez que el contenedor se reinicie.

# Lógica: El script mira si ya existe la carpeta /var/lib/mysql/mysql (donde vive la base de datos maestra).

# Si no existe: Ejecuta mysql_install_db, que crea las tablas básicas del sistema.

# 3. Ejecución del SQL de Configuración (La "Magia")
# Aquí es donde inyectamos tus variables del .env (Usuario, Contraseña, Nombre de DB). Como MariaDB debe estar encendido para procesar SQL, el script hace este "baile":

# Arranca MariaDB en segundo plano (&).

# Espera a que el servicio responda (un pequeño sleep o un bucle de comprobación).

# Lanza los comandos ALTER USER, CREATE DATABASE y GRANT PRIVILEGES usando las variables de entorno.

# Apaga ese proceso temporal de MariaDB.

# 4. Lanzamiento Final (El Relevo)
# El script termina ejecutando el comando definitivo para que el contenedor se quede encendido.

# Acción: exec mysqld.

# El Pormenor del exec: Usamos exec para que el proceso de MariaDB pase a ser el PID 1 (el proceso principal) del contenedor. Si no usas exec, el contenedor podría no cerrarse correctamente cuando le des a docker stop.


# En el Dockerfile:

# Instalas el software (apt-get install mariadb-server).

# Configuras los archivos de red (my.cnf) para que escuche en 0.0.0.0.

# Copias tu entrypoint.sh.

# En el entrypoint.sh:

# Creas los directorios de sistema (/run/mysqld).

# Decides si inicializar o no la DB según si el volumen está vacío.

# Lanzas el proceso final con exec mysqld.