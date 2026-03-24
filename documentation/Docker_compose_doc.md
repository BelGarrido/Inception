```docker
version: '3.8'

services:
  mariadb:
    # 1. ¿Dónde está el Dockerfile?
    build:
      context: ./requirements/mariadb
      dockerfile: Dockerfile
    
    # 2. Nombre del contenedor (para que no sea un hash aleatorio)
    container_name: mariadb

    # 3. Variables de entorno (Las "llaves" de tu DB)
    env_file:
      - .env

    # 4. Redes: Para que WordPress pueda encontrarlo
    networks:
      - inception_network

    # 5. Volúmenes: Para que si apagas el PC, tus datos sigan ahí
    volumes:
      - db_data:/var/lib/mysql

    # 6. Política de reinicio
    restart: always

```



## 1. El "Apodo" (dentro de services)

```YAML
    volumes:
      - db_data:/var/lib/mysql
```
Aquí, db_data es un identificador interno (un alias). Le estás diciendo a Compose: "Busca en este mismo archivo un volumen que yo he decidido llamar db_data y conéctalo a la carpeta /var/lib/mysql del contenedor".

## 2. El "Nombre Real" (en la declaración global)
```YAML
volumes:
  db_data:
    name: mariadb_data
```
(/home/login/data)

Aquí es donde ocurre la magia y la conexión.

* **db_data**: (a la izquierda) es el enlace que conecta con el alias que usaste arriba. Es como el nombre de una variable en C.

* **name**: mariadb_data: Es el nombre físico que tendrá el volumen en tu sistema operativo.

¿Por qué hacerlo así? (Analogía técnica)
Imagina que estás programando en C:

db_data es el nombre de la variable que usas en tu código.

mariadb_data es el espacio en la memoria física (la dirección de memoria) donde se guardan los datos.

Si mañana quieres que tu volumen se llame físicamente mi_base_de_datos_final, solo tendrías que cambiar el name en la declaración global, y no tendrías que tocar nada dentro de la configuración de tus services.


certificado ssl
lets encrypt