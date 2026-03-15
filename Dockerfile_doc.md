## 1. El Cimiento: FROM

```docker
FROM debian:bullseye
```

Aquí defines el Sistema Operativo. Elegimos Debian o Alpine. Al ejecutar esto, Docker descarga una imagen "rootfs" (un sistema de archivos básico) de Debian o Alpine.

## 2.Preparación de la "Caja de Herramientas": RUN apt-get
```docker
RUN apt-get update -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*
```
* **update**: Actualiza la lista de paquetes disponibles.

* **install -y mariadb-server**: Instala el motor de base de datos. El -y es vital porque el Dockerfile no es interactivo (nadie puede pulsar "y" por ti).

* **rm -rf ...** : Esto es "limpieza de obra". Borramos los archivos temporales de la instalación para que la imagen final ocupe menos megas.

## 3.La Configuración de Red: sed

```docker
RUN sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
```
Por defecto, MariaDB solo escucha a **127.0.0.1** (él mismo).

Si WordPress intenta conectar desde otro contenedor, MariaDB lo ignorará.

Cambiándolo a **0.0.0.0**, le decimos: "Escucha en todas las interfaces de red del contenedor".

## 4. Permisos y Directorios: mkdir y chown

```docker
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
```

MariaDB necesita un lugar donde guardar sus archivos temporales de proceso (sockets). Si el directorio no existe o el usuario mysql no tiene permisos, el servidor cracheará al arrancar.

## 5. La Puerta de Enlace: EXPOSE
```docker
EXPOSE 3306
```
Informa a Docker de que este contenedor escuchará en el puerto 3306. **No abre el puerto al mundo exterior (eso se hace en el Compose)**, pero sirve como documentación técnica y para la comunicación entre contenedores.

## 6. El Cerebro: COPY y ENTRYPOINT
```docker
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh
ENTRYPOINT ["setup.sh"]
```
* **COPY**: Trae tu script de configuración desde tu PC al interior de la imagen.

* **ENTRYPOINT**: Es el comando que se ejecuta siempre que el contenedor nace. Si este script termina, el contenedor muere.

<br>
**¿Por qué necesitamos un setup.sh?**

Aquí es donde entra la lógica de negocio. Un Dockerfile construye la imagen, pero el setup.sh configura el estado cuando el contenedor arranca. Dentro de ese script deberías:

* Iniciar el servicio MariaDB temporalmente.

* Crear la base de datos (ej. CREATE DATABASE IF NOT EXISTS...).

* Crear el usuario de WordPress y darle privilegios.

* Cambiar la contraseña del root.

* Apagar el servicio temporal y volverlo a lanzar en primer plano (usando mysqld_safe).